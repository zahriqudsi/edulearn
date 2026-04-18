import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/core/network/api_client.dart';
import 'package:edulearn/models/course_model.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<List<String>> getCategories();
  Future<List<String>> getLevels();
  Future<Course> getCourseDetails(String id);
  Future<List<dynamic>> getCourseReviews(String id);
  Future<void> addReview(String id, double rating, String comment);
  Future<void> enroll(String courseId, String userId);
  Future<void> toggleLessonCompletion(String lessonId, bool isCompleted);
}

class LaravelCourseRepository implements CourseRepository {
  final ApiClient _apiClient;

  LaravelCourseRepository(this._apiClient);

  @override
  Future<List<Course>> getCourses() async {
    final response = await _apiClient.get('/courses');
    final list = List<Map<String, dynamic>>.from(response.data);
    return list.map((c) => Course.fromJson(c)).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await _apiClient.get('/categories');
    return List<String>.from(response.data);
  }

  @override
  Future<List<String>> getLevels() async {
    final response = await _apiClient.get('/levels');
    return List<String>.from(response.data);
  }

  @override
  Future<Course> getCourseDetails(String id) async {
    final response = await _apiClient.get('/courses/$id');
    return Course.fromJson(response.data);
  }

  @override
  Future<List<dynamic>> getCourseReviews(String id) async {
    final response = await _apiClient.get('/courses/$id/reviews');
    return response.data as List;
  }

  @override
  Future<void> addReview(String id, double rating, String comment) async {
    await _apiClient.post(
      '/courses/$id/reviews',
      data: {'rating': rating, 'comment': comment},
    );
  }

  @override
  Future<void> enroll(String courseId, String userId) async {
    await _apiClient.post(
      '/student/enroll',
      data: {'course_id': courseId, 'user_id': userId},
    );
  }

  @override
  Future<void> toggleLessonCompletion(String lessonId, bool isCompleted) async {
    await _apiClient.post(
      '/lessons/$lessonId/complete',
      data: {'is_completed': isCompleted},
    );
  }
}

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return LaravelCourseRepository(ref.watch(apiClientProvider));
});

final coursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  return ref.watch(courseRepositoryProvider).getCourses();
});

final categoriesProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  return ref.watch(courseRepositoryProvider).getCategories();
});

final levelsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  return ref.watch(courseRepositoryProvider).getLevels();
});

final courseDetailsProvider = FutureProvider.autoDispose.family<Course, String>(
  (ref, id) async {
    return ref.watch(courseRepositoryProvider).getCourseDetails(id);
  },
);
