import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Centralized NFC method channel handler
/// This ensures we have a single handler that dispatches to the appropriate callbacks
class NfcMethodChannelHandler {
  static final NfcMethodChannelHandler _instance = NfcMethodChannelHandler._internal();
  factory NfcMethodChannelHandler() => _instance;
  NfcMethodChannelHandler._internal();

  static const _channel = MethodChannel('com.example.payam/nfc');
  static bool _isHandlerSet = false;

  Function(String transactionId)? get onTransactionReceived => _onTransactionReceived;
  Function(String transactionId)? _onTransactionReceived;
  set onTransactionReceived(Function(String transactionId)? cb) {
    _onTransactionReceived = cb;
    if (cb != null) {
      debugPrint('NfcMethodChannel: Callback registered');
      if (_pendingTransactionId != null) {
        final pending = _pendingTransactionId!;
        _pendingTransactionId = null;
        debugPrint('NfcMethodChannel: Flushing pending transaction $pending');
        cb(pending);
      }
    } else {
      debugPrint('NfcMethodChannel: Callback cleared');
    }
  }
  VoidCallback? onCardRead;
  Function(String transactionId)? onNfcIntent;
  Function(String logMessage)? onLog;

  // Pending transaction that arrived before callback was ready
  String? _pendingTransactionId;

  // Persistent log buffer — survives screen navigation
  final List<String> logBuffer = [];
  static const int _maxBufferSize = 200;

  void _bufferLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 23);
    final entry = '[$timestamp] $message';
    logBuffer.add(entry);
    if (logBuffer.length > _maxBufferSize) logBuffer.removeAt(0);
    onLog?.call(message);
  }

  /// Initialize the centralized handler (call once at app startup)
  void initialize() {
    if (_isHandlerSet) return;
    
    _channel.setMethodCallHandler((call) async {
      debugPrint('NfcMethodChannel: Received ${call.method}');
      
      switch (call.method) {
        case 'onTransactionReceived':
          final txnId = call.arguments as String?;
          if (txnId != null && txnId.isNotEmpty) {
            debugPrint('NfcMethodChannel: Transaction received $txnId');
            final cb = _onTransactionReceived;
            if (cb != null) {
              debugPrint('NfcMethodChannel: Invoking callback');
              try {
                cb(txnId);
                debugPrint('NfcMethodChannel: Callback completed');
              } catch (e, stack) {
                debugPrint('NfcMethodChannel: Callback error: $e');
                debugPrint('Stack: $stack');
              }
            } else {
              debugPrint('NfcMethodChannel: No callback - buffering transaction');
              _pendingTransactionId = txnId;
            }
          }
          break;
          
        case 'onCardRead':
          debugPrint('NfcMethodChannel: Card read callback');
          final cb = onCardRead;
          cb?.call();
          break;
          
        case 'onNfcIntent':
          final txnId = call.arguments as String?;
          if (txnId != null && txnId.isNotEmpty) {
            debugPrint('NfcMethodChannel: NFC intent $txnId');
            onNfcIntent?.call(txnId);
          }
          break;
          
        case 'onLog':
          final message = call.arguments as String?;
          if (message != null && message.isNotEmpty) {
            _bufferLog(message);
          }
          break;
          
        default:
          debugPrint('NfcMethodChannel: Unknown method ${call.method}');
      }
    });
    
    _isHandlerSet = true;
  }

  /// Invoke startCardEmulation
  Future<void> startCardEmulation(String transactionId) {
    return _channel.invokeMethod('startCardEmulation', {
      'transactionId': transactionId,
    });
  }

  /// Invoke stopCardEmulation
  Future<void> stopCardEmulation() {
    return _channel.invokeMethod('stopCardEmulation');
  }

  /// Invoke startReaderMode
  Future<void> startReaderMode() {
    return _channel.invokeMethod('startReaderMode');
  }

  /// Invoke stopReaderMode
  Future<void> stopReaderMode() {
    return _channel.invokeMethod('stopReaderMode');
  }

  /// Check if NFC is available
  Future<bool> isNfcAvailable() async {
    try {
      final available = await _channel.invokeMethod<bool>('isNfcAvailable');
      return available ?? false;
    } catch (e) {
      debugPrint('NfcMethodChannel: Error checking NFC availability: $e');
      return false;
    }
  }
}

// Global instance for easy access
final nfcMethodChannel = NfcMethodChannelHandler();