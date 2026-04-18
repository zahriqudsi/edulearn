class Course {
  final String id;
  final String name;
  final String description;
  final String instructorId;
  final String? category;
  final String? level;
  final String? thumbnail;
  final double progress;
  final List<Subject> subjects;
  final List<CourseMaterial> materials;
  final List<LiveClass> liveClasses;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.instructorId,
    this.category,
    this.level,
    this.thumbnail,
    this.progress = 0.0,
    this.subjects = const [],
    this.materials = const [],
    this.liveClasses = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      name: json['title'] ?? 'Untitled Course',
      description: json['description'] ?? '',
      instructorId: json['instructor_id']?.toString() ?? '',
      category: json['category'],
      level: json['level'],
      thumbnail: json['thumbnail_url'],
      progress: (json['progress'] ?? 0.0).toDouble() / 100.0,
      subjects: json['subjects'] != null 
          ? (json['subjects'] as List).map((s) => Subject.fromJson(s)).toList() 
          : [],
      materials: json['materials'] != null 
          ? (json['materials'] as List).map((m) => CourseMaterial.fromJson(m)).toList() 
          : [],
      liveClasses: json['live_classes'] != null 
          ? (json['live_classes'] as List).map((lc) => LiveClass.fromJson(lc)).toList() 
          : [],
    );
  }
}

class Subject {
  final String id;
  final String title;
  final List<Module> modules;

  Subject({required this.id, required this.title, this.modules = const []});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled Subject',
      modules: json['modules'] != null 
          ? (json['modules'] as List).map((m) => Module.fromJson(m)).toList() 
          : [],
    );
  }
}

class Module {
  final String id;
  final String title;
  final List<Lesson> lessons;

  Module({required this.id, required this.title, this.lessons = const []});

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled Module',
      lessons: json['lessons'] != null 
          ? (json['lessons'] as List).map((l) => Lesson.fromJson(l)).toList() 
          : [],
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String type; // 'video', 'file', 'live'
  final String? contentUrl;
  final int? durationMinutes;
  final bool isCompleted;

  Lesson({
    required this.id, 
    required this.title, 
    required this.type, 
    this.contentUrl, 
    this.durationMinutes,
    this.isCompleted = false
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled Lesson',
      type: json['content_type'] ?? 'file',
      contentUrl: json['file_url'],
      durationMinutes: json['duration_minutes'],
      isCompleted: json['is_completed'] == true,
    );
  }
}

class LiveClass {
  final String id;
  final String title;
  final DateTime? startTime;
  final String? meetingLink;
  final String? recordingUrl;

  LiveClass({
    required this.id,
    required this.title,
    this.startTime,
    this.meetingLink,
    this.recordingUrl,
  });

  factory LiveClass.fromJson(Map<String, dynamic> json) {
    return LiveClass(
      id: json['id'].toString(),
      title: json['title'] ?? 'Live Session',
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      meetingLink: json['meeting_link'],
      recordingUrl: json['recording_url'],
    );
  }
}

class CourseMaterial {
  final String id;
  final String title;
  final String type;
  final String fileUrl;

  CourseMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.fileUrl,
  });

  factory CourseMaterial.fromJson(Map<String, dynamic> json) {
    return CourseMaterial(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitied Material',
      type: json['type'] ?? 'document',
      fileUrl: json['file_url'] ?? '',
    );
  }
}



