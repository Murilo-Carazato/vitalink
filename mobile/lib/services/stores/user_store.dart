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

  Future<bool> loadCurrentUser() async {
    isLoading.value = true;
    try {
      final result =
          await (repository as UserRepository).getAuthenticatedUser();

      if (result != null) {
        state.value = [result];
        MyHttpClient.setToken(result.token!);
        return true;
      } else {
        state.value = [];
        MyHttpClient.setToken('');
        return false;
      }
    } on NotFoundException catch (e) {
      erro.value = e.message;
      return false;
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
      // 1. Atualiza o usuário no banco de dados local.
      await repository.updateUser(newUser);

      // 2. Encontra o usuário no estado atual e o atualiza diretamente.
      // Isso é mais seguro do que recarregar tudo do banco.
      final index = state.value.indexWhere((user) => user.id == newUser.id);
      if (index != -1) {
        final updatedList = List<UserModel>.from(state.value);
        updatedList[index] = newUser;
        state.value = updatedList;
      } else {
        // Fallback: se o usuário não estava no estado, recarrega o usuário atual.
        await loadCurrentUser();
      }
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
      if (state.value.isNotEmpty) {
        final currentUser = state.value.first;
        // Limpa o token do usuário atual, mas mantém os outros dados
        final loggedOutUser = currentUser.copyWith(token: '');
        await repository.updateUser(loggedOutUser);
      }

      // Limpar token global do cliente HTTP
      MyHttpClient.setToken('');

      // Zera o estado local para forçar o login na próxima vez
      state.value = [];
    } catch (e) {
      erro.value = e.toString();
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }
}
