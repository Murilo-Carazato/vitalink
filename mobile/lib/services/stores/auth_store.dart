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
    final userJson = data.containsKey('user') ? data['user'] : data['data'];
    final serverId = userJson['id'] as int;

    MyHttpClient.setToken(token);

    // 1. Tenta encontrar um usuário local com o mesmo ID do servidor
    final existingUser = await _userRepo.getUserById(serverId);

    if (existingUser != null) {
      // 2. Se o usuário existe, preserva os dados locais e apenas atualiza o token e o nome/email do servidor.
      final updatedUser = existingUser.copyWith(
        token: token,
        name: userJson['name'] ?? existingUser.name, // Garante que o nome esteja sincronizado
        email: userJson['email'] ?? existingUser.email, // Garante que o email esteja sincronizado
      );
      await _userRepo.updateUser(updatedUser);
    } else {
      // 3. Se não existe, cria um novo usuário local com dados padrão
      final newUser = UserModel(
        id: serverId, // ID vem do servidor
        name: userJson['name'] ?? 'Anônimo',
        email: userJson['email'],
        token: token,
        birthDate: '01/01/2000', // Padrão inicial
        bloodType: 'A+', // Padrão inicial
        viewedTutorial: true,
        hasTattoo: false,
        hasMicropigmentation: false,
        hasPermanentMakeup: false,
      );
      await _userRepo.createUser(newUser);
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
    if (e.toString().startsWith('Exception: ')) {
      error = e.toString().substring(11);
    } else {
      error = e.toString();
    }
    _finish();
  }
}
