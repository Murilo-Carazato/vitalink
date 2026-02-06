import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyHttpClient {
  static String? _token;
  // static String? _token = "3|TdMkGp4EHz1iZ3oq7HExr2xTx836rFmScKFceeXdca0075fd";

  // Base URL configurável via --dart-define=API_BASE_URL
  // Ex.: fvm flutter run --dart-define=API_BASE_URL=http://localhost:8080
  // Normaliza a barra final e adiciona "/api".
  //static const baseUrl = "http://192.168.0.3:8000/api";
  static final String baseUrl = (() {
    final env = dotenv.env['API_BASE_URL']!;
    final normalized = env.endsWith('/') ? env.substring(0, env.length - 1) : env;
    return '$normalized/api';
  })();


  static void setToken(String newToken) {
    if (newToken.isEmpty) {
      print('WARNING: Setting empty token in HTTP client');
      _token = null;
      return;
    }
    _token = newToken;
    print('Token set in HTTP client: ${newToken.length > 10 ? newToken.substring(0, 10) + '...' : newToken}');
  }

  static void clearToken() {
    print('Clearing token in HTTP client');
    _token = null;
  }

  static String? getToken() {
    return _token;
  }

  static bool hasValidToken() {
    return _token != null && _token!.isNotEmpty;
  }

  static Map<String, String> getHeaders({String? token, bool isJson = false}) {
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
    };
    final currentToken = token ?? _token;
    if (currentToken != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $currentToken';
    }
    if (isJson) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json';
    }
    return headers;
  }

  static Future<http.Response> get({
    required String url,
    required Map<String, String> headers,
  }) async {
    final fullUrl = baseUrl + url;
    print('HTTP GET Request: $fullUrl');
    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: headers,
      );
      print('HTTP Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('HTTP ERROR: $e');
      rethrow;
    }
  }

  static Future<http.Response> post({
    required String url,
    required Map<String, String> headers,
    Map<String, String>? body,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl + url),
      headers: headers,
      body: body,
    );
    return response;
  }

  static Future<http.Response> postString({
    required String url,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl + url),
      headers: headers,
      body: json.encode(body),
    );
    return response;
  }

  static Future<http.Response> putString({
    required String url,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) async {
    final response = await http.put(
      Uri.parse(baseUrl + url),
      headers: headers,
      body: json.encode(body),
    );
    return response;
  }

  static Future<http.Response> put({
    required String url,
    required Map<String, String> headers,
    Map<String, String>? body,
  }) async {
    final response = await http.put(
      Uri.parse(baseUrl + url),
      headers: headers,
      body: body,
    );
    return response;
  }

  static Future<http.Response> delete({
    required String url,
    required Map<String, String> headers,
  }) async {
    final response = await http.delete(
      Uri.parse(baseUrl + url),
      headers: headers,
    );
    return response;
  }
}
