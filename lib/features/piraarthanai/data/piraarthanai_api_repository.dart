import 'dart:convert';
import 'dart:io';
import '../../../core/network/api_client.dart';

class PiraarthanaiApiRepository {
  final ApiClient _apiClient;

  PiraarthanaiApiRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getKuraiNivarthi() async {
    try {
      final response = await _apiClient.get('/kurai_nivarthi/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch kurai nivarthi: $e');
      return [];
    }
  }

  Future<bool> addKuraiNivarthi(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      final response = imageFile != null
          ? await _apiClient.postMultipart(
              '/kurai_nivarthi/create',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.post('/kurai_nivarthi/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add kurai nivarthi: $e');
      return false;
    }
  }

  Future<bool> updateKuraiNivarthi(
    int id,
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      final response = imageFile != null
          ? await _apiClient.putMultipart(
              '/kurai_nivarthi/update/$id',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.put('/kurai_nivarthi/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update kurai nivarthi: $e');
      return false;
    }
  }

  Future<bool> deleteKuraiNivarthi(int id) async {
    try {
      final response = await _apiClient.delete('/kurai_nivarthi/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete kurai nivarthi: $e');
      return false;
    }
  }
}
