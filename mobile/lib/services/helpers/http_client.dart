import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MyHttpClient {
  //esse token deve ser utilizado para os gets enquanto o backend não altera os dados para não necessitar de token
  static String token = "2|5yijr4W5VLIOPbY71sjrKt97snNZh5cqEpSGbiRif4742286";
  static const baseUrl = "http://192.168.0.5:8000/api";

    static Map<String, String> getHeaders({String? token, bool isJson = false}) {
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (token != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    if (isJson) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json'; // << NOVO
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
