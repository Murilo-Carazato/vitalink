import 'package:flutter/material.dart';
import 'package:vitalink/services/helpers/exceptions.dart';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/user_model.dart';
import 'package:vitalink/services/repositories/user_repository.dart';
import 'package:vitalink/services/stores/auth_store.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class UserStore with ChangeNotifier {
  final IUserRepository repository;
  UserStore({required this.repository});

  ValueNotifier<List<UserModel>> state = ValueNotifier<List<UserModel>>([]);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<String> erro = ValueNotifier<String>('');

  Future<bool> loadCurrentUser() async {
    isLoading.value = true;
    try {
      // Tenta buscar o usuário autenticado do banco de dados local
      final result = await (repository as UserRepository).getAuthenticatedUser();

      if (result != null) {
        // Se encontrou um usuário autenticado
        state.value = [result];
        
        // Configura o token para uso nas requisições
        if (result.token != null && result.token!.isNotEmpty) {
          MyHttpClient.setToken(result.token!);
          print('Token loaded and set from database: ${result.token!.substring(0, 10)}...');
          
          // Ensure subscription to blood type topic and clean up others
          if (result.bloodType != null) {
            String currentTopic = convertBloodType(result.bloodType!);
            
            // Subscribe to current
            subscribeToBloodTypeTopic(result.bloodType!);
            
            // Clean up potentially stale subscriptions (Zombie subscriptions from previous bugs)
            List<String> allTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
            for (var type in allTypes) {
              if (type != result.bloodType) {
                // We don't await this to speed up startup, just fire and forget
                unsubscribeFromBloodTypeTopic(type); 
              }
            }
          }
           // Subscribe to general topic
           await FirebaseMessaging.instance.subscribeToTopic('general');
          return true;
        }
      }
      
      // Nenhum usuário autenticado encontrado ou token inválido
      state.value = [];
      MyHttpClient.setToken('');
      print('No valid token found, user will need to login');
      return false;
    } on Exception catch (e) {
      print('Error loading current user: $e');
      erro.value = e.toString();
      state.value = [];
      MyHttpClient.setToken('');
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
        // Let's grab the old user from current state
        final oldUser = state.value[index];
        print('UPDATE PROFILE DEBUG:');
        print('Old Blood Type: ${oldUser.bloodType}');
        print('New Blood Type: ${newUser.bloodType}');
        
        // Update state locally
        final updatedList = List<UserModel>.from(state.value);
        updatedList[index] = newUser;
        state.value = updatedList;

        if (oldUser.bloodType != newUser.bloodType) {
          print('Blood type changed! Processing subscriptions...');
          if (oldUser.bloodType != null) {
            print('Unsubscribing from old: ${oldUser.bloodType}');
            await unsubscribeFromBloodTypeTopic(oldUser.bloodType!);
          }
          if (newUser.bloodType != null) {
             print('Subscribing to new: ${newUser.bloodType}');
            await subscribeToBloodTypeTopic(newUser.bloodType!);
          }
        } else {
             print('Blood type DID NOT change. Skipping subscription updates.');
        }
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

  Future<void> logout(AuthStore authStore) async {
    isLoading.value = true;
    try {
      // Unsubscribe from topic before logging out
      if (state.value.isNotEmpty && state.value.first.bloodType != null) {
         await unsubscribeFromBloodTypeTopic(state.value.first.bloodType!);
      }

      await authStore.signOut(); // Usa o método centralizado do AuthStore
      state.value = []; // Limpa o estado local
    } catch (e) {
      erro.value = e.toString();
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  // --- Firebase Topic Subscription Logic ---

  Future<void> subscribeToBloodTypeTopic(String bloodType) async {
    try {
      // Topics are not supported on Web
      // We can check kIsWeb from 'package:flutter/foundation.dart' but we need to import it.
      // Assuming kIsWeb is available or handled by the plugin gracefully (it usually is).
      // However, to be safe and consistent with main.dart:
      // Note: We need to import kIsWeb or just ignore if not web. 
      // Checking conditional imports might be tricky here without seeing imports, 
      // so we rely on run-time check if possible or strict catch.
      
      final topic = convertBloodType(bloodType);
      if (topic.isNotEmpty) {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromBloodTypeTopic(String bloodType) async {
    try {
      final topic = convertBloodType(bloodType);
      if (topic.isNotEmpty) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  String convertBloodType(String type) {
    print('Converting blood type: "$type"');
    switch (type) {
      case 'A+':
        return 'positiveA';
      case 'A-':
        return 'negativeA';
      case 'B+':
        return 'positiveB';
      case 'B-':
        return 'negativeB';
      case 'AB+':
        return 'positiveAB';
      case 'AB-':
        return 'negativeAB';
      case 'O+':
        return 'positiveO';
      case 'O-':
        return 'negativeO';
      default:
        return '';
    }
  }
}
