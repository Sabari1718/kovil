import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://temple.jobes24x7.com/api';

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = '$baseUrl$endpoint';
    debugPrint('========== API REQUEST ==========');
    debugPrint('URL: POST $url');
    debugPrint('Payload: $body');
    debugPrint('=================================');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('========== API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      debugPrint('==================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = '$baseUrl$endpoint';
    debugPrint('========== API REQUEST ==========');
    debugPrint('URL: GET $url');
    debugPrint('=================================');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('========== API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      debugPrint('==================================');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = '$baseUrl$endpoint';
    debugPrint('========== API REQUEST ==========');
    debugPrint('URL: PUT $url');
    debugPrint('Payload: $body');
    debugPrint('=================================');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('========== API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      debugPrint('==================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final url = '$baseUrl$endpoint';
    debugPrint('========== API REQUEST ==========');
    debugPrint('URL: DELETE $url');
    debugPrint('=================================');

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('========== API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      debugPrint('==================================');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return {'success': true};
      } else {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    String? fileKey,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final url = '$baseUrl$endpoint';
    debugPrint('========== API REQUEST ==========');
    debugPrint('URL: POST $url (Multipart)');
    debugPrint('Fields: $fields');
    if (fileName != null) debugPrint('File: $fileName');
    debugPrint('=================================');

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(fields);

      if (fileKey != null && fileBytes != null && fileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(fileKey, fileBytes, filename: fileName),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('========== API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      debugPrint('==================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> putMultipart(
    String endpoint,
    Map<String, String> fields, {
    String? fileKey,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final url = '$baseUrl$endpoint';
    debugPrint('========== API REQUEST ==========');
    debugPrint('URL: PUT $url (Multipart)');
    debugPrint('Fields: $fields');
    if (fileName != null) debugPrint('File: $fileName');
    debugPrint('=================================');

    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));
      request.fields.addAll(fields);

      if (fileKey != null && fileBytes != null && fileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(fileKey, fileBytes, filename: fileName),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('========== API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      debugPrint('==================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> postMultipartFiles(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final url = '$baseUrl$endpoint';
    debugPrint('========== API REQUEST ==========');
    debugPrint('URL: POST $url (Multipart Multiple)');
    debugPrint('Fields: $fields');
    debugPrint('Files Count: ${files.length}');
    debugPrint('=================================');

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(fields);
      request.files.addAll(files);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('========== API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      debugPrint('==================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> putMultipartFiles(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final url = '$baseUrl$endpoint';
    debugPrint('========== API REQUEST ==========');
    debugPrint('URL: PUT $url (Multipart Multiple)');
    debugPrint('Fields: $fields');
    debugPrint('Files Count: ${files.length}');
    debugPrint('=================================');

    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));
      request.fields.addAll(fields);
      request.files.addAll(files);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('========== API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      debugPrint('==================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }
}
