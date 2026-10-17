/// ============================================================================
/// PASSWORD RECOVERY DTOS & ARGUMENTS
/// ============================================================================
/// Models matching /api/v1/recover/* endpoints defined in reset_password.txt
library;

class RecoverUserData {
  final String fullName;
  final String email;
  final String role;
  final String status;
  final String? avatar;
  final String token;

  const RecoverUserData({
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    this.avatar,
    required this.token,
  });

  factory RecoverUserData.fromJson(Map<String, dynamic> json) {
    return RecoverUserData(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      avatar: json['avatar'] as String?,
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'status': status,
      if (avatar != null) 'avatar': avatar,
      'token': token,
    };
  }
}

class ResetPasswordArgs {
  final String? email;
  final String? token;

  const ResetPasswordArgs({this.email, this.token});
}
