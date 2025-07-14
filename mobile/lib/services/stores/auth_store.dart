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
      // 1. Autenticar no backend (receber apenas token)
      final data =
          await _authRepo.login(LoginRequest(email: email, password: password));
      final token = data['token'];

      MyHttpClient.setToken(token);

      // 2. Obter dados do usuário da resposta
      final userJson = data['user'];

      // 3. Criar novo usuário local com valores válidos para campos obrigatórios
      final newUser = UserModel(
        id: userJson['id'],
        name: userJson['name'] ?? 'Anônimo',
        email: userJson['email'],
        token: token,
        // Valores válidos para campos obrigatórios no SQLite
        birthDate: '01/01/2000',
        bloodType: 'A+',
        viewedTutorial: true,
        hasTattoo: false,
        hasMicropigmentation: false,
        hasPermanentMakeup: false,
      );

      // 4. Limpar tabela e salvar novo usuário
      try {
        await _userRepo.clearTable();
        await _userRepo.createUser(newUser);
      } catch (dbError) {
        // Log do erro e tentativa de recuperação
        print('Database error during login: $dbError');
        // Tenta uma abordagem alternativa - criar o usuário sem limpar a tabela
        try {
          final existingUsers = await _userRepo.getUser();
          if (existingUsers.isNotEmpty) {
            // Atualiza o usuário existente em vez de criar um novo
            // Usa copyWith para criar uma nova instância com o ID existente
            final updatedUser = newUser.copyWith(id: existingUsers.first.id);
            await _userRepo.updateUser(updatedUser);
          } else {
            await _userRepo.createUser(newUser);
          }
        } catch (finalError) {
          throw Exception('Falha ao salvar dados do usuário: $finalError');
        }
      }

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
      // 1. Registrar no backend (receber token e id)
      final data = await _authRepo.register(
        RegisterRequest(
          email: email,
          password: password,
          isadmin: isadmin,
        ),
      );

      // 2. Salvar token para uso imediato
      final token = data['token'];
      if (token != null) {
        MyHttpClient.setToken(token);
      }

      // 3. Criar usuário local com dados do registro e valores válidos para campos obrigatórios
      final userJson = data['data'];
      final user = UserModel(
        id: userJson['id'],
        name: userJson['name'] ?? 'Anônimo',
        email: userJson['email'],
        token: token,
        // Valores válidos para campos obrigatórios no SQLite
        birthDate: '01/01/2000',
        bloodType: 'A+',
        viewedTutorial: true,
        hasTattoo: false,
        hasMicropigmentation: false,
        hasPermanentMakeup: false,
      );

      // 4. Limpar tabela e salvar novo usuário com tratamento de erros
      try {
        await _userRepo.clearTable();
        await _userRepo.createUser(user);
      } catch (dbError) {
        print('Database error during registration: $dbError');
        // Tenta uma abordagem alternativa - criar o usuário sem limpar a tabela
        try {
          final existingUsers = await _userRepo.getUser();
          if (existingUsers.isNotEmpty) {
            // Atualiza o usuário existente em vez de criar um novo
            // Usa copyWith para criar uma nova instância com o ID existente
            final updatedUser = user.copyWith(id: existingUsers.first.id);
            await _userRepo.updateUser(updatedUser);
          } else {
            await _userRepo.createUser(user);
          }
        } catch (finalError) {
          throw Exception('Falha ao salvar dados do usuário: $finalError');
        }
      }

      _finish();
      return true;
    } catch (e) {
      _error(e);
      return false;
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
