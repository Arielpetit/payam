import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'nfc_method_channel.dart';

// ── Backend base URL ──────────────────────────────────────────────────────
// TODO: Replace with env-based config before production
const String kBackendBase = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'http://localhost:3000',
);

class TransferResponse {
  final bool success;
  final String? transactionId;
  final double? amount;
  final double? senderNewBalance;
  final double? receiverNewBalance;
  final String? senderName;
  final String? receiverName;
  final String? errorMessage;
  final String? errorCode;

  TransferResponse({
    required this.success,
    this.transactionId,
    this.amount,
    this.senderNewBalance,
    this.receiverNewBalance,
    this.senderName,
    this.receiverName,
    this.errorMessage,
    this.errorCode,
  });

  factory TransferResponse.error(String message, [String? code]) =>
      TransferResponse(success: false, errorMessage: message, errorCode: code);
}

class BackendTransactionEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  BackendTransactionEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}

class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  final StreamController<BackendTransactionEvent> _eventController =
      StreamController<BackendTransactionEvent>.broadcast();

  Stream<BackendTransactionEvent> get eventStream => _eventController.stream;

  // ── Initiate (Sender) ────────────────────────────────────────────────────

  Future<TransferResponse> initiateTransaction({
    required String senderId,
    required double amount,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$kBackendBase/transaction/initiate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'senderId': senderId, 'amount': amount}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 && body['success'] == true) {
        return TransferResponse(
          success: true,
          transactionId: body['transactionId'] as String,
        );
      }
      return TransferResponse.error(
        body['error'] ?? 'Failed to initiate transaction',
        'INITIATE_FAILED',
      );
    } catch (e) {
      debugPrint('[Backend] initiateTransaction error: $e');
      return TransferResponse.error(
        'Cannot reach server. Are you on the same Wi-Fi?',
        'NETWORK_ERROR',
      );
    }
  }

  // ── Tap Receive (Receiver) ───────────────────────────────────────────────

  Future<TransferResponse> tapReceive({
    required String transactionId,
    required String receiverId,
  }) async {
    debugPrint('[Backend] tapReceive called: $transactionId');
    try {
      final res = await http
          .post(
            Uri.parse('$kBackendBase/transaction/tap'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'transactionId': transactionId,
              'receiverId': receiverId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 && body['success'] == true) {
        debugPrint('[Backend] tapReceive SUCCESS');
        _eventController.add(BackendTransactionEvent(
          type: 'transfer_success',
          data: {
            'transactionId': transactionId,
            'amount': body['amount'],
            'receiverName': body['receiverName'],
            'senderNewBalance': body['senderNewBalance'],
          },
          timestamp: DateTime.now(),
        ));

        return TransferResponse(
          success: true,
          transactionId: transactionId,
          amount: (body['amount'] as num?)?.toDouble(),
          senderNewBalance: (body['senderNewBalance'] as num?)?.toDouble(),
          senderName: body['senderName'] as String?,
          receiverName: body['receiverName'] as String?,
        );
      }
      debugPrint('[Backend] tapReceive FAILED: ${body['error']}');
      return TransferResponse.error(
        body['error'] ?? 'Transfer failed',
        'TAP_FAILED',
      );
    } catch (e) {
      debugPrint('[Backend] tapReceive ERROR: $e');
      return TransferResponse.error(
        'Cannot reach server. Are you on the same Wi-Fi?',
        'NETWORK_ERROR',
      );
    }
  }

  // ── Poll transaction status (Sender polls while waiting) ────────────────

  Future<Map<String, dynamic>?> getTransaction(String transactionId) async {
    try {
      final res = await http
          .get(Uri.parse('$kBackendBase/transaction/$transactionId'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    _eventController.close();
  }
}
