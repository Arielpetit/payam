import 'package:uuid/uuid.dart';

enum NfcTransactionStatus { pending, success, failed }

enum NfcTransactionDirection { send, receive }

class NfcTransaction {
  final String id;
  final String senderUserId;
  final String receiverUserId;
  final double amount;
  final NfcTransactionDirection direction;
  final NfcTransactionStatus status;
  final DateTime createdAt;

  const NfcTransaction({
    required this.id,
    required this.senderUserId,
    required this.receiverUserId,
    required this.amount,
    required this.direction,
    required this.status,
    required this.createdAt,
  });

  factory NfcTransaction.create({
    required String senderUserId,
    required String receiverUserId,
    required double amount,
    required NfcTransactionDirection direction,
  }) {
    return NfcTransaction(
      id: const Uuid().v4(),
      senderUserId: senderUserId,
      receiverUserId: receiverUserId,
      amount: amount,
      direction: direction,
      status: NfcTransactionStatus.pending,
      createdAt: DateTime.now(),
    );
  }
}
