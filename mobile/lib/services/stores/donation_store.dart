import 'package:flutter/material.dart';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/donation_model.dart';
import 'package:vitalink/services/repositories/api/donation_repository.dart';

class DonationStore extends ChangeNotifier {
  final DonationRepository _repository;

  DonationStore({required DonationRepository repository})
      : _repository = repository;

  // Estados
  final ValueNotifier<List<DonationModel>> _donations = ValueNotifier([]);
  final ValueNotifier<DonationModel?> _nextDonation = ValueNotifier(null);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<String> _error = ValueNotifier('');
  final ValueNotifier<Map<String, dynamic>> _statistics = ValueNotifier({});

  // Getters
  ValueNotifier<List<DonationModel>> get donations => _donations;
  ValueNotifier<DonationModel?> get nextDonation => _nextDonation;
  ValueNotifier<bool> get isLoading => _isLoading;
  ValueNotifier<String> get error => _error;
  ValueNotifier<Map<String, dynamic>> get statistics => _statistics;

  // Métodos privados
  void _setLoading(bool value) {
    _isLoading.value = value;
    notifyListeners();
  }

  void _setError(String value) {
    _error.value = value;
    notifyListeners();
  }

  void _clearError() {
    _error.value = '';
    notifyListeners();
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

      // Atualiza a lista de doações - certifique-se de que é uma nova instância da lista
      final updatedDonations = [donation, ..._donations.value];
      _donations.value = updatedDonations;

      // Atualiza próxima doação
      if (_nextDonation.value == null ||
          donationDate.isBefore(_nextDonation.value!.donationDate)) {
        _nextDonation.value = donation;
      }

      notifyListeners();
      return donation;
    } catch (e) {
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

      _donations.value = donations;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Buscar próxima doação
  Future<void> fetchNextDonation() async {
    _setLoading(true);
    _clearError();

    try {
      final donation = await _repository.getNextDonation();
      _nextDonation.value = donation;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Cancelar doação
  Future<bool> cancelDonation(String token) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedDonation = await _repository.cancelDonation(token);

      // Atualiza a lista local
      final index =
          _donations.value.indexWhere((d) => d.donationToken == token);
      if (index != -1) {
        final updatedList = List<DonationModel>.from(_donations.value);
        updatedList[index] = updatedDonation;
        _donations.value = updatedList;
      }

      // Atualiza próxima doação se necessário
      if (_nextDonation.value?.donationToken == token) {
        await fetchNextDonation();
      }

      notifyListeners();
      return true;
    } catch (e) {
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
  }) async {
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
      );

      // Atualiza a lista local
      final index =
          _donations.value.indexWhere((d) => d.donationToken == token);
      if (index != -1) {
        final updatedList = List<DonationModel>.from(_donations.value);
        updatedList[index] = updatedDonation;
        _donations.value = updatedList;
      }

      // Atualiza próxima doação se necessário
      if (_nextDonation.value?.donationToken == token) {
        _nextDonation.value = updatedDonation;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Buscar histórico
  Future<void> fetchDonationHistory() async {
    _setLoading(true);
    _clearError();

    try {
      final history = await _repository.getDonationHistory();
      print('Fetched donation history: ${history} items');
      _donations.value = history;
      notifyListeners();
    } catch (e) {
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
    } catch (e) {
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
        ? _donations.value
            .where((d) => d.status.toLowerCase() == status.toLowerCase())
            .toList()
        : List<DonationModel>.from(_donations.value);

    // Filtra apenas as doações que contêm o token do usuário nas notas médicas
    if (MyHttpClient.getHeaders().isNotEmpty) {
      filtered = filtered
          .where((d) =>
              d.medicalNotes != null &&
              d.medicalNotes!.contains('[USER_TOKEN:${MyHttpClient.getHeaders()}]'))
          .toList();
    }

    // Ordena por data (mais recente primeiro)
    filtered.sort((a, b) => b.donationDate.compareTo(a.donationDate));

    return filtered;
  }

  // Limpar dados
  void clearData() {
    _donations.value = [];
    _nextDonation.value = null;
    _statistics.value = {};
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _donations.dispose();
    _nextDonation.dispose();
    _isLoading.dispose();
    _error.dispose();
    _statistics.dispose();
    super.dispose();
  }
}
