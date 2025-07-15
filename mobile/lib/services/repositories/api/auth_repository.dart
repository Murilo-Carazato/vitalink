import 'dart:convert';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/models/login_request.dart';
import 'package:vitalink/services/models/register_request.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(LoginRequest req) async {
    try {
      final res = await MyHttpClient.postString(
        url: '/user/login',
        headers: MyHttpClient.getHeaders(isJson: true),
        body: req.toMap(),
      );

      print(res.body);

      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e, stackTrace) {
      print("erro no login: $e");
      print("stack trace: $stackTrace");
    }
    throw Exception('Login falhou');
  }

  Future<Map<String, dynamic>> register(RegisterRequest req) async {
    print(req.toMap());
    final res = await MyHttpClient.postString(
      url: '/user/register',
      headers: MyHttpClient.getHeaders(isJson: true),
      body: req.toMap(),
    );

    print(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    if (res.statusCode == 422) {
      try {
        final errorBody = jsonDecode(res.body);
        if (errorBody.containsKey('errors')) {
          final errors = errorBody['errors'] as Map<String, dynamic>;
          // Pega a primeira mensagem de erro da lista de erros.
          final firstErrorMessage =
              (errors.values.first as List).first as String;
          throw Exception(firstErrorMessage);
        }
        throw Exception('Os dados fornecidos são inválidos.');
      } catch (e) {
        // Se o erro não for o esperado, relança-o
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
    }

    throw Exception('Registro falhou: ${res.reasonPhrase}');
  }
}
