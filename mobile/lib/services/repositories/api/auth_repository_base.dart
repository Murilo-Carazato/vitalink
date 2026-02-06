import 'package:vitalink/services/models/login_request.dart';
import 'package:vitalink/services/models/register_request.dart';

abstract class IAuthRepository {
  Future<Map<String, dynamic>> loginWithGoogle();
  Future<Map<String, dynamic>> login(LoginRequest req);
  Future<Map<String, dynamic>> register(RegisterRequest req);
  Future<String> forgotPassword({required String email});
  Future<String> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  });
  Future<void> signOut();
}
