import 'dart:convert';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/donation_model.dart';

class DonationRepository {
  // Gerar token de doação
  Future<String> generateDonationToken() async {
    try {
      final response = await MyHttpClient.get(
        url: '/donations/generate-token',
        headers: MyHttpClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        throw Exception('Erro ao gerar token: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao gerar token: $e');
    }
  }

  // Agendar nova doação
  Future<DonationModel> scheduleDonation({
    required String bloodType,
    required DateTime donationDate,
    required String donationTime,
    required int bloodcenterId,
    String? donorAgeRange,
    String? donorGender,
    bool isFirstTimeDonor = false,
    String? medicalNotes,
  }) async {
    try {
      final token = await generateDonationToken();

      final Map<String, String> body = {
        'donation_token': token,
        'blood_type': bloodType,
        'donation_date': donationDate.toIso8601String().split('T')[0],
        'donation_time': donationTime,
        'bloodcenter_id': bloodcenterId.toString(),
        'is_first_time_donor': isFirstTimeDonor ? '1' : '0',
        'status': 'scheduled',
      };
      if (medicalNotes != null) body['medical_notes'] = medicalNotes;
      if (donorAgeRange != null) body['donor_age_range'] = donorAgeRange;
      if (donorGender != null) body['donor_gender'] = donorGender;

      final response = await MyHttpClient.post(
        url: '/donations/schedule',
        headers: MyHttpClient.getHeaders(),
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DonationModel.fromJson(data['data']);
      } else {
        throw Exception('Erro ao agendar doação: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception(
          'Erro ao agendar doação: $e');
    }
  }

  // Buscar doação por token
  Future<DonationModel> getDonationByToken(String token) async {
    try {
      final response = await MyHttpClient.get(
        url: '/donations/$token',
        headers: MyHttpClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DonationModel.fromJson(data['data']);
      } else {
        throw Exception('Erro ao buscar doação: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar doação: $e');
    }
  }

  // Listar doações com filtros
  Future<List<DonationModel>> getDonations({
    String? status,
    String? bloodType,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Map<String, String> params = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) params['status'] = status;
      if (bloodType != null) params['blood_type'] = bloodType;
      if (dateFrom != null)
        params['date_from'] = dateFrom.toIso8601String().split('T')[0];
      if (dateTo != null)
        params['date_to'] = dateTo.toIso8601String().split('T')[0];

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await MyHttpClient.get(
        url: '/donations?$queryString',
        headers: MyHttpClient.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']['data'] as List;
        return data.map((json) => DonationModel.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar doações: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar doações: $e');
    }
  }

  // Cancelar doação
  Future<DonationModel> cancelDonation(String token) async {
    try {
      final response = await MyHttpClient.post(
        url: '/donations/$token/cancel',
        headers: MyHttpClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DonationModel.fromJson(data['data']);
      } else {
        throw Exception('Erro ao cancelar doação: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao cancelar doação: $e');
    }
  }

  // Atualizar doação
  Future<DonationModel> updateDonation(
    String token, {
    String? bloodType,
    DateTime? donationDate,
    String? donationTime,
    String? donorAgeRange,
    String? donorGender,
    bool? isFirstTimeDonor,
    String? medicalNotes,
  }) async {
    try {
      Map<String, dynamic> data = {};

      if (bloodType != null) data['blood_type'] = bloodType;
      if (donationDate != null)
        data['donation_date'] = donationDate.toIso8601String().split('T')[0];
      if (donationTime != null) data['donation_time'] = donationTime;
      if (donorAgeRange != null) data['donor_age_range'] = donorAgeRange;
      if (donorGender != null) data['donor_gender'] = donorGender;
      if (isFirstTimeDonor != null)
        data['is_first_time_donor'] = isFirstTimeDonor;
      if (medicalNotes != null) data['medical_notes'] = medicalNotes;

      final response = await MyHttpClient.put(
        url: '/donations/$token',
        headers: MyHttpClient.getHeaders(),
        body: data.map((key, value) => MapEntry(key, value.toString())),
      );
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        return DonationModel.fromJson(resData['data']);
      } else {
        throw Exception('Erro ao atualizar doação: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar doação: $e');
    }
  }

  // Confirmar doação (usado pelo hemocentro)
  Future<DonationModel> confirmDonation(String token, String status,
      {String? staffNotes}) async {
    try {
      final response = await MyHttpClient.post(
        url: '/donations/$token/confirm',
        headers: MyHttpClient.getHeaders(),
        body: {
          'status': status,
          if (staffNotes != null) 'staff_notes': staffNotes,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DonationModel.fromJson(data['data']);
      } else {
        throw Exception('Erro ao confirmar doação: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao confirmar doação: $e');
    }
  }

  // Buscar estatísticas
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await MyHttpClient.get(
        url: '/donations/statistics',
        headers: MyHttpClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception(
            'Erro ao buscar estatísticas: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas: $e');
    }
  }

  // Buscar próxima doação do usuário
  Future<DonationModel?> getNextDonation() async {
    try {
      final response = await MyHttpClient.get(
        url: '/user/donations',
        headers: MyHttpClient.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        final userDonations = data.map((json) => DonationModel.fromJson(json)).toList();

        if (userDonations.isEmpty) return null;

        // Filtra apenas as doações agendadas e futuras
        final scheduledDonations = userDonations.where((d) =>
            d.status == 'scheduled' &&
            d.donationDate.isAfter(DateTime.now().subtract(Duration(days: 1)))) // Considera doações a partir de hoje
            .toList();

        if (scheduledDonations.isEmpty) return null;

        // Ordena por data e retorna a mais próxima
        scheduledDonations.sort((a, b) => a.donationDate.compareTo(b.donationDate));
        return scheduledDonations.first;
      } else {
        throw Exception('Erro ao buscar próxima doação: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar próxima doação: $e');
    }
  }

  // Buscar histórico de doações
  Future<List<DonationModel>> getDonationHistory() async {
    try {
      final response = await MyHttpClient.get(
        url: '/user/donations',
        headers: MyHttpClient.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        return data.map((json) => DonationModel.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar histórico: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar histórico: $e');
    }
  }
}
