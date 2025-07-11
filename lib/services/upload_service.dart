import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadService {
  static const String baseUrl = "http://192.168.126.251:5000"; // Replace if needed

  /// 🔼 Upload image entry to backend
  static Future<bool> uploadEntry({
    required File imageFile,
    required double latitude,
    required double longitude,
    required DateTime timeSlot,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/api/blo/send-image");

    print("📤 Uploading image entry...");
    print("🗂️ TimeSlot: $timeSlot");
    print("📍 Location: $latitude, $longitude");
    print("🖼️ Image path: ${imageFile.path}");
    print("🔐 Token: $token");

    try {
      final request = http.MultipartRequest("POST", url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['latitude'] = latitude.toString()
        ..fields['longitude'] = longitude.toString()
        ..fields['timeSlot'] = timeSlot.toIso8601String()
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📡 Upload response: ${response.statusCode}");
      print("📄 Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Upload failed: $e");
      return false;
    }
  }

  /// 📡 Send background location to backend
  static Future<bool> sendBackgroundLocation({
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/api/blo/send-location");

    print("📡 Sending background location...");
    print("🕓 Timestamp: $timestamp");
    print("📍 Location: $latitude, $longitude");
    print("🔐 Token: $token");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': timestamp.toIso8601String(),
        }),
      );

      print("📡 Location response: ${response.statusCode}");
      print("📄 Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Background location upload error: $e");
      return false;
    }
  }
}













// ********************************************

// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:http/http.dart' as http;

// class UploadService {
//   static const String baseUrl =
//       "https://dummy-backend-for-test.com"; // Simulated

//   /// 🔼 Simulated image entry upload
//   static Future<bool> uploadEntry({
//     required File imageFile,
//     required double latitude,
//     required double longitude,
//     required DateTime timeSlot,
//     required String token,
//   }) async {
//     print("📤 [SIM] Uploading image entry...");
//     print("🗂️ TimeSlot: $timeSlot");
//     print("📍 Location: $latitude, $longitude");
//     print("🖼️ Image path: ${imageFile.path}");
//     print("🔐 Token: $token");

//     await Future.delayed(const Duration(seconds: 2)); // simulate network delay

//     // Random success/failure for testing (90% success rate)
//     final success = Random().nextInt(10) < 9;
//     print(
//       success
//           ? "✅ [SIM] Image upload success!"
//           : "❌ [SIM] Image upload failed!",
//     );

//     return success;
//   }

//   /// 📡 Simulated background location sender
//   static Future<bool> sendBackgroundLocation({
//     required double latitude,
//     required double longitude,
//     required DateTime timestamp,
//     required String token,
//   }) async {
//     print("📡 [SIM] Sending background location...");
//     print("🕓 Timestamp: $timestamp");
//     print("📍 Location: $latitude, $longitude");
//     print("🔐 Token: $token");

//     await Future.delayed(const Duration(seconds: 1)); // simulate delay

//     // final success = Random().nextInt(10) < 9;
//     final success = true;
//     print(
//       success
//           ? "✅ [SIM] Location upload success!"
//           : "❌ [SIM] Location upload failed!",
//     );

//     return success;
//   }
// }


// // ***************REAL LOGIC****************
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:http/http.dart' as http;

// // class UploadService {
// //   static const String baseUrl = "https://your-backend-api.com"; // Replace with actual

// //   static Future<bool> uploadEntry({
// //     required File imageFile,
// //     required double latitude,
// //     required double longitude,
// //     required DateTime timeSlot,
// //     required String token,
// //   }) async {
// //     final url = Uri.parse("$baseUrl/api/upload-entry");

// //     try {
// //       final request = http.MultipartRequest("POST", url)
// //         ..headers['Authorization'] = 'Bearer $token'
// //         ..fields['latitude'] = latitude.toString()
// //         ..fields['longitude'] = longitude.toString()
// //         ..fields['timeSlot'] = timeSlot.toIso8601String()
// //         ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

// //       final streamedResponse = await request.send();
// //       final response = await http.Response.fromStream(streamedResponse);

// //       print("📡 Upload response: ${response.statusCode}");
// //       print("📄 Body: ${response.body}");

// //       if (response.statusCode == 200) {
// //         final body = json.decode(response.body);
// //         return body['success'] == true;
// //       } else {
// //         return false;
// //       }
// //     } catch (e) {
// //       print("❌ Upload failed: $e");
// //       return false;
// //     }
// //   }

// //   /// ✅ NEW FUNCTION: Background location upload
// //   static Future<bool> sendBackgroundLocation({
// //     required double latitude,
// //     required double longitude,
// //     required DateTime timestamp,
// //     required String token,
// //   }) async {
// //     final url = Uri.parse("$baseUrl/api/send-location");

// //     try {
// //       final response = await http.post(
// //         url,
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //         body: jsonEncode({
// //           'latitude': latitude,
// //           'longitude': longitude,
// //           'timestamp': timestamp.toIso8601String(),
// //         }),
// //       );

// //       print("📡 Location response: ${response.statusCode}");
// //       print("📄 Body: ${response.body}");

