import 'user_model.dart';

/// Tokens + account returned by a successful `/auth/login` call.
class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        accessToken: json['accessToken']?.toString() ?? '',
        refreshToken: json['refreshToken']?.toString() ?? '',
        user: UserModel.fromJson(
          (json['user'] as Map<String, dynamic>?) ?? const {},
        ),
      );
}
