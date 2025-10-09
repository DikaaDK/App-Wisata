import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:appwisata/helpers/user_info.dart';
import 'app_exception.dart';

class Api {
  static const String baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final parsed = _returnResponse(response);
    return parsed as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registrasi(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/registrasi'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final parsed = _returnResponse(response);
    return parsed as Map<String, dynamic>;
  }

  Future<dynamic> post(dynamic url, dynamic data) async {
    var token = await UserInfo().getToken();
    dynamic responseJson;
    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> get(dynamic url) async {
    var token = await UserInfo().getToken();
    dynamic responseJson;
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> delete(dynamic url) async {
    var token = await UserInfo().getToken();
    dynamic responseJson;
    try {
      final response = await http.delete(
        url,
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 422:
        throw InvalidInputException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}',
        );
    }
  }
}
