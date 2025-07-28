import 'package:flutter/foundation.dart';
import 'privacy_validator.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Simulação de preferências de notificação
  Map<String, bool> _preferences = {
    'donation_reminders': true,
    'emergency_alerts': true,
    'blood_center_updates': true,
    'system_notifications': true,
  };

  /// Obter preferências de notificação
  Map<String, bool> get preferences => Map.from(_preferences);

  /// Atualizar preferência específica
  Future<void> updatePreference(String key, bool value) async {
    _preferences[key] = value;
    await _savePreferences();
  }

  /// Verificar se notificação deve ser enviada
  bool shouldSendNotification(String type) {
    return _preferences[type] ?? false;
  }

  /// Processar notificação com validação de privacidade
  Future<Map<String, dynamic>> processNotification({
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    // Validar se o tipo de notificação está habilitado
    if (!shouldSendNotification(type)) {
      return {
        'success': false,
        'error': 'Tipo de notificação desabilitado nas preferências'
      };
    }

    // Sanitizar dados sensíveis
    final sanitizedTitle = PrivacyValidator.sanitizeString(title);
    final sanitizedMessage = PrivacyValidator.sanitizeString(message);
    final sanitizedData = data != null ? _sanitizeNotificationData(data) : null;

    // Validar se contém dados sensíveis
    if (PrivacyValidator.containsSensitiveData(title) ||
        PrivacyValidator.containsSensitiveData(message)) {
      if (kDebugMode) {
        print('AVISO: Notificação contém dados sensíveis e foi sanitizada');
      }
    }

    // Simular envio de notificação
    await Future.delayed(Duration(milliseconds: 100));

    return {
      'success': true,
      'notification': {
        'type': type,
        'title': sanitizedTitle,
        'message': sanitizedMessage,
        'data': sanitizedData,
        'timestamp': DateTime.now().toIso8601String(),
      }
    };
  }

  /// Sanitizar dados da notificação
  Map<String, dynamic> _sanitizeNotificationData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    
    for (final entry in data.entries) {
      if (entry.value is String) {
        sanitized[entry.key] = PrivacyValidator.sanitizeString(entry.value);
      } else if (entry.value is Map<String, dynamic>) {
        sanitized[entry.key] = _sanitizeNotificationData(entry.value);
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    
    return sanitized;
  }

  /// Criar notificação de lembrete de doação
  Future<Map<String, dynamic>> createDonationReminder({
    required String donationToken,
    required DateTime donationDate,
    required String bloodCenterName,
  }) async {
    return await processNotification(
      type: 'donation_reminders',
      title: 'Lembrete de Doação',
      message: 'Você tem uma doação agendada para ${_formatDate(donationDate)} no $bloodCenterName',
      data: {
        'donation_token': donationToken,
        'donation_date': donationDate.toIso8601String(),
        'blood_center_name': bloodCenterName,
        'action': 'view_donation',
      },
    );
  }

  /// Criar notificação de emergência
  Future<Map<String, dynamic>> createEmergencyAlert({
    required String bloodType,
    required String bloodCenterName,
    required String urgencyLevel,
  }) async {
    return await processNotification(
      type: 'emergency_alerts',
      title: 'Alerta de Emergência',
      message: 'Urgente: Necessidade de sangue tipo $bloodType em $bloodCenterName',
      data: {
        'blood_type': bloodType,
        'blood_center_name': bloodCenterName,
        'urgency_level': urgencyLevel,
        'action': 'schedule_donation',
      },
    );
  }

  /// Criar notificação de atualização do hemocentro
  Future<Map<String, dynamic>> createBloodCenterUpdate({
    required String bloodCenterName,
    required String updateType,
    required String message,
  }) async {
    return await processNotification(
      type: 'blood_center_updates',
      title: 'Atualização do Hemocentro',
      message: message,
      data: {
        'blood_center_name': bloodCenterName,
        'update_type': updateType,
        'action': 'view_blood_center',
      },
    );
  }

  /// Criar notificação do sistema
  Future<Map<String, dynamic>> createSystemNotification({
    required String title,
    required String message,
    String? actionType,
  }) async {
    return await processNotification(
      type: 'system_notifications',
      title: title,
      message: message,
      data: {
        'action': actionType ?? 'none',
      },
    );
  }

  /// Salvar preferências (simulação)
  Future<void> _savePreferences() async {
    // Em uma implementação real, salvaria em SharedPreferences
    await Future.delayed(Duration(milliseconds: 50));
    if (kDebugMode) {
      print('Preferências de notificação salvas: $_preferences');
    }
  }

  /// Carregar preferências (simulação)
  Future<void> loadPreferences() async {
    // Em uma implementação real, carregaria do SharedPreferences
    await Future.delayed(Duration(milliseconds: 50));
    if (kDebugMode) {
      print('Preferências de notificação carregadas: $_preferences');
    }
  }

  /// Formatar data para exibição
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final donationDay = DateTime(date.year, date.month, date.day);

    if (donationDay == today) {
      return 'hoje às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (donationDay == tomorrow) {
      return 'amanhã às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Resetar preferências para padrão
  Future<void> resetToDefault() async {
    _preferences = {
      'donation_reminders': true,
      'emergency_alerts': true,
      'blood_center_updates': true,
      'system_notifications': true,
    };
    await _savePreferences();
  }

  /// Desabilitar todas as notificações
  Future<void> disableAllNotifications() async {
    _preferences = _preferences.map((key, value) => MapEntry(key, false));
    await _savePreferences();
  }

  /// Habilitar todas as notificações
  Future<void> enableAllNotifications() async {
    _preferences = _preferences.map((key, value) => MapEntry(key, true));
    await _savePreferences();
  }
}
