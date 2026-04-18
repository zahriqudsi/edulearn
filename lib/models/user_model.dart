enum UserRole { student, teacher, admin, manager }

class EduUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImage;
  final String? bio;
  final String? phoneNumber;
  final String? address;
  final DateTime? emailVerifiedAt;
  final String? institutionId;

  EduUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.bio,
    this.phoneNumber,
    this.address,
    this.emailVerifiedAt,
    this.institutionId,
  });

  factory EduUser.fromJson(Map<String, dynamic> json) {
    // Robust role parsing: handle case-insensitive strings from API
    final roleStr = (json['role'] ?? 'student').toString().toLowerCase();
    
    UserRole parsedRole;
    if (roleStr.contains('admin')) {
      parsedRole = UserRole.admin;
    } else if (roleStr.contains('manager')) {
      parsedRole = UserRole.manager;
    } else if (roleStr.contains('teacher')) {
      parsedRole = UserRole.teacher;
    } else {
      parsedRole = UserRole.student;
    }

    final verifiedAt = json['email_verified_at'];

    return EduUser(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: parsedRole,
      profileImage: json['avatar_url'] ?? json['profile_image_url'],
      bio: json['bio'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      emailVerifiedAt: verifiedAt != null ? DateTime.parse(verifiedAt) : null,
      institutionId: json['institution_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
    'bio': bio,
    'phone_number': phoneNumber,
    'address': address,
    'email_verified_at': emailVerifiedAt?.toIso8601String(),
    'institution_id': institutionId,
  };
}
