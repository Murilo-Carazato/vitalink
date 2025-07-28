import 'package:flutter/foundation.dart';
import 'dart:async';
import 'privacy_validator.dart';

class TokenService {
  
  static String? _currentToken;
  static DateTime? _tokenExpiry;
  static Timer? _refreshTimer;
  
  // Configurações
  static const String baseUrl = 'https://api.vitalink.com.br'; // Configurar URL base
  static const Duration refreshInterval = Duration(minutes: 30); // Verificar a cada 30 min
  
  /// Salva token com data de expiração
  static Future<void> setToken(String token, DateTime expiresAt) async {
    _currentToken = token;
    _tokenExpiry = expiresAt;
    
    // Iniciar timer para verificação automática
    _scheduleTokenRefresh();
    
    if (kDebugMode) {
      print('Token salvo. Expira em: ${expiresAt.toLocal()}');
    }
  }
  
  /// Obtém token atual
  static Future<String?> getToken() async {
    if (_currentToken != null && _tokenExpiry != null) {
      if (DateTime.now().isBefore(_tokenExpiry!)) {
        return _currentToken;
      }
    }
    
    return null;
  }
  
  /// Verifica se token está próximo do vencimento
  static bool isTokenExpiringSoon() {
    if (_tokenExpiry == null) return true;
    
    final now = DateTime.now();
    final minutesToExpiry = _tokenExpiry!.difference(now).inMinutes;
    
    return minutesToExpiry <= 60; // 1 hora antes do vencimento
  }
  
  /// Tenta renovar o token automaticamente
  static Future<bool> attemptTokenRefresh() async {
    final currentToken = await getToken();
    if (currentToken == null) {
      return false;
    }
    
    try {
      // Implementar requisição HTTP manualmente ou usar o cliente HTTP existente
      // Por enquanto, retornar false para indicar que não foi possível renovar
      if (kDebugMode) {
        print('Token refresh não implementado ainda');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        final sanitizedError = PrivacyValidator.sanitizeForLogging(e.toString());
        print('Erro ao renovar token: $sanitizedError');
      }
    }
    
    return false;
  }
  
  /// Agenda verificação automática de token
  static void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();
    
    _refreshTimer = Timer.periodic(refreshInterval, (timer) async {
      if (isTokenExpiringSoon()) {
        final refreshed = await attemptTokenRefresh();
        if (!refreshed) {
          // Token não pôde ser renovado, usuário precisa fazer login novamente
          await clearToken();
          _notifyTokenExpired();
        }
      }
    });
  }
  
  /// Notifica que o token expirou (implementar callback se necessário)
  static void _notifyTokenExpired() {
    if (kDebugMode) {
      print('Token expirado - usuário precisa fazer login novamente');
    }
    // Aqui você pode implementar um callback para notificar a UI
    // ou usar um EventBus para comunicar com outras partes do app
  }
  
  /// Limpa token do storage
  static Future<void> clearToken() async {
    _currentToken = null;
    _tokenExpiry = null;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    
    if (kDebugMode) {
      print('Token removido da memória');
    }
  }
  
  /// Verifica se usuário está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
  
  /// Obtém headers com token para requisições autenticadas
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token não encontrado - usuário não autenticado');
    }
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
  
  /// Dispose para cleanup
  static void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}
