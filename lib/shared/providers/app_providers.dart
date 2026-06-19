import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/notification_model.dart';
import '../repositories/mock_repository.dart';

// Theme Mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Locale/Language
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

// Auth state
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

// Balance visibility
final balanceVisibleProvider = StateProvider<bool>((ref) => true);

// User data
final userProvider = StateProvider<UserModel>((ref) {
  return MockRepository.instance.currentUser;
});

// Transactions
final transactionsProvider = StateProvider<List<TransactionModel>>((ref) {
  return MockRepository.instance.transactions;
});

// Notifications
final notificationsProvider = StateProvider<List<NotificationModel>>((ref) {
  return MockRepository.instance.notifications;
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

// Contacts
final contactsProvider = StateProvider<List<UserModel>>((ref) {
  return MockRepository.instance.contacts;
});

// NFC Settings
const _kAutoReceiveKey = 'auto_receive_nfc';

class AutoReceiveNfcNotifier extends Notifier<bool> {
  @override
  bool build() => false; // will be overwritten after prefs load

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kAutoReceiveKey) ?? false;
  }

  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoReceiveKey, value);
  }
}

final autoReceiveNfcProvider = NotifierProvider<AutoReceiveNfcNotifier, bool>(
  AutoReceiveNfcNotifier.new,
);

// Navigation
final currentNavIndexProvider = StateProvider<int>((ref) => 0);

// Send money state
class SendMoneyState {
  final UserModel? recipient;
  final double amount;
  final String note;

  const SendMoneyState({
    this.recipient,
    this.amount = 0,
    this.note = '',
  });

  SendMoneyState copyWith({
    UserModel? recipient,
    double? amount,
    String? note,
  }) {
    return SendMoneyState(
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}

final sendMoneyStateProvider =
    StateProvider<SendMoneyState>((ref) => const SendMoneyState());
