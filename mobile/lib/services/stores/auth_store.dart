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
        print('Logging out user ${currentUser.id}');
        final loggedOutUser = currentUser.copyWith(token: '');
        await userRepo.updateUser(loggedOutUser);
      }
    }
    
    // Limpa o token no HttpClient
    MyHttpClient.clearToken();
    
    print('User logged out successfully');
    
    // Notifica os ouvintes para atualizar a UI
    notifyListeners();
  }

  Future<void> _updateLocalUser(Map<String, dynamic> data) async {
    final token = data['token'];
    final userJson = data.containsKey('user') ? data['user'] : data['data'];
    final serverId = userJson['id'] as int;

    // Definir o token no HttpClient para uso imediato nas requisições
    MyHttpClient.setToken(token);
    print('Token set in HTTP client: ${token.substring(0, 10)}...');

    // 1. Tenta encontrar um usuário local com o mesmo ID do servidor
    final existingUser = await _userRepo.getUserById(serverId);

    if (existingUser != null) {
      // 2. Se o usuário existe, preserva os dados locais e apenas atualiza o token e o nome/email do servidor.
      final updatedUser = existingUser.copyWith(
        token: token,
        name: userJson['name'] ?? existingUser.name, 
        email: userJson['email'] ?? existingUser.email, 
        bloodType: userJson['blood_type'] ?? existingUser.bloodType,
        birthDate: userJson['birth_date'] ?? existingUser.birthDate,
      );
      
      print('AUTH STORE DEBUG: Backend Blood Type: "${userJson['blood_type']}"');
      print('AUTH STORE DEBUG: Existing Local Blood Type: "${existingUser.bloodType}"');
      print('Updating existing user with token and syncing data from backend');
      await _userRepo.updateUser(updatedUser);
    } else {
      // 3. Se não existe, cria um novo usuário local com dados do servidor ou padrão
      final newUser = UserModel(
        id: serverId, // ID vem do servidor
        name: userJson['name'] ?? 'Anônimo',
        email: userJson['email'],
        token: token,
        birthDate: userJson['birth_date'] ?? '01/01/2000', 
        bloodType: userJson['blood_type'] ?? 'A+', 
        viewedTutorial: true,
        hasTattoo: false,
        hasMicropigmentation: false,
        hasPermanentMakeup: false,
      );
      
      print('Creating new user with token');
      await _userRepo.createUser(newUser);
    }
    
    // Verificar se o token foi realmente salvo
    final verifyUser = await _userRepo.getAuthenticatedUser();
    if (verifyUser != null && verifyUser.token == token) {
      print('Token successfully verified in database');
    } else {
      print('WARNING: Token verification failed!');
    }
  }

  /// Valida o token atual com o backend.
  /// Se o token for inválido (401), realiza o logout forçado.
  /// Retorna true se o token for válido ou se não foi possível validar (offline).
  /// Retorna false se o token for inválido e o usuário foi deslogado.
  Future<bool> validateSession() async {
    final currentUser = await _userRepo.getAuthenticatedUser();
    if (currentUser == null || currentUser.token == null || currentUser.token!.isEmpty) {
      return false; // Sem sessão
    }

    try {
      print('Validating session token...');
      final response = await MyHttpClient.get(
        url: '/user',
        headers: MyHttpClient.getHeaders(token: currentUser.token!),
      );

      if (response.statusCode == 401) {
        print('Session invalid (401). Forcing logout.');
        await signOut(); // Reutiliza o método signOut existente para limpar tudo
        return false;
      } else if (response.statusCode == 200) {
        print('Session valid.');
        return true;
      } else {
        print('Session validation returned: ${response.statusCode}. Assuming valid (offline/server error).');
        return true;
      }
    } catch (e) {
      print('Error validating session: $e. Assuming valid (network issue).');
      return true;
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
