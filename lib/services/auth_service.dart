import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      'https://your-api-url.com'; // TODO: Update later

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    // final url = Uri.parse('$baseUrl/api/login');
    // final response = await http.post(
    //   url,
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'email': email,
    //     'password': password,
    //   }),
    // );

    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body);
    //   return {
    //     'token': data['token'],
    //     'user': data['user'],
    //   };
    // } else {
    //   throw Exception('Login failed: ${response.body}');
    // }
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    // Hardcoded token and user
    return {
      'token': 'hardcoded_token_123',
      'user': {'name': 'Test User', 'email': email, 'phone': '9876543210'},
    };
  }
}
