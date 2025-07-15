import 'package:flutter/material.dart';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/login_request.dart';
import 'package:vitalink/services/models/register_request.dart';
import 'package:vitalink/services/models/user_model.dart';
import 'package:vitalink/services/repositories/api/auth_repository.dart';
import 'package:vitalink/services/repositories/user_repository.dart';

class AuthStore with ChangeNotifier {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  AuthStore(
      {required AuthRepository authRepository,
      required UserRepository userRepository})
      : _authRepo = authRepository,
        _userRepo = userRepository;

  bool isLoading = false;
  String error = '';

  Future<bool> login({required String email, required String password}) async {
    _start();
    try {
      final data =
          await _authRepo.login(LoginRequest(email: email, password: password));

      await _updateLocalUser(data);
      _finish();
      return true;
    } catch (e) {
      _error(e);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? isadmin,
  }) async {
    _start();
    try {
      final data = await _authRepo.register(
        RegisterRequest(
          email: email,
          password: password,
          isadmin: isadmin,
        ),
      );
      await _updateLocalUser(data);
      _finish();
      return true;
    } catch (e, stackTrace) {
      print('error: $e');
      print('stackTrace: $stackTrace');
      _error(e);
      return false;
    }
  }

  Future<void> _updateLocalUser(Map<String, dynamic> data) async {
    final token = data['token'];
    print('token: $token');

    final userJson = data.containsKey('user') ? data['user'] : data['data'];

    MyHttpClient.setToken(token);

    final newUser = UserModel(
      id: userJson['id'],
      name: userJson['name'] ?? 'Anônimo',
      email: userJson['email'],
      token: token,
      birthDate: '01/01/2000',
      bloodType: 'A+',
      viewedTutorial: true,
      hasTattoo: false,
      hasMicropigmentation: false,
      hasPermanentMakeup: false,
    );

    try {
      await _userRepo.clearTable();
      await _userRepo.createUser(newUser);
    } catch (dbError) {
      print('Database error during user update: $dbError');
      final existingUsers = await _userRepo.getUser();
      if (existingUsers.isNotEmpty) {
        final updatedUser = newUser.copyWith(id: existingUsers.first.id);
        await _userRepo.updateUser(updatedUser);
      } else {
        await _userRepo.createUser(newUser);
      }
    }
  }

  // -------------------------------------------------------
  void _start() {
    isLoading = true;
    error = '';
    notifyListeners();
  }

  void _finish() {
    isLoading = false;
    notifyListeners();
  }

  void _error(Object e) {
    error = e.toString();
    _finish();
  }
}