// //       if (response.statusCode == 200) {
// //         final body = json.decode(response.body);
// //         return body['success'] == true;
// //       } else {
// //         return false;
// //       }
// //     } catch (e) {
// //       print("❌ Background location upload error: $e");
// //       return false;
// //     }
// //   }
// // }






















// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:blo_tracker/models/live_entry_model.dart';
// // import 'package:http/http.dart' as http;

// // class UploadService {
// //   static const String baseUrl =
// //       "https://your-backend-api.com"; // ✅ Replace with your actual backend URL

// //   static Future<bool> uploadEntry({
// //     required File imageFile,
// //     required double latitude,
// //     required double longitude,
// //     required DateTime timeSlot,
// //     required String token,
// //   }) async {
// //     print("🛰️ Simulating backend upload...");
// //     await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

// //     // final url = Uri.parse("$baseUrl/api/upload-entry");

// //     // try {
// //     //   final request = http.MultipartRequest("POST", url)
// //     //     ..headers['Authorization'] = 'Bearer $token'
// //     //     ..fields['latitude'] = latitude.toString()
// //     //     ..fields['longitude'] = longitude.toString()
// //     //     ..fields['timeSlot'] = timeSlot.toIso8601String()
// //     //     ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

// //     //   final streamedResponse = await request.send();
// //     //   final response = await http.Response.fromStream(streamedResponse);

// //     //   print("📡 Upload response: ${response.statusCode}");
// //     //   print("📄 Body: ${response.body}");

// //     //   if (response.statusCode == 200) {
// //     //     final body = json.decode(response.body);
// //     //     return body['success'] == true;
// //     //   } else {
// //     //     return false;
// //     //   }
// //     // } catch (e) {
// //     //   print("❌ Upload failed: $e");
// //     //   return false;
// //     // }
// //     print("✅ Simulated upload complete:");
// //     print("🖼️ Image: ${imageFile.path}");
// //     print("📍 Location: $latitude, $longitude");
// //     print("⏰ TimeSlot: $timeSlot");
// //     print("🔐 Token: $token");

// //     return true; // Simulate success
// //   }
// // }

// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:http/http.dart' as http;

// // class UploadService {
// //   static const String baseUrl = "https://your-backend-api.com"; // Replace with your API
// //   static const String uploadEndpoint = "/upload-entry"; // Replace with correct endpoint

// //   static Future<bool> uploadEntry({
// //     required File imageFile,
// //     required double latitude,
// //     required double longitude,
// //     required DateTime timeSlot,
// //     required String token, // Add auth token if needed
// //   }) async {
// //     try {
// //       final uri = Uri.parse('$baseUrl$uploadEndpoint');
// //       final request = http.MultipartRequest('POST', uri);

// //       // Add authorization header
// //       request.headers['Authorization'] = 'Bearer $token';

// //       // Add form fields
// //       request.fields['latitude'] = latitude.toString();
// //       request.fields['longitude'] = longitude.toString();
// //       request.fields['timeSlot'] = timeSlot.toIso8601String();

// //       // Add image file
// //       request.files.add(await http.MultipartFile.fromPath(
// //         'image',
// //         imageFile.path,
// //       ));

// //       print('📤 Sending data to backend...');
// //       final streamedResponse = await request.send();
// //       final response = await http.Response.fromStream(streamedResponse);

// //       print('📬 Backend response: ${response.statusCode}');
// //       print('🔧 Response body: ${response.body}');

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         return data['success'] == true; // Adjust based on your API's response
// //       } else {
// //         return false;
// //       }
// //     } catch (e) {
// //       print('❌ Upload error: $e');
// //       return false;
// //     }
// //   }
// // }

// // import 'dart:io';
// // import 'package:http/http.dart' as http;
// // import 'package:http_parser/http_parser.dart';
// // import 'package:mime/mime.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class UploadService {
// //   static Future<bool> uploadEntry({
// //     required DateTime timeSlot,
// //     required double latitude,
// //     required double longitude,
// //     required File imageFile,
// //   }) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token');

// //       if (token == null) {
// //         print('❌ No token found');
// //         return false;
// //       }

// //       final uri = Uri.parse("https://your-backend.com/api/upload-entry");

// //       final request = http.MultipartRequest('POST', uri)
// //         ..headers['Authorization'] = 'Bearer $token'
// //         ..fields['timeSlot'] = timeSlot.toIso8601String()
// //         ..fields['latitude'] = latitude.toString()
// //         ..fields['longitude'] = longitude.toString();

// //       final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
// //       final mimeSplit = mimeType.split('/');

// //       request.files.add(await http.MultipartFile.fromPath(
// //         'image',
// //         imageFile.path,
// //         contentType: MediaType(mimeSplit[0], mimeSplit[1]),
// //       ));

// //       print('📡 Sending data to backend...');

// //       final response = await request.send();

// //       if (response.statusCode == 200) {
// //         print('✅ Entry uploaded successfully');
// //         return true;
// //       } else {
// //         print('❌ Upload failed: ${response.statusCode}');
// //         return false;
// //       }
// //     } catch (e) {
// //       print('❌ Exception during upload: $e');
// //       return false;
// //     }
// //   }
// // }
