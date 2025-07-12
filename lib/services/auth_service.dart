import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://192.168.126.251:5000'; // your laptop IP

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/blo/login');
    print('🔐 Sending login request to: $url');
    print('📤 Request body: { email: $email, password: $password }');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': email,
          'password': password,
        }),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print('✅ Login successful. Token: ${data['token']}');
        return {
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        print('❌ Login failed with status ${response.statusCode}');
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('💥 Error during login: $e');
      rethrow;
    }
  }
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AuthService {
//   static const String baseUrl =
//       'https://your-api-url.com'; // TODO: Update later

//   static Future<Map<String, dynamic>> login(
//     String email,
//     String password,
//   ) async {
//     // final url = Uri.parse('$baseUrl/api/login');
//     // final response = await http.post(
//     //   url,
//     //   headers: {'Content-Type': 'application/json'},
//     //   body: jsonEncode({
//     //     'email': email,
//     //     'password': password,
//     //   }),
//     // );

//     // if (response.statusCode == 200) {
//     //   final data = jsonDecode(response.body);
//     //   return {
//     //     'token': data['token'],
//     //     'user': data['user'],
//     //   };
//     // } else {
//     //   throw Exception('Login failed: ${response.body}');
//     // }
//     await Future.delayed(const Duration(seconds: 1)); // simulate network delay

//     // Hardcoded token and user
//     return {
//       'token': 'hardcoded_token_123',
//       'user': {'name': 'Test User', 'email': email, 'phone': '9876543210'},
//     };
//   }
// }
