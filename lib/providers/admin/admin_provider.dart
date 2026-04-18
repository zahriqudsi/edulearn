import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/core/network/api_client.dart';

class AdminStats {
  final int totalStudents;
  final int totalTeachers;
  final int totalCourses;
  final int activeInstitutions;

  AdminStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalCourses,
    required this.activeInstitutions,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalStudents: json['total_students'] ?? 0,
      totalTeachers: json['total_teachers'] ?? 0,
      totalCourses: json['total_courses'] ?? 0,
      activeInstitutions: json['active_institutions'] ?? 0,
    );
  }
}

abstract class AdminRepository {
  Future<AdminStats> getStats();
  Future<Map<String, dynamic>> getUsers({int page = 1, String? query, String? role});
  Future<Map<String, dynamic>> getInstitutions({int page = 1, String? query});
  
  // User CRUD
  Future<void> createUser(Map<String, dynamic> data);
  Future<void> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);
  Future<void> updateUserStatus(String id, String status, {String? institutionId});
  
  // Institution CRUD
  Future<void> createInstitution(Map<String, dynamic> data);
  Future<void> updateInstitution(String id, Map<String, dynamic> data);
  Future<void> deleteInstitution(String id);
  Future<void> updateInstitutionStatus(String id, String status);

  // Subscriptions
  Future<List<Map<String, dynamic>>> getSubscriptionPlans();
  Future<void> createSubscriptionPlan(Map<String, dynamic> data);
  Future<void> updateSubscriptionPlan(String id, Map<String, dynamic> data);
  Future<void> deleteSubscriptionPlan(String id);

  // Settings & Analytics
  Future<Map<String, dynamic>> getAnalytics();
  Future<Map<String, dynamic>> getSettings();
  Future<void> updateSettings(List<Map<String, dynamic>> settings);

  // Courses & Curriculum
  Future<Map<String, dynamic>> getCourses({int page = 1, String? query, String? institutionId});
  Future<Map<String, dynamic>> getCourseDetails(String id);
  Future<void> createCourse(Map<String, dynamic> data);
  Future<void> updateCourse(String id, Map<String, dynamic> data);
  Future<void> deleteCourse(String id);
  
  Future<void> createSubject(String courseId, Map<String, dynamic> data);
  Future<void> updateSubject(String id, Map<String, dynamic> data);
  Future<void> deleteSubject(String id);
  
  Future<void> createModule(String subjectId, Map<String, dynamic> data);
  Future<void> updateModule(String id, Map<String, dynamic> data);
  Future<void> deleteModule(String id);
  
  Future<void> createLesson(String moduleId, Map<String, dynamic> data);
  Future<void> updateLesson(String id, Map<String, dynamic> data);
  Future<void> deleteLesson(String id);
}

class LaravelAdminRepository implements AdminRepository {
  final ApiClient _apiClient;

  LaravelAdminRepository(this._apiClient);

