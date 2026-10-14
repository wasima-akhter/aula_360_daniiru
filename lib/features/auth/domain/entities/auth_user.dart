import '../../../../utils/enum/app_enum.dart';

class AuthUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;
  final bool isProfileSetup;
  final String? avatarUrl;
  final String? address;
  final String? occupation;
  final String? relationWithChild;
  final String? department;
  final String? designation;
  final String? bio;

  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.isProfileSetup = false,
    this.avatarUrl,
    this.address,
    this.occupation,
    this.relationWithChild,
    this.department,
    this.designation,
    this.bio,
  });

  // Backward compatibility alias for name
  String get name => fullName;

  AuthUser copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    bool? isProfileSetup,
    String? avatarUrl,
    String? address,
    String? occupation,
    String? relationWithChild,
    String? department,
    String? designation,
    String? bio,
  }) {
    return AuthUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isProfileSetup: isProfileSetup ?? this.isProfileSetup,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      relationWithChild: relationWithChild ?? this.relationWithChild,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.isTeacher ? 'TEACHER' : 'PARENT',
      'isProfileSetup': isProfileSetup,
      'avatarUrl': avatarUrl,
      'address': address,
      'occupation': occupation,
      'relationWithChild': relationWithChild,
      'department': department,
      'designation': designation,
      'bio': bio,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] as String? ?? '').toUpperCase();
    final role = roleStr == 'TEACHER' ? UserRole.teacher : UserRole.parent;

    return AuthUser(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: role,
      isProfileSetup: json['isProfileSetup'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      address: json['address'] as String?,
      occupation: json['occupation'] as String?,
      relationWithChild: json['relationWithChild'] as String?,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      bio: json['bio'] as String?,
    );
  }
}
