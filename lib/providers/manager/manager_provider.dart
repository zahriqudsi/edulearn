import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/core/network/api_client.dart';

class ManagerStats {
  final int totalStudents;
  final int totalTeachers;
  final int totalCourses;
  final int upcomingSchedules;

  ManagerStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalCourses,
    required this.upcomingSchedules,
  });

  factory ManagerStats.fromJson(Map<String, dynamic> json) {
    return ManagerStats(
      totalStudents: json['total_students'] ?? 0,
      totalTeachers: json['total_teachers'] ?? 0,
      totalCourses: json['total_courses'] ?? 0,
      upcomingSchedules: json['upcoming_schedules'] ?? 0,
    );
  }
}

abstract class ManagerRepository {
  Future<ManagerStats> getStats();

  // Users
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    String? query,
    String? role,
  });
  Future<void> createUser(Map<String, dynamic> data);
  Future<void> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);

  // Courses
  Future<Map<String, dynamic>> getCourses({int page = 1, String? query});
  Future<void> createCourse(Map<String, dynamic> data);
  Future<void> updateCourse(String id, Map<String, dynamic> data);
  Future<void> deleteCourse(String id);

  // Enrolments
  Future<Map<String, dynamic>> getEnrollments({int page = 1});
  Future<void> enrollStudent(Map<String, dynamic> data);
  Future<void> unenrollStudent(String id);

  // Schedules / Timetable
  Future<List<Map<String, dynamic>>> getSchedules();
  Future<void> createSchedule(Map<String, dynamic> data);
  Future<void> deleteSchedule(String id);

  // Institution Settings
  Future<Map<String, dynamic>> getInstitution();
  Future<void> updateInstitution(Map<String, dynamic> data);

  // Curriculum Management
  Future<Map<String, dynamic>> getCourseDetails(String id);
  Future<void> createSubject(String courseId, Map<String, dynamic> data);
  Future<void> updateSubject(String id, Map<String, dynamic> data);
  Future<void> deleteSubject(String id);
  Future<void> createModule(String subjectId, Map<String, dynamic> data);
  Future<void> updateModule(String id, Map<String, dynamic> data);
  Future<void> deleteModule(String id);
  Future<void> createLesson(String moduleId, Map<String, dynamic> data);
  Future<void> updateLesson(String id, Map<String, dynamic> data);
  Future<void> deleteLesson(String id);

  // Announcements
  Future<List<dynamic>> getAnnouncements();
  Future<void> postAnnouncement(Map<String, dynamic> data);
}

class LaravelManagerRepository implements ManagerRepository {
  final ApiClient _apiClient;

  LaravelManagerRepository(this._apiClient);