  @override
  Future<AdminStats> getStats() async {
    final response = await _apiClient.get('/admin/stats');
    return AdminStats.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> getUsers({int page = 1, String? query, String? role}) async {
    final Map<String, dynamic> params = {'page': page};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (role != null) params['role'] = role;
    
    final response = await _apiClient.get('/admin/users', queryParameters: params);
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> getInstitutions({int page = 1, String? query}) async {
    final Map<String, dynamic> params = {'page': page};
    if (query != null && query.isNotEmpty) params['q'] = query;
    
    final response = await _apiClient.get('/admin/institutions', queryParameters: params);
    return Map<String, dynamic>.from(response.data);
  }

  // --- User CRUD ---
  @override
  Future<void> createUser(Map<String, dynamic> data) async {
    await _apiClient.post('/admin/users', data: data);
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/admin/users/$id/update', data: data);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _apiClient.post('/admin/users/$id/delete');
  }

  @override
  Future<void> updateUserStatus(String id, String status, {String? institutionId}) async {
    try {
      final Map<String, dynamic> data = {
        'status': status,
      };
      if (institutionId != null) {
        data['institution_id'] = institutionId;
      }
      await _apiClient.post('/admin/users/$id/status', data: data);
    } catch (e) {
      print("Admin Status Update Error: $e");
      rethrow;
    }
  }

  // --- Institution CRUD ---
  @override
  Future<void> createInstitution(Map<String, dynamic> data) async {
    await _apiClient.post('/admin/institutions', data: data);
  }

  @override
  Future<void> updateInstitution(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/admin/institutions/$id/update', data: data);
  }

  @override
  Future<void> deleteInstitution(String id) async {
    await _apiClient.post('/admin/institutions/$id/delete');
  }

  @override
  Future<void> updateInstitutionStatus(String id, String status) async {
    await _apiClient.post('/admin/institutions/$id/status', data: {
      'status': status,
    });
  }

  // --- Subscriptions ---
  @override
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    final response = await _apiClient.get('/admin/subscriptions');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<void> createSubscriptionPlan(Map<String, dynamic> data) async {
    await _apiClient.post('/admin/subscriptions', data: data);
  }

  @override
  Future<void> updateSubscriptionPlan(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/admin/subscriptions/$id/update', data: data);
  }

  @override
  Future<void> deleteSubscriptionPlan(String id) async {
    await _apiClient.post('/admin/subscriptions/$id/delete');
  }

  // --- Settings & Analytics ---
  @override
  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await _apiClient.get('/admin/analytics');
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    final response = await _apiClient.get('/admin/settings');
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {}; // Fallback if backend returns [] or other non-map types
  }

  @override
  Future<void> updateSettings(List<Map<String, dynamic>> settings) async {
    await _apiClient.post('/admin/settings', data: {'settings': settings});
  }

  // --- Courses & Curriculum ---
  @override
  Future<Map<String, dynamic>> getCourses({int page = 1, String? query, String? institutionId}) async {
    final Map<String, dynamic> params = {'page': page};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (institutionId != null) params['institution_id'] = institutionId;
    
    final response = await _apiClient.get('/admin/courses', queryParameters: params);
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> getCourseDetails(String id) async {
    final response = await _apiClient.get('/admin/courses/$id');
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<void> createCourse(Map<String, dynamic> data) async {
    await _apiClient.post('/admin/courses', data: data);
  }

  @override
  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/admin/courses/$id/update', data: data);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _apiClient.post('/admin/courses/$id/delete');
  }

  @override
  Future<void> createSubject(String courseId, Map<String, dynamic> data) async {
    await _apiClient.post('/admin/courses/$courseId/subjects', data: data);
  }

  @override
  Future<void> updateSubject(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/admin/subjects/$id/update', data: data);
  }

  @override
  Future<void> deleteSubject(String id) async {
    await _apiClient.post('/admin/subjects/$id/delete');
  }

  @override
  Future<void> createModule(String subjectId, Map<String, dynamic> data) async {
    await _apiClient.post('/admin/subjects/$subjectId/modules', data: data);
  }

  @override
  Future<void> updateModule(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/admin/modules/$id/update', data: data);
  }

  @override
  Future<void> deleteModule(String id) async {
    await _apiClient.post('/admin/modules/$id/delete');
  }

  @override
  Future<void> createLesson(String moduleId, Map<String, dynamic> data) async {
    await _apiClient.post('/admin/modules/$moduleId/lessons', data: data);
  }

  @override
  Future<void> updateLesson(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/admin/lessons/$id/update', data: data);
  }

  @override
  Future<void> deleteLesson(String id) async {
    await _apiClient.post('/admin/lessons/$id/delete');
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return LaravelAdminRepository(ref.watch(apiClientProvider));
});

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) async {
  return ref.watch(adminRepositoryProvider).getStats();
});

final adminUsersProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (int, String?, String?)>((ref, params) async {
  return ref.watch(adminRepositoryProvider).getUsers(
    page: params.$1,
    query: params.$2,
    role: params.$3,
  );
});

final adminInstitutionsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (int, String?)>((ref, params) async {
  return ref.watch(adminRepositoryProvider).getInstitutions(
    page: params.$1,
    query: params.$2,
  );
});

final adminSubscriptionsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(adminRepositoryProvider).getSubscriptionPlans();
});

final adminAnalyticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(adminRepositoryProvider).getAnalytics();
});

final adminSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(adminRepositoryProvider).getSettings();
});

final adminCoursesProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (int, String?, String?)>((ref, params) async {
  return ref.watch(adminRepositoryProvider).getCourses(
    page: params.$1,
    query: params.$2,
    institutionId: params.$3,
  );
});

final adminCourseDetailsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  return ref.watch(adminRepositoryProvider).getCourseDetails(id);
});



