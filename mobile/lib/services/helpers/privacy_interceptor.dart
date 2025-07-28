import 'package:flutter/foundation.dart';
import 'privacy_validator.dart';

class PrivacyHelper {
  /// Valida e sanitiza dados antes de enviar para API
  static Map<String, dynamic> sanitizeRequestData(Map<String, dynamic> data, String path) {
    // Aplicar validação específica baseada no endpoint
    switch (path) {
      case '/donations/schedule':
      case '/donations':
        return PrivacyValidator.validateDonationData(data);
      
      case '/user/profile':
      case '/user/update':
        return PrivacyValidator.validateUserData(data);
      
      default:
        // Validação geral para outros endpoints
        return _generalDataValidation(data);
    }
  }

  /// Sanitiza headers removendo dados sensíveis
  static Map<String, String> sanitizeHeaders(Map<String, String> headers) {
    final sanitizedHeaders = <String, String>{};

    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'authorization') {
        // Manter header de autorização mas não logar
        sanitizedHeaders[entry.key] = entry.value;
      } else {
        sanitizedHeaders[entry.key] = PrivacyValidator.sanitizeText(entry.value);
      }
    }

    return sanitizedHeaders;
  }

  /// Log seguro de resposta da API
  static void logResponse(int statusCode, String path, [String? body]) {
    if (kDebugMode) {
      final sanitizedMessage = PrivacyValidator.sanitizeForLogging(
        'Response: $statusCode - $path'
      );
      print(sanitizedMessage);
      
      if (body != null) {
        final sanitizedBody = PrivacyValidator.sanitizeForLogging(body);
        print('Body: $sanitizedBody');
      }
    }
  }

  /// Log seguro de erro da API
  static void logError(String message, String path) {
    if (kDebugMode) {
      final sanitizedMessage = PrivacyValidator.sanitizeForLogging(
        'Error: $message - $path'
      );
      print(sanitizedMessage);
    }
  }

  static Map<String, dynamic> _generalDataValidation(Map<String, dynamic> data) {
    final sanitizedData = <String, dynamic>{};

    for (final entry in data.entries) {
      if (entry.value is String) {
        final validation = PrivacyValidator.validateSensitiveData(entry.value);
        if (validation.isValid) {
          sanitizedData[entry.key] = entry.value;
        } else {
          sanitizedData[entry.key] = PrivacyValidator.sanitizeText(entry.value);
          if (kDebugMode) {
            print('Dados sensíveis sanitizados em ${entry.key}');
          }
        }
      } else {
        sanitizedData[entry.key] = entry.value;
      }
    }

    return sanitizedData;
  }
}