  @override
  Future<ManagerStats> getStats() async {
    final response = await _apiClient.get('/manager/stats');
    return ManagerStats.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    String? query,
    String? role,
  }) async {
    final Map<String, dynamic> params = {'page': page};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (role != null) params['role'] = role;

    final response = await _apiClient.get(
      '/manager/users',
      queryParameters: params,
    );
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> getCourses({int page = 1, String? query}) async {
    final Map<String, dynamic> params = {'page': page};
    if (query != null && query.isNotEmpty) params['q'] = query;

    final response = await _apiClient.get(
      '/manager/courses',
      queryParameters: params,
    );
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<void> createUser(Map<String, dynamic> data) async {
    await _apiClient.post('/manager/users', data: data);
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/manager/users/$id/update', data: data);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _apiClient.post('/manager/users/$id/delete');
  }

  @override
  Future<void> createCourse(Map<String, dynamic> data) async {
    await _apiClient.post('/manager/courses', data: data);
  }

  @override
  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/manager/courses/$id/update', data: data);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _apiClient.post('/manager/courses/$id/delete');
  }

  @override
  Future<Map<String, dynamic>> getEnrollments({int page = 1}) async {
    final response = await _apiClient.get(
      '/manager/enrollments',
      queryParameters: {'page': page},
    );
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<void> enrollStudent(Map<String, dynamic> data) async {
    await _apiClient.post('/manager/enrollments', data: data);
  }

  @override
  Future<void> unenrollStudent(String id) async {
    await _apiClient.post('/manager/enrollments/$id/delete');
  }

  @override
  Future<List<Map<String, dynamic>>> getSchedules() async {
    final response = await _apiClient.get('/manager/schedules');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<void> createSchedule(Map<String, dynamic> data) async {
    await _apiClient.post('/manager/schedules', data: data);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await _apiClient.post('/manager/schedules/$id/delete');
  }

  @override
  Future<Map<String, dynamic>> getInstitution() async {
    final response = await _apiClient.get('/manager/institution');
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<void> updateInstitution(Map<String, dynamic> data) async {
    await _apiClient.post('/manager/institution/update', data: data);
  }

  // Curriculum Management
  @override
  Future<Map<String, dynamic>> getCourseDetails(String id) async {
    try {
      final response = await _apiClient.get('/manager/courses/$id');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      if (e.toString().contains('404')) {
        throw 'Course details route not found (404). Please ensure the backend route [GET /api/manager/courses/$id] is registered.';
      }
      rethrow;
    }
  }

  @override
  Future<void> createSubject(String courseId, Map<String, dynamic> data) async {
    await _apiClient.post('/manager/courses/$courseId/subjects', data: data);
  }

  @override
  Future<void> updateSubject(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/manager/subjects/$id/update', data: data);
  }

  @override
  Future<void> deleteSubject(String id) async {
    await _apiClient.post('/manager/subjects/$id/delete');
  }

  @override
  Future<void> createModule(String subjectId, Map<String, dynamic> data) async {
    await _apiClient.post('/manager/subjects/$subjectId/modules', data: data);
  }

  @override
  Future<void> updateModule(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/manager/modules/$id/update', data: data);
  }

  @override
  Future<void> deleteModule(String id) async {
    await _apiClient.post('/manager/modules/$id/delete');
  }

  @override
  Future<void> createLesson(String moduleId, Map<String, dynamic> data) async {
    await _apiClient.post('/manager/modules/$moduleId/lessons', data: data);
  }

  @override
  Future<void> updateLesson(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/manager/lessons/$id/update', data: data);
  }

  @override
  Future<void> deleteLesson(String id) async {
    await _apiClient.post('/manager/lessons/$id/delete');
  }

  @override
  Future<List<dynamic>> getAnnouncements() async {
    final response = await _apiClient.get('/announcements');
    return response.data as List;
  }

  @override
  Future<void> postAnnouncement(Map<String, dynamic> data) async {
    await _apiClient.post('/announcements', data: data);
  }
}

final managerRepositoryProvider = Provider<ManagerRepository>((ref) {
  return LaravelManagerRepository(ref.watch(apiClientProvider));
});

final managerStatsProvider = FutureProvider.autoDispose<ManagerStats>((
  ref,
) async {
  return ref.watch(managerRepositoryProvider).getStats();
});

final managerUsersProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (int, String?, String?)>((ref, params) async {
      return ref
          .watch(managerRepositoryProvider)
          .getUsers(page: params.$1, query: params.$2, role: params.$3);
    });

final managerCoursesProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (int, String?)>((ref, params) async {
      return ref
          .watch(managerRepositoryProvider)
          .getCourses(page: params.$1, query: params.$2);
    });

final managerEnrollmentsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, page) async {
      return ref.watch(managerRepositoryProvider).getEnrollments(page: page);
    });

final managerSchedulesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      return ref.watch(managerRepositoryProvider).getSchedules();
    });

final managerInstitutionProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      return ref.watch(managerRepositoryProvider).getInstitution();
    });

final managerCourseDetailsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      return ref.watch(managerRepositoryProvider).getCourseDetails(id);
    });

final managerAnnouncementsProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
      return ref.watch(managerRepositoryProvider).getAnnouncements();
    });
