import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nfc_transaction_model.dart';
import '../repositories/mock_repository.dart';
import 'app_providers.dart';

// ─── Log entry for the backend logger panel ──────────────────────────────────
class NfcLogEntry {
  final String message;
  final DateTime timestamp;
  final NfcLogLevel level;

  NfcLogEntry({
    required this.message,
    required this.timestamp,
    this.level = NfcLogLevel.info,
  });
}

enum NfcLogLevel { info, success, error, warning }

// ─── Overall sandbox state ────────────────────────────────────────────────────
enum NfcSandboxPhase {
  idle,
  biometric,
  transmitting, // wave animation running
  processing,   // spinner in backend log
  success,
  failed,
}

class NfcSandboxState {
  final NfcSandboxPhase phase;
  final double amount;
  final bool requireBiometric;
  final List<NfcLogEntry> logs;
  final List<NfcTransaction> history;
  final int countdown; // seconds remaining for token validity

  const NfcSandboxState({
    this.phase = NfcSandboxPhase.idle,
    this.amount = 5000,
    this.requireBiometric = true,
    this.logs = const [],
    this.history = const [],
    this.countdown = 0,
  });

  NfcSandboxState copyWith({
    NfcSandboxPhase? phase,
    double? amount,
    bool? requireBiometric,
    List<NfcLogEntry>? logs,
    List<NfcTransaction>? history,
    int? countdown,
  }) {
    return NfcSandboxState(
      phase: phase ?? this.phase,
      amount: amount ?? this.amount,
      requireBiometric: requireBiometric ?? this.requireBiometric,
      logs: logs ?? this.logs,
      history: history ?? this.history,
      countdown: countdown ?? this.countdown,
    );
  }
}

// ─── StateNotifier ────────────────────────────────────────────────────────────
class NfcSandboxNotifier extends StateNotifier<NfcSandboxState> {
  final Ref _ref;

  NfcSandboxNotifier(this._ref) : super(const NfcSandboxState());

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void toggleBiometric(bool value) {
    state = state.copyWith(requireBiometric: value);
  }

  void _addLog(String message, {NfcLogLevel level = NfcLogLevel.info}) {
    final entry = NfcLogEntry(
      message: message,
      timestamp: DateTime.now(),
      level: level,
    );
    state = state.copyWith(logs: [...state.logs, entry]);
  }

  /// Main flow: biometric → transmitting → processing → success/fail
  Future<void> simulateTap() async {
    if (state.phase != NfcSandboxPhase.idle &&
        state.phase != NfcSandboxPhase.failed &&
        state.phase != NfcSandboxPhase.success) {
      return; // already running
    }

    // Reset logs
    state = state.copyWith(
      phase: NfcSandboxPhase.biometric,
      logs: [],
    );

    _addLog('🔐 Biometric check initiated…', level: NfcLogLevel.info);
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate biometric success (always pass in sandbox)
    _addLog('✅ Biometric verified: usr_001', level: NfcLogLevel.success);
    await Future.delayed(const Duration(milliseconds: 400));

    // Transmit phase (wave animation)
    state = state.copyWith(phase: NfcSandboxPhase.transmitting, countdown: 30);
    _addLog(
      '📡 NFC tap detected — creating transaction token…',
      level: NfcLogLevel.info,
    );

    // Countdown tick
    for (int i = 30; i >= 28; i--) {
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(countdown: i);
    }

    // Processing phase
    state = state.copyWith(phase: NfcSandboxPhase.processing);
    _addLog(
      '{\n  "event": "NFC_TAP",\n  "senderId": "usr_001",\n  "receiverId": "usr_002",\n  "amount": ${state.amount.toStringAsFixed(0)},\n  "currency": "FCFA",\n  "token": "tkn_${DateTime.now().millisecondsSinceEpoch}"\n}',
      level: NfcLogLevel.info,
    );

    await Future.delayed(const Duration(milliseconds: 800));
    _addLog('🔍 Verifying token on secure server…', level: NfcLogLevel.info);
    await Future.delayed(const Duration(milliseconds: 600));
    _addLog('💳 Checking sender balance…', level: NfcLogLevel.info);
    await Future.delayed(const Duration(milliseconds: 500));

    // Check balance
    final user = MockRepository.instance.currentUser;
    if (user.balance < state.amount) {
      _addLog('❌ Insufficient balance!', level: NfcLogLevel.error);
      state = state.copyWith(phase: NfcSandboxPhase.failed, countdown: 0);
      return;
    }

    _addLog('💸 Debiting sender…', level: NfcLogLevel.info);
    await Future.delayed(const Duration(milliseconds: 400));

    // Execute
    final txn = NfcTransaction.create(
      senderUserId: 'usr_001',
      receiverUserId: 'usr_002',
      amount: state.amount,
      direction: NfcTransactionDirection.send,
    );
    MockRepository.instance.addNfcTransaction(txn);

    // Refresh user provider
    _ref.read(userProvider.notifier).state =
        MockRepository.instance.currentUser;

    _addLog('💰 Crediting receiver…', level: NfcLogLevel.info);
    await Future.delayed(const Duration(milliseconds: 400));
    _addLog(
      '{\n  "status": "SUCCESS",\n  "transactionId": "${txn.id.substring(0, 8)}",\n  "newSenderBalance": ${MockRepository.instance.currentUser.balance.toStringAsFixed(0)},\n  "timestamp": "${DateTime.now().toIso8601String()}"\n}',
      level: NfcLogLevel.success,
    );
    await Future.delayed(const Duration(milliseconds: 300));
    _addLog('🎉 Transfer complete!', level: NfcLogLevel.success);

    state = state.copyWith(
      phase: NfcSandboxPhase.success,
      countdown: 0,
      history: [txn, ...state.history],
    );
  }

  void reset() {
    state = const NfcSandboxState();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final nfcSandboxProvider =
    StateNotifierProvider<NfcSandboxNotifier, NfcSandboxState>(
  (ref) => NfcSandboxNotifier(ref),
);
