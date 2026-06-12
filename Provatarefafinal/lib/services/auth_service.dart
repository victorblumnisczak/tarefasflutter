import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_user.dart';
import 'api_headers.dart';

class AuthService {
  final String baseUrl = 'https://dummyjson.com/auth';

  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: ApiHeaders.json(),
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 30,
      }),
    );
    if (response.statusCode == 200) {
      return AuthUser.fromJson(jsonDecode(response.body));
    }
    throw Exception('Usuário ou senha inválidos');
  }

  Future<AuthUser> fetchProfile(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: ApiHeaders.auth(accessToken),
    );
    if (response.statusCode == 200) {
      return AuthUser.fromJson(jsonDecode(response.body));
    }
    throw Exception('Não foi possível carregar o perfil');
  }
}
