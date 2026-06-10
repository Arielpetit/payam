import 'dart:async';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'nfc_method_channel.dart';

class HceNfcService {
  static final HceNfcService _instance = HceNfcService._internal();
  factory HceNfcService() => _instance;
  HceNfcService._internal();

  Function(String transactionId)? onTransactionReceived;
  VoidCallback? onCardRead;

  Future<bool> isAvailable() async {
    try {
      final available = await nfcMethodChannel.isNfcAvailable();
      if (!available) return false;
      return await NfcManager.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<void> startCardEmulation({
    required String transactionId,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    onCardRead = onSuccess;
    nfcMethodChannel.onCardRead = onSuccess;

    try {
      await nfcMethodChannel.startCardEmulation(transactionId);
    } catch (e) {
      onError?.call('Failed to start card emulation: $e');
    }
  }

  Future<void> stopCardEmulation() async {
    onCardRead = null;
    nfcMethodChannel.onCardRead = null;
    
    try {
      await nfcMethodChannel.stopCardEmulation();
    } catch (_) {}
  }

  Future<void> startReaderMode({
    required Function(String transactionId) onTransactionReceived,
    Function(String)? onError,
  }) async {
    this.onTransactionReceived = onTransactionReceived;
    // DON'T set nfcMethodChannel.onTransactionReceived - GlobalNfcListener manages it
    
    try {
      await nfcMethodChannel.startReaderMode();
    } catch (e) {
      onError?.call('Failed to start reader mode: $e');
    }
  }

  Future<void> stopReaderMode() async {
    onTransactionReceived = null;
    try {
      await nfcMethodChannel.stopReaderMode();
    } catch (_) {}
  }

  Future<void> stopAll() async {
    await stopCardEmulation();
    await stopReaderMode();
  }
}