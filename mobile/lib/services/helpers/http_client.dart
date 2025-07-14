import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MyHttpClient {
  static String? _token;
  static const baseUrl = "http://192.168.0.5:8000/api";

  static void setToken(String newToken) {
    _token = newToken;
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
    final response = await http.get(
      Uri.parse(baseUrl + url),
      headers: headers,
    );

    return response;
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
