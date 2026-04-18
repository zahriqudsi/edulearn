import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/models/user_model.dart';
import 'package:edulearn/repositories/auth_repository.dart';
import 'package:edulearn/core/services/biometric_service.dart';
import 'package:edulearn/core/network/api_client.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LaravelAuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(biometricServiceProvider),
  );
});

class AuthNotifier extends Notifier<EduUser?> {
  late AuthRepository _repository;
  StreamSubscription? _subscription;

  @override
  EduUser? build() {
    _repository = ref.watch(authRepositoryProvider);
    _subscription = _repository.onAuthStateChanged.listen((user) {
      state = user;
    });
    ref.onDispose(() => _subscription?.cancel());
    return null;
  }

  Future<String> login(String email, String password) async {
    try {
      return await _repository.login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      return await _repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      return await _repository.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      return await _repository.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> resendVerification() async {
    try {
      return await _repository.resendVerification();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> logout() async {
    try {
      return await _repository.logout();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    final user = await _repository.getCurrentUser();
    state = user;
  }

  Future<void> updateProfile({
    String? name,
    String? password,
    String? bio,
    String? phone,
    String? address,
    String? avatarPath,
  }) async {
    try {
      await _repository.updateProfile(
        name: name,
        password: password,
        bio: bio,
        phone: phone,
        address: address,
        avatarPath: avatarPath,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> loginWithBiometrics() async {
    try {
      return await _repository.loginWithBiometrics();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> enrollBiometrics(String email, String password) async {
    await _repository.enrollBiometrics(email, password);
  }

  Future<bool> isBiometricEnabled() async {
    return await ref.read(biometricServiceProvider).isBiometricEnabled();
  }

  Future<bool> canCheckBiometrics() async {
    return await ref.read(biometricServiceProvider).canCheckBiometrics();
  }

  Future<String> linkInstitution(String code) async {
    try {
      final message = await _repository.linkInstitution(code);
      await refreshUser();
      return message;
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, EduUser?>(() {
  return AuthNotifier();
});
