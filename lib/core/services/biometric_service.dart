import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyEmail = 'bio_email';
  static const String _keyPassword = 'bio_password';
  static const String _keyEnabled = 'bio_enabled';

  /// Check if the device is capable of biometric auth
  Future<bool> canCheckBiometrics() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool isDeviceSupported = await _auth.isDeviceSupported();
    return canAuthenticateWithBiometrics && isDeviceSupported;
  }

  /// Authenticate the user with biometrics
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to log in to EduLearn',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('❌ [BIO ERROR]: Authentication failed: $e');
      return false;
    }
  }

  /// Save credentials for future biometric login
  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyEnabled, value: 'true');
  }

  /// Get saved credentials if biometric login is enabled
  Future<Map<String, String>?> getSavedCredentials() async {
    final enabled = await _storage.read(key: _keyEnabled);
    if (enabled != 'true') return null;

    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// Disable biometric login and clear saved credentials
  Future<void> disableBiometrics() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    await _storage.write(key: _keyEnabled, value: 'false');
  }

  /// Check if biometric login is currently enabled by the user
  Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: _keyEnabled);
    return enabled == 'true';
  }
}
