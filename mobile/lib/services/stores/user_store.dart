import 'package:flutter/material.dart';
import 'package:vitalink/services/helpers/exceptions.dart';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/user_model.dart';
import 'package:vitalink/services/repositories/user_repository.dart';

class UserStore with ChangeNotifier {
  final IUserRepository repository;
  UserStore({required this.repository});

  ValueNotifier<List<UserModel>> state = ValueNotifier<List<UserModel>>([]);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<String> erro = ValueNotifier<String>('');

  Future getUser() async {
    isLoading.value = true;
    try {
      final result = await repository.getUser();
      state.value = result;

      // Restaura o token do usuário para o cliente HTTP
      if (result.isNotEmpty &&
          result.first.token != null &&
          result.first.token!.isNotEmpty) {
        MyHttpClient.setToken(result.first.token!);
      }
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future createUser({required UserModel user}) async {
    isLoading.value = true;
    try {
      final result = await repository.createUser(user);
      state.value = result;
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future updateUser({required UserModel newUser}) async {
    isLoading.value = true;
    try {
      await repository.updateUser(newUser);
      final result = await repository.getUser();
      state.value = result;
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  // Método auxiliar para pegar o tipo sanguíneo atualizado
  Future<String?> getCurrentBloodType() async {
    final result = await repository.getUser();
    if (result.isNotEmpty) {
      return result.first.bloodType;
    }
    return null;
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      // Obter usuário atual
      final currentUser = state.value.first;

      // Criar cópia sem token
      final loggedOutUser = currentUser.copyWith(token: '');

      // Atualizar no banco
      await repository.updateUser(loggedOutUser);

      // Limpar token global
      MyHttpClient.setToken('');

      // Recarregar usuário
      final result = await repository.getUser();
      state.value = result;
    } catch (e) {
      erro.value = e.toString();
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }
}
