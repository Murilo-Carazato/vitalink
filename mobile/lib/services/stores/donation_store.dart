import 'package:flutter/foundation.dart';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/donation_model.dart';
import 'package:vitalink/services/repositories/api/donation_repository.dart';
import 'package:vitalink/services/stores/user_store.dart';
import '../helpers/privacy_validator.dart';
import '../helpers/notification_service.dart';
import '../helpers/token_service.dart';

class DonationStore extends ChangeNotifier {
  final DonationRepository _repository;
  final UserStore _userStore;

  DonationStore(
      {required DonationRepository repository, required UserStore userStore})
      : _repository = repository,
        _userStore = userStore;

  // Estados
  List<DonationModel> _donations = [];
  DonationModel? _nextDonation;
  bool _isLoading = false;
  String? _error;
  final NotificationService _notificationService = NotificationService();
  final TokenService _tokenService = TokenService();
  Map<String, dynamic> _statistics = {};

  // Getters
  List<DonationModel> get donations => _donations;
  DonationModel? get nextDonation => _nextDonation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get statistics => _statistics;

  // Métodos privados
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String value) {
    if (value.startsWith('Exception: ')) {
      _error = value.substring(11); // Remove "Exception: "
    } else {
      _error = value;
    }
    // Log error for debugging but don't expose sensitive data
    if (kDebugMode) {
      final sanitizedError = PrivacyValidator.sanitizeForLogging(value);
      print('DonationStore Error: $sanitizedError');
    }
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<bool> _ensureUserIsLoaded() async {
    // Se o token não estiver definido no cliente, tenta carregar o usuário
    if (MyHttpClient.getToken() == null || MyHttpClient.getToken()!.isEmpty) {
      await _userStore.loadCurrentUser();
    }
    
    // Se, mesmo após a tentativa, o token não estiver disponível, a ação falha.
    if (MyHttpClient.getToken() == null || MyHttpClient.getToken()!.isEmpty) {
      _setError("Usuário não autenticado.");
      return false;
    }
    return true;
  }

  // Agendar doação
  Future<DonationModel?> scheduleDonation({
    required String bloodType,
    required DateTime donationDate,
    required String donationTime,
    required int bloodcenterId,
    String? donorAgeRange,
    String? donorGender,
    bool isFirstTimeDonor = false,
    String? medicalNotes,
  }) async {
    if (!await _ensureUserIsLoaded()) return null;
    _setLoading(true);
    _clearError();

    try {
      final donation = await _repository.scheduleDonation(
        bloodType: bloodType,
        donationDate: donationDate,
        donationTime: donationTime,
        bloodcenterId: bloodcenterId,
        donorAgeRange: donorAgeRange,
        donorGender: donorGender,
        isFirstTimeDonor: isFirstTimeDonor,
        medicalNotes: medicalNotes,
      );

      _donations = [donation, ..._donations];
      
      if (_nextDonation == null ||
          donationDate.isBefore(_nextDonation!.donationDate)) {
        _nextDonation = donation;
      }

      notifyListeners();
      return donation;
    } catch (e, stackTrace) {
      print('error: $e , stackTrace: $stackTrace');
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Buscar doações
  Future<void> fetchDonations({
    String? status,
    String? bloodType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final donations = await _repository.getDonations(
        status: status,
        bloodType: bloodType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      _donations = donations;
      notifyListeners();
    } catch (e, stackTrace) {
      print('error: $e , stackTrace: $stackTrace');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Buscar próxima doação
  Future<void> fetchNextDonation() async {
    if (!await _ensureUserIsLoaded()) return;
    _setLoading(true);
    _clearError();

    try {
      final donation = await _repository.getNextDonation();
      _nextDonation = donation;
      notifyListeners();
    } catch (e, stackTrace) {
      print('error: $e , stackTrace: $stackTrace');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Cancelar doação
  Future<bool> cancelDonation(String token) async {
    if (!await _ensureUserIsLoaded()) return false;
    _setLoading(true);
    _clearError();

    try {
      final updatedDonation = await _repository.cancelDonation(token);

      final index =
          _donations.indexWhere((d) => d.donationToken == token);
      if (index != -1) {
        final updatedList = List<DonationModel>.from(_donations);
        updatedList[index] = updatedDonation;
        _donations = updatedList;
      }

      if (_nextDonation?.donationToken == token) {
        await fetchNextDonation();
      }

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('error: $e , stackTrace: $stackTrace');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar doação
  Future<bool> updateDonation(
    String token, {
    String? bloodType,
    DateTime? donationDate,
    String? donationTime,
    String? donorAgeRange,
    String? donorGender,
    bool? isFirstTimeDonor,
    String? medicalNotes,
    String? status,
  }) async {
    if (!await _ensureUserIsLoaded()) return false;
    _setLoading(true);
    _clearError();

    try {
      final updatedDonation = await _repository.updateDonation(
        token,
        bloodType: bloodType,
        donationDate: donationDate,
        donationTime: donationTime,
        donorAgeRange: donorAgeRange,
        donorGender: donorGender,
        isFirstTimeDonor: isFirstTimeDonor,
        medicalNotes: medicalNotes,
        status: status,
      );

      final index =
          _donations.indexWhere((d) => d.donationToken == token);
      if (index != -1) {
        final updatedList = List<DonationModel>.from(_donations);
        updatedList[index] = updatedDonation;
        _donations = updatedList;
      }

      if (_nextDonation?.donationToken == token) {
        _nextDonation = updatedDonation;
      }

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('error: $e , stackTrace: $stackTrace');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Marcar doação como concluída
  Future<bool> completeDonation(String token) async {
    if (!await _ensureUserIsLoaded()) return false;
    _setLoading(true);
    _clearError();

    try {
      final completedDonation = await _repository.completeDonation(token);

      final index = _donations.indexWhere((d) => d.donationToken == token);
      if (index != -1) {
        final updatedList = List<DonationModel>.from(_donations);
        updatedList[index] = completedDonation;
        _donations = updatedList;
      }

      if (_nextDonation?.donationToken == token) {
        await fetchNextDonation(); // Recarrega a próxima doação
      }

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('error: $e , stackTrace: $stackTrace');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Buscar histórico
  Future<void> fetchDonationHistory() async {
    if (!await _ensureUserIsLoaded()) return;
    _setLoading(true);
    _clearError();

    try {
      final history = await _repository.getDonationHistory();
      _donations = history;
      print('history: $history');
      notifyListeners();
    } catch (e, stackTrace) {
      print('error: $e , stackTrace: $stackTrace');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Buscar estatísticas
  // Future<void> fetchStatistics() async {
  //   _setLoading(true);
  //   _clearError();

  //   try {
  //     final stats = await _repository.getStatistics();
  //     _statistics.value = stats;
  //     notifyListeners();
  //   } catch (e) {
  //     _setError(e.toString());
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Buscar doação por token
  Future<DonationModel?> getDonationByToken(String token) async {
    _setLoading(true);
    _clearError();

    try {
      final donation = await _repository.getDonationByToken(token);
      return donation;
    } catch (e, stackTrace) {
      print('error: $e , stackTrace: $stackTrace');
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Filtrar doações localmente
  // Método para filtrar doações pelo usuário atual
  List<DonationModel> getFilteredDonations({String? status}) {
    // Primeiro filtra por status se necessário
    var filtered = status != null
        ? _donations
            .where((d) => d.status.toLowerCase() == status.toLowerCase())
            .toList()
        : List<DonationModel>.from(_donations);

    // Ordena por data (mais recente primeiro)
    filtered.sort((a, b) => b.donationDate.compareTo(a.donationDate));

    return filtered;
  }

  // Limpar dados
  void clearData() {
    _donations = [];
    _nextDonation = null;
    _statistics = {};
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
