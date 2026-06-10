import 'package:uuid/uuid.dart';

enum TransactionType {
  send,
  receive,
  payment,
  airtime,
  data,
  bills,
  deposit,
  withdrawal,
}

enum TransactionStatus {
  success,
  pending,
  failed,
}

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime date;
  final String? reference;
  final String? recipientName;
  final String? recipientPhone;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.type,
    required this.status,
    required this.date,
    this.reference,
    this.recipientName,
    this.recipientPhone,
    this.note,
  });

  factory TransactionModel.mock({
    required String title,
    required String subtitle,
    required double amount,
    required bool isCredit,
    required TransactionType type,
    required TransactionStatus status,
    required DateTime date,
    String? recipientName,
    String? recipientPhone,
    String? note,
  }) {
    return TransactionModel(
      id: const Uuid().v4(),
      title: title,
      subtitle: subtitle,
      amount: amount,
      isCredit: isCredit,
      type: type,
      status: status,
      date: date,
      reference: 'PAY${DateTime.now().millisecondsSinceEpoch}',
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      note: note,
    );
  }
}
