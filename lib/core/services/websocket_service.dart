import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] ?? '',
      data: json['data'] ?? {},
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };
}

class WebSocketEvent {
  final String type;
  final dynamic payload;

  WebSocketEvent({required this.type, this.payload});
}

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final StreamController<WebSocketEvent> _eventController =
      StreamController<WebSocketEvent>.broadcast();

  Stream<WebSocketEvent> get eventStream => _eventController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> connect(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isConnected = true;
    debugPrint('[WebSocket] Connected for user: $userId');
    
    _eventController.add(WebSocketEvent(
      type: 'connection_established',
      payload: {'userId': userId, 'status': 'connected'},
    ));
  }

  void disconnect() {
    _isConnected = false;
    debugPrint('[WebSocket] Disconnected');
  }

  void sendEvent(WebSocketMessage message) {
    if (!_isConnected) {
      debugPrint('[WebSocket] Attempted to send message while disconnected');
      return;
    }

    debugPrint('[WebSocket] Sending: ${jsonEncode(message.toJson())}');
    
    _eventController.add(WebSocketEvent(
      type: message.type,
      payload: message.data,
    ));
  }

  void simulateServerEvent(String type, Map<String, dynamic> data) {
    if (!_isConnected) {
      return;
    }

    _eventController.add(WebSocketEvent(
      type: type,
      payload: data,
    ));
  }

  void simulateTransferSuccess({
    required String transactionId,
    required double amount,
    required String senderName,
  }) {
    simulateServerEvent('transfer_success', {
      'transactionId': transactionId,
      'amount': amount,
      'senderName': senderName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void simulateMoneyReceived({
    required String transactionId,
    required double amount,
    required String senderName,
  }) {
    simulateServerEvent('money_received', {
      'transactionId': transactionId,
      'amount': amount,
      'senderName': senderName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void dispose() {
    _eventController.close();
  }
}