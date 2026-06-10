import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  bool get isBiometricAvailable => _isBiometricAvailable;
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  Future<void> initialize() async {
    try {
      _isBiometricAvailable = await _localAuth.canCheckBiometrics;
      
      if (_isBiometricAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
      }
    } on PlatformException catch (e) {
      _isBiometricAvailable = false;
      _availableBiometrics = [];
      debugPrint('Biometric initialization error: ${e.message}');
    }
  }

  Future<bool> authenticate({
    String localizedReason = 'Authenticate to proceed with transaction',
    bool useErrorDialogs = true,
  }) async {
    try {
      if (!_isBiometricAvailable) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication error: ${e.message}');
      return false;
    }
  }

  Future<bool> authenticateWithFallback({
    String localizedReason = 'Authenticate to proceed with transaction',
  }) async {
    try {
      if (!_isBiometricAvailable) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication error: ${e.message}');
      return false;
    }
  }

  String getBiometricTypeName() {
    if (_availableBiometrics.isEmpty) {
      return 'Biometric';
    }

    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (_availableBiometrics.contains(BiometricType.weak)) {
      return 'Biometric';
    } else if (_availableBiometrics.contains(BiometricType.strong)) {
      return 'Secure Biometric';
    }

    return 'Biometric';
  }

  Future<bool> isDeviceSupported() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }
}