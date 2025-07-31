import 'package:flutter/foundation.dart';

class PrivacyValidator {
  // Patterns que não devem ser enviados para o servidor
  static const List<String> _sensitivePatterns = [
    r'\b\d{3}\.\d{3}\.\d{3}-\d{2}\b', // CPF
    r'\b\d{11}\b', // CPF sem pontos
    r'\b\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}\b', // CNPJ
    r'\b\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\b', // Cartão de crédito
    r'\b\d{5}-?\d{3}\b', // CEP
    r'\b\(\d{2}\)\s?\d{4,5}-?\d{4}\b', // Telefone
    r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b', // Email (em alguns contextos)
  ];

  /// Valida se o texto contém informações sensíveis
  static ValidationResult validateSensitiveData(String? text) {
    if (text == null || text.isEmpty) {
      return ValidationResult.success();
    }

    final violations = <String>[];

    for (final pattern in _sensitivePatterns) {
      final regex = RegExp(pattern);
      if (regex.hasMatch(text)) {
        violations.add(_getViolationMessage(pattern));
      }
    }

    if (violations.isNotEmpty) {
      return ValidationResult.failure(violations);
    }

    return ValidationResult.success();
  }

  /// Limpa dados sensíveis do texto
  static String sanitizeText(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }

    String sanitized = text;

    for (final pattern in _sensitivePatterns) {
      final regex = RegExp(pattern);
      sanitized = sanitized.replaceAll(regex, '[DADOS_REMOVIDOS]');
    }

    return sanitized;
  }

  /// Alias para `sanitizeText` para compatibilidade legada
  static String sanitizeString(String? text) => sanitizeText(text);

  /// Retorna `true` se o texto contiver dados sensíveis, de acordo com [_sensitivePatterns].
  static bool containsSensitiveData(String? text) =>
      !validateSensitiveData(text).isValid;

  /// Limpa dados sensíveis do texto (duplicado, será removido em refatoração futura)
  static String _sanitizeTextLegacy(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }

    String sanitized = text;

    for (final pattern in _sensitivePatterns) {
      final regex = RegExp(pattern);
      sanitized = sanitized.replaceAll(regex, '[DADOS_REMOVIDOS]');
    }

    return sanitized;
  }

  /// Valida dados de doação antes de enviar
  static Map<String, dynamic> validateDonationData(Map<String, dynamic> data) {
    final sanitizedData = <String, dynamic>{};

    for (final entry in data.entries) {
      if (entry.value is String) {
        // Validar e sanitizar strings
        final validation = validateSensitiveData(entry.value);
        if (validation.isValid) {
          sanitizedData[entry.key] = entry.value;
        } else {
          sanitizedData[entry.key] = sanitizeText(entry.value);
          if (kDebugMode) {
            print('Dados sensíveis detectados em ${entry.key}: ${validation.violations}');
          }
        }
      } else {
        sanitizedData[entry.key] = entry.value;
      }
    }

    return sanitizedData;
  }

  /// Valida dados de usuário antes de enviar
  static Map<String, dynamic> validateUserData(Map<String, dynamic> data) {
    final allowedFields = {
      'email',
      'bloodcenter_id', // Apenas ID, não dados completos
      'device_token', // Para notificações
      'preferences', // Configurações de notificação
    };

    final sanitizedData = <String, dynamic>{};

    for (final entry in data.entries) {
      if (allowedFields.contains(entry.key)) {
        if (entry.value is String) {
          sanitizedData[entry.key] = sanitizeText(entry.value);
        } else {
          sanitizedData[entry.key] = entry.value;
        }
      } else {
        if (kDebugMode) {
          print('Campo não permitido removido: ${entry.key}');
        }
      }
    }

    return sanitizedData;
  }

  /// Valida se os dados estão seguros para logging
  static String sanitizeForLogging(String message) {
    return sanitizeText(message);
  }

  static String _getViolationMessage(String pattern) {
    switch (pattern) {
      case r'\b\d{3}\.\d{3}\.\d{3}-\d{2}\b':
      case r'\b\d{11}\b':
        return 'CPF detectado';
      case r'\b\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}\b':
        return 'CNPJ detectado';
      case r'\b\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\b':
        return 'Número de cartão detectado';
      case r'\b\d{5}-?\d{3}\b':
        return 'CEP detectado';
      case r'\b\(\d{2}\)\s?\d{4,5}-?\d{4}\b':
        return 'Telefone detectado';
      case r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b':
        return 'Email detectado';
      default:
        return 'Dados sensíveis detectados';
    }
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> violations;

  ValidationResult._(this.isValid, this.violations);

  factory ValidationResult.success() => ValidationResult._(true, []);
  factory ValidationResult.failure(List<String> violations) => ValidationResult._(false, violations);
}
