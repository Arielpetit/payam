import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/hce_nfc_service.dart';
import '../services/backend_service.dart';
import '../services/biometric_service.dart';
import '../services/global_nfc_listener.dart';
import '../services/nfc_method_channel.dart';
import '../router/app_router.dart';
import '../../shared/repositories/mock_repository.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/models/transaction_model.dart';

// Stream controller to broadcast background payments
final backgroundPaymentStream = StreamController<PaymentReceivedEvent>.broadcast();

class PaymentReceivedEvent {
  final String transactionId;
  final double amount;
  final String? senderName;
  
  PaymentReceivedEvent({
    required this.transactionId,
    required this.amount,
    this.senderName,
  });
}

enum NfcPaymentPhase {
idle,
amountEntry,
biometric,
waitingForTap, // Sender: card emulation active, waiting to be read
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
final bool isSender; // true = sender (card), false = receiver (reader)
final bool isBackgroundReceiving; // true when auto-receive is active

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
this.isSender = true,
this.isBackgroundReceiving = false,
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
bool? isSender,
bool? isBackgroundReceiving,
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
isSender: isSender ?? this.isSender,
isBackgroundReceiving: isBackgroundReceiving ?? this.isBackgroundReceiving,
);
}
}

class NfcPaymentNotifier extends StateNotifier<NfcPaymentState> {
final Ref _ref;
final HceNfcService _nfcService = HceNfcService();
final BackendService _backendService = BackendService();
final BiometricService _biometricService = BiometricService();
final AudioPlayer _audioPlayer = AudioPlayer();
Timer? _countdownTimer;
Timer? _pollTimer;

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

/// Stop background receive when sending payment
Future<void> startPaymentFlow() async {
  if (state.amount <= 0) return;

  // Stop background receive while sending
  if (state.isBackgroundReceiving) {
    await stopBackgroundReceive();
  }

// 1. Biometric authentication
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
isSender: true,
);

// 3. Start HCE card emulation - sender's phone acts as NFC card
  debugPrint('=== SENDER: Starting card emulation for $transactionId ===');
  try {
    await _nfcService.startCardEmulation(
      transactionId: transactionId,
      onSuccess: () {
        debugPrint('=== SENDER: Card was read by receiver ===');
        _vibrate();
        // Card was read — poll immediately instead of waiting 1.5s
        _pollImmediately(transactionId);
      },
      onError: (e) {
        debugPrint('=== SENDER: NFC ERROR: $e ===');
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
    debugPrint('=== SENDER: Card emulation started successfully ===');
  } catch (e) {
    debugPrint('=== SENDER: EXCEPTION starting card emulation: $e ===');
    if (mounted && state.phase == NfcPaymentPhase.waitingForTap) {
      _cleanup();
      state = state.copyWith(
        phase: NfcPaymentPhase.failed,
        errorMessage: 'Failed to start NFC: $e',
        errorCode: 'NFC_START_ERROR',
      );
    }
    return;
  }

// 4. Start polling for completion (receiver will call /transaction/tap)
_startPolling(transactionId);

// 5. Start countdown
_startCountdown(transactionId);
}

void _startPolling(String transactionId) {
_pollTimer?.cancel();
_pollTimer = Timer.periodic(const Duration(milliseconds: 1500), (t) async {
if (!mounted) {
t.cancel();
return;
}

final data = await _backendService.getTransaction(transactionId);
if (data == null) return;

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

Future<void> _pollImmediately(String transactionId) async {
  // Poll right away after card read, don't wait for next timer tick
  if (!mounted) return;
  final data = await _backendService.getTransaction(transactionId);
  if (data == null || !mounted) return;
  final status = data['status'] as String?;
  if (status == 'completed') {
    _onTransferSuccess(
      receiverName: data['receiverName'] as String?,
      newBalance: (data['senderNewBalance'] as num?)?.toDouble(),
    );
  }
}

void _startCountdown(String transactionId) {
_countdownTimer?.cancel();
int seconds = 30;
_countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
if (!mounted) {
t.cancel();
return;
}
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

if (newBalance != null) {
  final updatedUser = _ref.read(userProvider).copyWith(balance: newBalance);
  _ref.read(userProvider.notifier).state = updatedUser;
} else {
  _ref.read(userProvider.notifier).state = MockRepository.instance.currentUser;
}

// Add to transaction history
final txn = TransactionModel.mock(
  title: 'NFC Payment Sent',
  subtitle: 'To: ${receiverName ?? 'Unknown'}',
  amount: state.amount,
  isCredit: false,
  type: TransactionType.send,
  status: TransactionStatus.success,
  date: DateTime.now(),
  recipientName: receiverName,
  note: 'NFC Tap payment',
);
MockRepository.instance.addTransaction(txn);
_ref.read(transactionsProvider.notifier).state =
    MockRepository.instance.transactions;

state = state.copyWith(
phase: NfcPaymentPhase.success,
recipientName: receiverName,
);

// Navigate to dedicated success screen
_ref.read(routerProvider).go('/nfc-success', extra: {
  'amount': state.amount,
  'recipientName': receiverName,
  'isSender': true,
});

if (_ref.read(autoReceiveNfcProvider)) {
_startBackgroundReceiveIfEnabled();
}
}

// ─── RECEIVER FLOW: ReaderMode ─────────────────────────────────────

/// Entry point for receiver - uses background receive
/// This is now automatic when the app is in background or on other screens
/// Call this to manually start background receive if needed
Future<void> ensureBackgroundReceiveActive() async {
  if (!state.isBackgroundReceiving) {
    await startBackgroundReceive();
  }
}

void _startReceiveCountdown() {
  _countdownTimer?.cancel();
}

Future<void> _handleReceivedTransaction(String transactionId) async {
  debugPrint('Handling received transaction: $transactionId');
  
  state = state.copyWith(phase: NfcPaymentPhase.processing);
  final user = _ref.read(userProvider);

  try {
    final response = await _backendService.tapReceive(
      transactionId: transactionId,
      receiverId: user.id,
    );
    
    debugPrint('Backend response: success=${response.success}');
    
    if (!mounted) return;

    if (!response.success) {
      state = state.copyWith(
        phase: NfcPaymentPhase.failed,
        errorMessage: response.errorMessage,
        errorCode: response.errorCode,
      );
      return;
    }

    // Update receiver balance
    if (response.receiverNewBalance != null) {
      final updatedUser = _ref.read(userProvider).copyWith(balance: response.receiverNewBalance!);
      _ref.read(userProvider.notifier).state = updatedUser;
    }

    // Add to history
    final txn = TransactionModel.mock(
      title: 'NFC Payment Received',
      subtitle: 'From: ${response.senderName ?? 'Unknown'}',
      amount: response.amount ?? state.amount,
      isCredit: true,
      type: TransactionType.receive,
      status: TransactionStatus.success,
      date: DateTime.now(),
      recipientName: response.senderName,
      note: 'NFC Tap payment',
    );
    MockRepository.instance.addTransaction(txn);
    _ref.read(transactionsProvider.notifier).state = MockRepository.instance.transactions;

    _vibrate();
    _playSuccessSound();
    
    // Navigate to success screen
    _ref.read(routerProvider).go('/nfc-success', extra: {
      'amount': response.amount ?? state.amount,
      'recipientName': response.senderName,
      'isSender': false,
    });
    
    state = state.copyWith(phase: NfcPaymentPhase.success);
  } catch (e) {
    debugPrint('Error in _handleReceivedTransaction: $e');
    if (mounted) {
      state = state.copyWith(
        phase: NfcPaymentPhase.failed,
        errorMessage: 'Error: $e',
        errorCode: 'HANDLE_ERROR',
      );
    }
  }
}

/// Called from main.dart when app is launched via NFC intent (legacy)
Future<void> handleIncomingNfcTransaction(String transactionId) async {
_handleReceivedTransaction(transactionId);
}

Future<void> _playSuccessSound() async {
try {
  await _audioPlayer.stop();
  await _audioPlayer.play(AssetSource('sounds/sound.mp3'));
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

// ─── BACKGROUND RECEIVE MODE (Auto-receive) ───────────────────────────

/// Start background receiving - called when app launches if auto-receive is enabled
Future<void> startBackgroundReceive() async {
  if (state.isBackgroundReceiving) return;
  
  debugPrint('Starting background NFC receive mode');
  state = state.copyWith(isBackgroundReceiving: true);
  
  await GlobalNfcListener().startBackgroundListener(
    onTransactionReceived: (transactionId) {
      debugPrint('Background received: $transactionId');
      _handleBackgroundTransaction(transactionId);
    },
  );
}

/// Stop background receiving - ONLY call this when sending payment
Future<void> stopBackgroundReceive() async {
  if (!state.isBackgroundReceiving) return;
  
  debugPrint('Stopping background receive');
  await GlobalNfcListener().stopBackgroundListener();
  state = state.copyWith(isBackgroundReceiving: false);
}

/// Handle transaction received in background
void _handleBackgroundTransaction(String transactionId) async {
  debugPrint('Processing background transaction: $transactionId');
  
  // Cancel timers
  _countdownTimer?.cancel();
  _pollTimer?.cancel();

  // Update state
  state = state.copyWith(
    phase: NfcPaymentPhase.processing,
    isSender: false,
    isBackgroundReceiving: false,
  );

  // Process the transaction
  try {
    await _handleReceivedTransaction(transactionId);
  } catch (e) {
    debugPrint('Error processing background transaction: $e');
    if (mounted) {
      state = state.copyWith(
        phase: NfcPaymentPhase.failed,
        errorMessage: 'Error: $e',
        errorCode: 'BACKGROUND_ERROR',
      );
    }
  }

  // Emit event for UI overlay
  final successState = state;
  if (successState.phase == NfcPaymentPhase.success) {
    backgroundPaymentStream.add(PaymentReceivedEvent(
      transactionId: transactionId,
      amount: successState.amount,
      senderName: successState.recipientName,
    ));
  }

  // Restart background receive if enabled
  if (_ref.read(autoReceiveNfcProvider)) {
    _startBackgroundReceiveIfEnabled();
  }
}

/// Check if should pause background receive (e.g., when initiating payment)
bool get shouldPauseBackgroundReceive => 
state.phase == NfcPaymentPhase.waitingForTap || 
state.phase == NfcPaymentPhase.biometric ||
state.phase == NfcPaymentPhase.amountEntry;

/// Start background receive if setting is enabled
Future<void> _startBackgroundReceiveIfEnabled() async {
final autoReceive = _ref.read(autoReceiveNfcProvider);
if (autoReceive && !state.isBackgroundReceiving) {
await startBackgroundReceive();
}
}

void _cleanup() {
  _countdownTimer?.cancel();
  _pollTimer?.cancel();
  // Only stop card emulation — do not stop reader mode or clear its callback
  // because the receiver may have a transaction in-flight
  _nfcService.stopCardEmulation();
}

void reset() {
_cleanup();
state = const NfcPaymentState();
_checkNfcAvailability();

// Restart background receive if enabled
_startBackgroundReceiveIfEnabled();
}

@override
void dispose() {
_cleanup();
_audioPlayer.dispose();
super.dispose();
}
}

final hcePaymentProvider =
    StateNotifierProvider<NfcPaymentNotifier, NfcPaymentState>((ref) {
  return NfcPaymentNotifier(ref);
});