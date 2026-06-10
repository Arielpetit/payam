import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/services/nfc_service.dart';
import '../../core/services/backend_service.dart';
import '../../core/services/biometric_service.dart';
import '../repositories/mock_repository.dart';
import 'app_providers.dart';

enum NfcPaymentPhase {
  idle,
  amountEntry,
  biometric,
  waitingForTap,   // Sender: wrote NDEF, waiting for websocket confirm
  processing,
  success,
  failed,
}

class NfcPaymentState {
  final NfcPaymentPhase phase;
  final double amount;
  final String? transactionId;
  final String? errorMessage;
  final String? errorCode;
  final int countdown;
  final bool isBiometricRequired;
  final String? recipientName;
  final bool nfcAvailable;

  const NfcPaymentState({
    this.phase = NfcPaymentPhase.idle,
    this.amount = 0,
    this.transactionId,
    this.errorMessage,
    this.errorCode,
    this.countdown = 30,
    this.isBiometricRequired = true,
    this.recipientName,
    this.nfcAvailable = false,
  });

  NfcPaymentState copyWith({
    NfcPaymentPhase? phase,
    double? amount,
    String? transactionId,
    String? errorMessage,
    String? errorCode,
    int? countdown,
    bool? isBiometricRequired,
    String? recipientName,
    bool? nfcAvailable,
  }) {
    return NfcPaymentState(
      phase: phase ?? this.phase,
      amount: amount ?? this.amount,
      transactionId: transactionId ?? this.transactionId,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      countdown: countdown ?? this.countdown,
      isBiometricRequired: isBiometricRequired ?? this.isBiometricRequired,
      recipientName: recipientName ?? this.recipientName,
      nfcAvailable: nfcAvailable ?? this.nfcAvailable,
    );
  }
}

class NfcPaymentNotifier extends StateNotifier<NfcPaymentState> {
  final Ref _ref;
  final NfcService _nfcService = NfcService();
  final BackendService _backendService = BackendService();
  final BiometricService _biometricService = BiometricService();
  Timer? _countdownTimer;
  StreamSubscription? _backendEventSub;

  NfcPaymentNotifier(this._ref) : super(const NfcPaymentState()) {
    _checkNfcAvailability();
  }

  Future<void> _checkNfcAvailability() async {
    final available = await _nfcService.isAvailable();
    if (mounted) state = state.copyWith(nfcAvailable: available);
  }

  Future<void> recheckNfc() => _checkNfcAvailability();

  void setAmount(double amount) => state = state.copyWith(amount: amount);
  void setBiometricRequired(bool v) => state = state.copyWith(isBiometricRequired: v);

  // ─── SENDER FLOW ────────────────────────────────────────────────────────────

  Future<void> startPaymentFlow() async {
    if (state.amount <= 0) return;

    // 1. Biometric
    if (state.isBiometricRequired) {
      state = state.copyWith(phase: NfcPaymentPhase.biometric);
      final ok = await _biometricService.authenticate(
        localizedReason: 'Authenticate to send ${state.amount.toStringAsFixed(0)} FCFA',
      );
      if (!ok) {
        state = state.copyWith(
          phase: NfcPaymentPhase.failed,
          errorMessage: 'Authentication failed',
          errorCode: 'AUTH_FAILED',
        );
        return;
      }
    }

    // 2. Create transaction on backend
    final user = _ref.read(userProvider);
    final initResponse = await _backendService.initiateTransaction(
      senderId: user.id,
      amount: state.amount,
    );

    if (!initResponse.success || initResponse.transactionId == null) {
      state = state.copyWith(
        phase: NfcPaymentPhase.failed,
        errorMessage: initResponse.errorMessage ?? 'Failed to create transaction',
        errorCode: initResponse.errorCode ?? 'TXN_CREATE_FAILED',
      );
      return;
    }

    final transactionId = initResponse.transactionId!;
    state = state.copyWith(
      transactionId: transactionId,
      phase: NfcPaymentPhase.waitingForTap,
      countdown: 30,
    );

    // 3. Poll backend for transfer_success (receiver is on a different device)
    _backendEventSub?.cancel();
    _startPolling(transactionId);

    // 4. Start countdown
    _startCountdown(transactionId);

    // 5. Write transactionId to NFC — waits for receiver phone tap
    _nfcService.startSenderSession(
      transactionId: transactionId,
      onTagFound: () {
        // NDEF written successfully — now waiting for backend confirmation
        // The receiver's phone will call POST /tap/receive
        // which triggers the transfer_success event above
      },
      onError: (e) {
        if (mounted && state.phase == NfcPaymentPhase.waitingForTap) {
          _cleanup();
          state = state.copyWith(
            phase: NfcPaymentPhase.failed,
            errorMessage: 'NFC error: $e',
            errorCode: 'NFC_ERROR',
          );
        }
      },
    );
  }

