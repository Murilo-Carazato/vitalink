import 'package:flutter/material.dart';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/login_request.dart';
import 'package:vitalink/services/models/register_request.dart';
import 'package:vitalink/services/models/user_model.dart';
import 'package:vitalink/services/repositories/api/auth_repository.dart';
import 'package:vitalink/services/repositories/user_repository.dart';
import 'dart:convert';

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

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    _start();
    try {
      final data =
          await _authRepo.login(LoginRequest(email: email, password: password));

      await _updateLocalUser(data);
      _finish();
      return {
        'success': true,
        'email_verified': true,
      };
    } catch (e) {
      _error(e);
      
      // Verificar se o erro é de email não verificado
      if (e.toString().contains('verifique seu email') || 
          e.toString().contains('email verification')) {
        return {
          'success': false,
          'email_verified': false,
          'email': email,
        };
      }
      
      return {
        'success': false,
        'email_verified': true,
      };
    }
  }

  Future<Map<String, dynamic>> checkEmailVerificationStatus({required String email}) async {
    try {
      // Faz uma requisição para verificar o status de verificação do email
      final response = await MyHttpClient.get(
        url: '/user/check-verification-status?email=$email',
        headers: MyHttpClient.getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'email_verified': data['email_verified'] ?? false,
        };
      } else {
        return {
          'success': false,
          'email_verified': false,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'email_verified': false,
      };
    }
  }

  Future<Map<String, dynamic>> register({
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
      
      // No caso de registro bem-sucedido, considere que o usuário precisa verificar o email
      return {
        'success': true,
        'email_verified': false,
        'email': email,
      };
    } catch (e, stackTrace) {
      print('error: $e');
      print('stackTrace: $stackTrace');
      _error(e);
      return {
        'success': false,
        'email_verified': true,
      };
    }
  }

  Future<bool> loginWithGoogle() async {
    _start();
    try {
      final data = await _authRepo.loginWithGoogle();
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

  Future<bool> forgotPassword({required String email}) async {
    _start();
    try {
      await _authRepo.forgotPassword(email: email);
      _finish();
      return true;
    } catch (e) {
      _error(e);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _start();
    try {
      await _authRepo.resetPassword(
        token: token,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _finish();
      return true;
    } catch (e) {
      _error(e);
      return false;
    }
  }

  Future<void> signOut() async {
    // Adiciona o logout do Firebase/Google
    await _authRepo.signOut();
    
    // Mantém a lógica de limpeza do usuário local
    if (_userRepo is UserRepository) {
      final userRepo = _userRepo as UserRepository;
      final currentUser = await userRepo.getAuthenticatedUser();
      if (currentUser != null) {
        final loggedOutUser = currentUser.copyWith(token: '');
        await userRepo.updateUser(loggedOutUser);
      }
    }
    MyHttpClient.setToken('');
    // Notifica os ouvintes para atualizar a UI
    notifyListeners();
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
