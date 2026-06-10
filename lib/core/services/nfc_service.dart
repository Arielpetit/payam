import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  static final NfcService _instance = NfcService._internal();
  factory NfcService() => _instance;
  NfcService._internal();

  static const _mimeType = 'application/vnd.payam.transaction';

  Future<bool> isAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Sender: write transactionId as NDEF to the receiver's phone.
  /// Calls [onTagFound] when another device is tapped.
  /// Calls [onError] on failure.
  Future<void> startSenderSession({
    required String transactionId,
    required VoidCallback onTagFound,
    required Function(String) onError,
  }) async {
    try {
      final payload = utf8.encode(jsonEncode({'transactionId': transactionId}));
      final mimeBytes = utf8.encode(_mimeType);

      final record = NdefRecord(
        typeNameFormat: NdefTypeNameFormat.media,
        type: Uint8List.fromList(mimeBytes),
        identifier: Uint8List(0),
        payload: Uint8List.fromList(payload),
      );
      final message = NdefMessage([record]);

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final ndef = Ndef.from(tag);
            if (ndef == null || !ndef.isWritable) {
              await NfcManager.instance.stopSession(
                errorMessage: 'Tag not writable',
              );
              onError('NFC tag not writable');
              return;
            }
            await ndef.write(message);
            await NfcManager.instance.stopSession();
            onTagFound();
          } catch (e) {
            await NfcManager.instance.stopSession(errorMessage: e.toString());
            onError('Failed to write NFC: $e');
          }
        },
      );
    } on PlatformException catch (e) {
      onError('NFC session error: ${e.message}');
    }
  }

  /// Receiver: parse transactionId from an incoming NFC tag.
  /// Used when app is already open and detects a tag.
  Future<void> startReceiverSession({
    required Function(String transactionId) onTransactionReceived,
    required Function(String) onError,
  }) async {
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final txnId = _extractTransactionId(tag);
            await NfcManager.instance.stopSession();
            if (txnId != null) {
              onTransactionReceived(txnId);
            } else {
              onError('Invalid NFC payload');
            }
          } catch (e) {
            await NfcManager.instance.stopSession(errorMessage: e.toString());
            onError('Failed to read NFC: $e');
          }
        },
      );
    } on PlatformException catch (e) {
      onError('NFC session error: ${e.message}');
    }
  }

  /// Parse transactionId from an Android NFC intent payload (raw bytes).
  String? parseTransactionIdFromIntentPayload(Uint8List bytes) {
    try {
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return json['transactionId'] as String?;
    } catch (_) {
      return null;
    }
  }

  String? _extractTransactionId(NfcTag tag) {
    try {
      final ndef = Ndef.from(tag);
      final message = ndef?.cachedMessage;
      if (message == null || message.records.isEmpty) return null;
      final record = message.records.first;
      final json = jsonDecode(utf8.decode(record.payload)) as Map<String, dynamic>;
      return json['transactionId'] as String?;
    } catch (_) {
      return null;
    }
  }

  void stopSession() {
    try {
      NfcManager.instance.stopSession();
    } catch (_) {}
  }
}
