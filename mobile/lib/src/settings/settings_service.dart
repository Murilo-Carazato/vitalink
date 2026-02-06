import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vitalink/services/repositories/user_repository.dart';

/// Serviço que armazena e recupera as configurações do usuário.
class SettingsService {
  final UserRepository _userRepository = UserRepository();

  /// Carrega o ThemeMode preferido do usuário do armazenamento local.
  Future<ThemeMode> themeMode() async {
    try {
      if (kIsWeb) {
        // Web não usa sqflite; retorna padrão
        return ThemeMode.dark;
      }
      final users = await _userRepository.getUser();
      if (users.isNotEmpty) {
        return users.first.getThemeMode();
      }
    } catch (e) {
      print('Erro ao carregar tema: $e');
    }
    // Padrão para tema escuro se não encontrar usuário
    return ThemeMode.dark;
  }

  /// Persiste o ThemeMode preferido do usuário no armazenamento local.
  Future<void> updateThemeMode(ThemeMode theme) async {
    try {
      if (kIsWeb) return; // No-op no Web (sem DB)
      final users = await _userRepository.getUser();
      if (users.isNotEmpty) {
        final user = users.first;
        
        String themeModeString;
        switch (theme) {
          case ThemeMode.light:
            themeModeString = 'light';
            break;
          case ThemeMode.dark:
            themeModeString = 'dark';
            break;
          case ThemeMode.system:
            themeModeString = 'system';
            break;
        }
        
        final updatedUser = user.copyWith(themeMode: themeModeString);
        await _userRepository.updateUser(updatedUser);
        print('Tema atualizado para: $themeModeString');
      }
    } catch (e) {
      print('Erro ao salvar tema: $e');
    }
  }
}
