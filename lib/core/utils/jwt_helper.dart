import 'package:jwt_decode/jwt_decode.dart';

class JwtHelper {
  /// Strips potential 'Bearer ' prefix and whitespace from a JWT token.
  static String? cleanToken(String? token) {
    if (token == null) return null;
    var trimmed = token.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.toLowerCase().startsWith('bearer ')) {
      trimmed = trimmed.substring(7).trim();
    }
    return trimmed.isNotEmpty ? trimmed : null;
  }

  /// Decodes JWT payload and extracts the email claim if present.
  static String? extractEmail(String? token) {
    final cleaned = cleanToken(token);
    if (cleaned == null) return null;
    try {
      final payload = Jwt.parseJwt(cleaned);
      final email = payload['email'] ??
          payload['userEmail'] ??
          payload['user_email'] ??
          payload['emailAddress'] ??
          payload['mail'];
      if (email is String && email.trim().isNotEmpty) {
        return email.trim();
      }
      final sub = payload['sub'];
      if (sub is String && sub.contains('@')) {
        return sub.trim();
      }
      final identity = payload['identity'];
      if (identity is String && identity.contains('@')) {
        return identity.trim();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Safely decodes a JWT token into its payload Map, returning null if invalid.
  static Map<String, dynamic>? decode(String? token) {
    final cleaned = cleanToken(token);
    if (cleaned == null) return null;
    try {
      return Jwt.parseJwt(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Extracts user role claim from JWT payload.
  static String? extractRole(String? token) {
    final payload = decode(token);
    if (payload == null) return null;
    final role = payload['role'] ?? payload['userRole'];
    return role is String ? role.trim() : null;
  }

  /// Extracts user id from JWT payload.
  static String? extractUserId(String? token) {
    final payload = decode(token);
    if (payload == null) return null;
    final id = payload['id'] ?? payload['userId'] ?? payload['sub'];
    return id is String ? id.trim() : null;
  }
}

