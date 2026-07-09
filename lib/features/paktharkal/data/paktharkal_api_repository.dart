import 'dart:convert';
import 'dart:io';
import '../../../core/network/api_client.dart';

class PaktharkalApiRepository {
  final ApiClient _apiClient;

  PaktharkalApiRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getNerttiKatan() async {
    try {
      final response = await _apiClient.get('/nertti_katan/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch nertti_katan: $e');
      return [];
    }
  }

  Future<bool> addNerttiKatan(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      final response = imageFile != null
          ? await _apiClient.postMultipart(
              '/nertti_katan/create',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.post('/nertti_katan/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add nertti_katan: $e');
      return false;
    }
  }

  Future<bool> updateNerttiKatan(
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
              '/nertti_katan/update/$id',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.put('/nertti_katan/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update nertti_katan: $e');
      return false;
    }
  }

  Future<bool> deleteNerttiKatan(int id) async {
    try {
      final response = await _apiClient.delete('/nertti_katan/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete nertti_katan: $e');
      return false;
    }
  }

  // --- Kullam People ---
  Future<List<Map<String, dynamic>>> getKullamPeople() async {
    try {
      final response = await _apiClient.get('/kullam_people');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch kullam_people: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getVagaiyaras() async {
    try {
      final response = await _apiClient.get('/vagaiyaras');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch vagaiyaras: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getKulaDeivams() async {
    try {
      final response = await _apiClient.get('/kula-deivams');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch kula_deivams: $e');
      return [];
    }
  }

  Future<bool> addKullamPeople(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/kullam_people/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add kullam_people: $e');
      return false;
    }
  }

  Future<bool> updateKullamPeople(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/kullam_people/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update kullam_people: $e');
      return false;
    }
  }

  Future<bool> deleteKullamPeople(int id) async {
    try {
      final response = await _apiClient.delete('/kullam_people/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete kullam_people: $e');
      return false;
    }
  }

  // --- Kattali ---
  Future<List<Map<String, dynamic>>> getKattali() async {
    try {
      final response = await _apiClient.get('/kattali');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch kattali: $e');
      return [];
    }
  }

  Future<bool> addKattali(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/kattali/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add kattali: $e');
      return false;
    }
  }

  Future<bool> updateKattali(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/kattali/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update kattali: $e');
      return false;
    }
  }

  Future<bool> deleteKattali(int id) async {
    try {
      final response = await _apiClient.delete('/kattali/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete kattali: $e');
      return false;
    }
  }
}