  void _startPolling(String transactionId) {
    // Poll every 1.5s until completed, expired, or countdown hits 0
    _backendEventSub = Stream.periodic(const Duration(milliseconds: 1500))
        .asyncMap((_) => _backendService.getTransaction(transactionId))
        .listen((data) {
      if (!mounted || data == null) return;
      final status = data['status'] as String?;
      if (status == 'completed') {
        _onTransferSuccess(
          receiverName: data['receiverName'] as String?,
          newBalance: (data['senderNewBalance'] as num?)?.toDouble(),
        );
      } else if (status == 'expired' || status == 'failed') {
        _cleanup();
        state = state.copyWith(
          phase: NfcPaymentPhase.failed,
          errorMessage: status == 'expired'
              ? 'Transaction expired. Try again.'
              : 'Transfer failed on server.',
          errorCode: status?.toUpperCase(),
        );
      }
    });
  }

  void _startCountdown(String transactionId) {
    _countdownTimer?.cancel();
    int seconds = 30;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      seconds--;
      state = state.copyWith(countdown: seconds);
      if (seconds <= 0) {
        t.cancel();
        if (state.phase == NfcPaymentPhase.waitingForTap) {
          _cleanup();
          state = state.copyWith(
            phase: NfcPaymentPhase.failed,
            errorMessage: 'Transaction expired. Try again.',
            errorCode: 'TXN_EXPIRED',
          );
        }
      }
    });
  }

  void _onTransferSuccess({String? receiverName, double? newBalance}) {
    _cleanup();
    _vibrate();
    _playSuccessSound();
    _ref.read(userProvider.notifier).state = MockRepository.instance.currentUser;
    state = state.copyWith(
      phase: NfcPaymentPhase.success,
      recipientName: receiverName,
    );
  }

  // ─── RECEIVER FLOW ───────────────────────────────────────────────────────────

  /// Called from main.dart when app is launched via NFC intent.
  /// [transactionId] extracted from the NDEF payload.
  Future<void> handleIncomingNfcTransaction(String transactionId) async {
    state = state.copyWith(phase: NfcPaymentPhase.processing);

    final user = _ref.read(userProvider);
    final response = await _backendService.tapReceive(
      transactionId: transactionId,
      receiverId: user.id,
    );

    if (!mounted) return;

    if (!response.success) {
      state = state.copyWith(
        phase: NfcPaymentPhase.failed,
        errorMessage: response.errorMessage,
        errorCode: response.errorCode,
      );
      return;
    }

    _vibrate();
    _playSuccessSound();
    _ref.read(userProvider.notifier).state = MockRepository.instance.currentUser;
    state = state.copyWith(
      phase: NfcPaymentPhase.success,
      amount: response.amount ?? state.amount,
      recipientName: response.senderName,
    );
  }

  Future<void> _playSuccessSound() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/sound.mp3'));
    } catch (_) {}
  }

  Future<void> _vibrate() async {
    try {
      final has = await Vibration.hasVibrator();
      if (has == true) {
        await Vibration.vibrate(duration: 80);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 80);
      }
    } catch (_) {}
  }

  void _cleanup() {
    _countdownTimer?.cancel();
    _backendEventSub?.cancel();
    _nfcService.stopSession();
  }

  void reset() {
    _cleanup();
    state = const NfcPaymentState();
    _checkNfcAvailability();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

final nfcPaymentProvider =
    StateNotifierProvider<NfcPaymentNotifier, NfcPaymentState>((ref) {
  return NfcPaymentNotifier(ref);
});
