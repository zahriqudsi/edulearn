import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edulearn/models/user_model.dart';
import 'package:edulearn/core/network/api_client.dart';
import 'package:edulearn/core/services/biometric_service.dart';

abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });
  Future<String> forgotPassword(String email);
  Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  });
  Future<String> resendVerification();
  Future<String> logout();
  Future<EduUser?> getCurrentUser();
  Future<void> updateProfile({
    String? name,
    String? password,
    String? bio,
    String? phone,
    String? address,
    String? avatarPath,
  });
  Future<String?> loginWithBiometrics();
  Future<void> enrollBiometrics(String email, String password);
  Future<String> linkInstitution(String code);
  Stream<EduUser?> get onAuthStateChanged;
}

class LaravelAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  final BiometricService _biometricService;
  final StreamController<EduUser?> _authController =
      StreamController<EduUser?>.broadcast();

  LaravelAuthRepository(this._apiClient, this._biometricService) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        final response = await _apiClient.get('/user');
        final user = EduUser.fromJson(response.data);
        _authController.add(user);
      } catch (e) {
        prefs.remove('auth_token');
        _authController.add(null);
      }
    } else {
      _authController.add(null);
    }
  }

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      final user = EduUser.fromJson(response.data['user']);
      final message = response.data['message'] ?? 'Login successful';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      _authController.add(user);
      return message;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiClient.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return response.data['message'] ?? 'Registration successful';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        '/forgot-password',
        data: {'email': email},
      );
      return response.data['message'] ?? 'Reset link sent if email exists';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        '/reset-password',
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return response.data['message'] ?? 'Password reset successful';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> resendVerification() async {
    try {
      final response = await _apiClient.post('/email/resend');
      return response.data['message'] ?? 'Verification link sent';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> logout() async {
    String message = 'Logged out successfully';
    try {
      final response = await _apiClient.post('/logout');
      message = response.data['message'] ?? message;
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _authController.add(null);
    }
    return message;
  }

  @override
  Future<EduUser?> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/user');
      final user = EduUser.fromJson(response.data);
      _authController.add(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? password,
    String? bio,
    String? phone,
    String? address,
    String? avatarPath,
  }) async {
    dynamic data;

    if (avatarPath != null) {
      data = FormData.fromMap({
        '_method': 'PATCH',
        if (name != null) 'name': name,
        if (password != null) 'password': password,
        if (bio != null) 'bio': bio,
        if (phone != null) 'phone_number': phone,
        if (address != null) 'address': address,
        'avatar_url': await MultipartFile.fromFile(avatarPath),
      });
    } else {
      data = {
        '_method': 'PATCH',
        if (name != null) 'name': name,
        if (password != null) 'password': password,
        if (bio != null) 'bio': bio,
        if (phone != null) 'phone_number': phone,
        if (address != null) 'address': address,
      };
    }

    await _apiClient.post('/profile', data: data);
    await getCurrentUser();
  }

  @override
  Future<String?> loginWithBiometrics() async {
    final hasBio = await _biometricService.canCheckBiometrics();
    final isEnabled = await _biometricService.isBiometricEnabled();

    if (!hasBio || !isEnabled) return null;

    final authenticated = await _biometricService.authenticate();
    if (!authenticated) return null;

    final creds = await _biometricService.getSavedCredentials();
    if (creds == null) return null;

    try {
      return await login(creds['email']!, creds['password']!);
    } catch (e) {
      // If server login fails (pwd changed), disable bio
      await _biometricService.disableBiometrics();
      return null;
    }
  }

  @override
  Future<void> enrollBiometrics(String email, String password) async {
    await _biometricService.saveCredentials(email, password);
  }

  @override
  Future<String> linkInstitution(String code) async {
    try {
      final response = await _apiClient.post(
        '/student/link-institution',
        data: {'code': code},
      );
      await getCurrentUser();
      return response.data['message'] ?? 'Successfully linked institution';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<EduUser?> get onAuthStateChanged => _authController.stream;
}
