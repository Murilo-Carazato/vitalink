import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/login_request.dart';
import 'package:vitalink/services/models/register_request.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login com Google cancelado pelo usuário.');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final String? firebaseIdToken = await userCredential.user!.getIdToken();
      if (firebaseIdToken == null) {
        throw Exception('Não foi possível obter o ID token do Firebase.');
      }
      final res = await MyHttpClient.postString(
        url: '/auth/google',
        headers: MyHttpClient.getHeaders(isJson: true),
        body: {'idToken': firebaseIdToken},
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      final errorBody = jsonDecode(res.body);
      throw Exception(errorBody['message'] ?? 'Falha no login com Google');
    } on Exception catch (e) {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(LoginRequest req) async {
    final res = await MyHttpClient.postString(
      url: '/user/login',
      headers: MyHttpClient.getHeaders(isJson: true),
      body: req.toMap(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Login falhou');
  }

  Future<Map<String, dynamic>> register(RegisterRequest req) async {
    final res = await MyHttpClient.postString(
      url: '/user/register',
      headers: MyHttpClient.getHeaders(isJson: true),
      body: req.toMap(),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return jsonDecode(res.body);
    throw Exception('Registro falhou: ${res.reasonPhrase}');
  }

  Future<String> forgotPassword({required String email}) async {
    final res = await MyHttpClient.postString(
      url: '/forgot-password',
      headers: MyHttpClient.getHeaders(isJson: true),
      body: {'email': email},
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['status'];
    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? 'Falha ao enviar o link');
  }

  Future<String> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await MyHttpClient.postString(
      url: '/reset-password',
      headers: MyHttpClient.getHeaders(isJson: true),
      body: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['status'];
    final body = jsonDecode(res.body);
    final errors = body['errors'] as Map<String, dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      throw Exception(errors.values.first.first);
    }
    throw Exception(body['message'] ?? 'Falha ao redefinir a senha');
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
