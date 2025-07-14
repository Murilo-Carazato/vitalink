import 'dart:convert';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/donation_model.dart';

class DonationRepository {
  // Gerar token de doação
  Future<String> generateDonationToken() async {
    try {
      final response = await MyHttpClient.get(
        url: '/donations/generate-token',
        headers: MyHttpClient.getHeaders(token: MyHttpClient.token),
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

      // Adiciona o token do usuário nas notas médicas para identificação
      final userTag = '[USER_TOKEN:${MyHttpClient.token}]';
      final notes = medicalNotes != null ? '$medicalNotes $userTag' : userTag;

      final Map<String, String> body = {
        'donation_token': token,
        'blood_type': bloodType,
        'donation_date': donationDate.toIso8601String().split('T')[0],
        'donation_time': donationTime,
        'bloodcenter_id': bloodcenterId.toString(),
        'is_first_time_donor': isFirstTimeDonor ? '1' : '0',
        'medical_notes': notes,
        'status': 'scheduled',
      };
      if (donorAgeRange != null) body['donor_age_range'] = donorAgeRange;
      if (donorGender != null) body['donor_gender'] = donorGender;

      final response = await MyHttpClient.post(
        url: '/donations/schedule',
        headers: MyHttpClient.getHeaders(token: MyHttpClient.token),
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DonationModel.fromJson(data['data']);
      } else {
        throw Exception('Erro ao agendar doação: ${response.reasonPhrase}');
      }
    } catch (e, stack) {
      throw Exception(
          'Erro ao agendar doação: $e, ${e.toString()} ${e.runtimeType}\n$stack');
    }
  }

  // Buscar doação por token
  Future<DonationModel> getDonationByToken(String token) async {
    try {
      final response = await MyHttpClient.get(
        url: '/donations/$token',
        headers: MyHttpClient.getHeaders(token: MyHttpClient.token),
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
        headers: MyHttpClient.getHeaders(token: MyHttpClient.token),
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
        headers: MyHttpClient.getHeaders(token: MyHttpClient.token),
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
        headers: MyHttpClient.getHeaders(token: MyHttpClient.token),
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
        headers: MyHttpClient.getHeaders(token: MyHttpClient.token),
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
        headers: MyHttpClient.getHeaders(token: MyHttpClient.token),
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
      final allDonations = await getDonations(
        status: 'scheduled',
        dateFrom: DateTime.now(),
      );

      if (allDonations.isEmpty) return null;

      // Filtra apenas as doações do usuário atual
      final userDonations = allDonations
          .where((d) =>
              d.medicalNotes != null &&
              d.medicalNotes!.contains('[USER_TOKEN:${MyHttpClient.token}]'))
          .toList();

      if (userDonations.isEmpty) return null;

      // Ordena por data e retorna a mais próxima
      userDonations.sort((a, b) => a.donationDate.compareTo(b.donationDate));
      return userDonations.first;
    } catch (e) {
      throw Exception('Erro ao buscar próxima doação: $e');
    }
  }

  // Buscar histórico de doações
  Future<List<DonationModel>> getDonationHistory() async {
    try {
      final response = await MyHttpClient.get(
        url: '/donations?limit=100&sort=donation_date&order=desc',
        headers: MyHttpClient.getHeaders(token: MyHttpClient.token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']['data'] as List;
        final allDonations =
            data.map((json) => DonationModel.fromJson(json)).toList();

        // Filtra apenas as doações do usuário atual
        return allDonations
            .where((d) =>
                d.medicalNotes != null &&
                d.medicalNotes!.contains('[USER_TOKEN:${MyHttpClient.token}]'))
            .toList();
      } else {
        throw Exception('Erro ao buscar histórico: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar histórico: $e');
    }
  }
}
