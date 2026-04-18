import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/core/network/api_client.dart';

abstract class TeacherRepository {
  Future<void> uploadMaterial(String courseId, String title, String type, String fileUrl);
  Future<void> scheduleSession(String courseId, String title, DateTime startTime, {bool isRecurring = false, int? dayOfWeek, String? recordingUrl});
  Future<void> postAnnouncement(String title, String message, String targetRole);
  Future<Map<String, dynamic>> getDashboardData();
  
  // Hierarchical management
  Future<void> createSubject(String courseId, Map<String, dynamic> data);
  Future<void> updateSubject(String id, Map<String, dynamic> data);
  Future<void> deleteSubject(String id);
  
  Future<void> createModule(String subjectId, Map<String, dynamic> data);
  Future<void> updateModule(String id, Map<String, dynamic> data);
  Future<void> deleteModule(String id);
  
  Future<void> createLesson(String moduleId, Map<String, dynamic> data);
  Future<void> updateLesson(String id, Map<String, dynamic> data);
  Future<void> deleteLesson(String id);
  
  Future<List<dynamic>> getCourses();
  Future<void> createCourse(Map<String, dynamic> data);
  Future<void> updateCourse(String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> getCourseDetails(String id);
  Future<void> deleteCourse(String id);

  Future<List<dynamic>> getEnrollments();
  Future<List<dynamic>> getHistory();
}

class LaravelTeacherRepository implements TeacherRepository {
  final ApiClient _apiClient;

  LaravelTeacherRepository(this._apiClient);

  @override
  Future<void> uploadMaterial(String courseId, String title, String type, String fileUrl) async {
    await _apiClient.post('/teacher/courses/$courseId/materials', data: {
      'title': title,
      'type': type,
      'file_url': fileUrl,
    });
  }

  @override
  Future<void> scheduleSession(String courseId, String title, DateTime startTime, {bool isRecurring = false, int? dayOfWeek, String? recordingUrl}) async {
    await _apiClient.post('/teacher/courses/$courseId/classes', data: {
      'title': title,
      'start_time': startTime.toIso8601String(),
      'is_recurring': isRecurring,
      'day_of_week': dayOfWeek,
      'recording_url': recordingUrl,
    });
  }

  @override
  Future<void> postAnnouncement(String title, String message, String targetRole) async {
    await _apiClient.post('/announcements', data: {
      'title': title,
      'message': message,
      'target_role': targetRole,
    });
  }

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await _apiClient.get('/teacher/dashboard');
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<void> createSubject(String courseId, Map<String, dynamic> data) async {
    await _apiClient.post('/teacher/courses/$courseId/subjects', data: data);
  }

  @override
  Future<void> updateSubject(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/teacher/subjects/$id/update', data: data);
  }

  @override
  Future<void> deleteSubject(String id) async {
    await _apiClient.post('/teacher/subjects/$id/delete');
  }

  @override
  Future<void> createModule(String subjectId, Map<String, dynamic> data) async {
    await _apiClient.post('/teacher/subjects/$subjectId/modules', data: data);
  }

  @override
  Future<void> updateModule(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/teacher/modules/$id/update', data: data);
  }

  @override
  Future<void> deleteModule(String id) async {
    await _apiClient.post('/teacher/modules/$id/delete');
  }

  @override
  Future<void> createLesson(String moduleId, Map<String, dynamic> data) async {
    await _apiClient.post('/teacher/modules/$moduleId/lessons', data: data);
  }

  @override
  Future<void> updateLesson(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/teacher/lessons/$id/update', data: data);
  }

  @override
  Future<void> deleteLesson(String id) async {
    await _apiClient.post('/teacher/lessons/$id/delete');
  }

  @override
  Future<List<dynamic>> getEnrollments() async {
    final response = await _apiClient.get('/teacher/enrollments');
    return response.data as List;
  }

  @override
  Future<List<dynamic>> getHistory() async {
    final response = await _apiClient.get('/teacher/history');
    return response.data as List;
  }

  @override
  Future<List<dynamic>> getCourses() async {
    final response = await _apiClient.get('/teacher/courses');
    return response.data as List;
  }

  @override
  Future<void> createCourse(Map<String, dynamic> data) async {
    await _apiClient.post('/teacher/courses', data: data);
  }

  @override
  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    await _apiClient.post('/teacher/courses/$id/update', data: data);
  }

  @override
  Future<Map<String, dynamic>> getCourseDetails(String id) async {
    final response = await _apiClient.get('/courses/$id');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _apiClient.post('/teacher/courses/$id/delete');
  }
}

final teacherDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(teacherRepositoryProvider).getDashboardData();
});

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return LaravelTeacherRepository(ref.watch(apiClientProvider));
});

final teacherEnrollmentsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) {
  return ref.watch(teacherRepositoryProvider).getEnrollments();
});

final teacherHistoryProvider = FutureProvider.autoDispose<List<dynamic>>((ref) {
  return ref.watch(teacherRepositoryProvider).getHistory();
});

final teacherCoursesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) {
  return ref.watch(teacherRepositoryProvider).getCourses();
});

final teacherCourseDetailsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) {
  return ref.watch(teacherRepositoryProvider).getCourseDetails(id);
});



