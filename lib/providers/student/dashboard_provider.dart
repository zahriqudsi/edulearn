import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/core/network/api_client.dart';

abstract class DashboardRepository {
  Future<Map<String, dynamic>> getStudentDashboard();
  Future<Map<String, dynamic>> getTeacherDashboard();
}

class LaravelDashboardRepository implements DashboardRepository {
  final ApiClient _apiClient;

  LaravelDashboardRepository(this._apiClient);

  @override
  Future<Map<String, dynamic>> getStudentDashboard() async {
    final response = await _apiClient.get('/student/dashboard');
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> getTeacherDashboard() async {
    final response = await _apiClient.get('/teacher/dashboard');
    return Map<String, dynamic>.from(response.data);
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return LaravelDashboardRepository(ref.watch(apiClientProvider));
});

final studentDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(dashboardRepositoryProvider).getStudentDashboard();
});

final teacherDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(dashboardRepositoryProvider).getTeacherDashboard();
});



