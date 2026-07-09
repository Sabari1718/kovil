import 'dart:convert';
import 'dart:io';
import '../../../core/network/api_client.dart';

class PoojaiApiRepository {
  final ApiClient _apiClient;

  PoojaiApiRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getNithiyaPoojais() async {
    try {
      final response = await _apiClient.get('/nitya_poojas/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch nithiya poojas: $e');
      return [];
    }
  }

  Future<bool> addNithiyaPoojai(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/nitya_poojas/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add nithiya pooja: $e');
      return false;
    }
  }

  Future<bool> updateNithiyaPoojai(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/nitya_poojas/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update nithiya pooja: $e');
      return false;
    }
  }

  Future<bool> deleteNithiyaPoojai(int id) async {
    try {
      final response = await _apiClient.delete('/nitya_poojas/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete nithiya pooja: $e');
      return false;
    }
  }

  // --- Kilamai Poojas (Weekly Rituals) ---

  Future<List<Map<String, dynamic>>> getKilamaiPoojais() async {
    try {
      final response = await _apiClient.get('/kilamai_poojas/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch kilamai poojas: $e');
      return [];
    }
  }

  Future<bool> addKilamaiPoojai(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/kilamai_poojas/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add kilamai pooja: $e');
      return false;
    }
  }

  Future<bool> updateKilamaiPoojai(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/kilamai_poojas/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update kilamai pooja: $e');
      return false;
    }
  }

  Future<bool> deleteKilamaiPoojai(int id) async {
    try {
      final response = await _apiClient.delete('/kilamai_poojas/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete kilamai pooja: $e');
      return false;
    }
  }

  // --- Special Poojas (சிறப்பு பூஜைகள்) ---

  Future<List<Map<String, dynamic>>> getSpecialPoojais() async {
    try {
      final response = await _apiClient.get('/special_poojas/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch special poojas: $e');
      return [];
    }
  }

  Future<bool> addSpecialPoojai(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/special_poojas/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add special pooja: $e');
      return false;
    }
  }

  Future<bool> updateSpecialPoojai(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/special_poojas/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update special pooja: $e');
      return false;
    }
  }

  Future<bool> deleteSpecialPoojai(int id) async {
    try {
      final response = await _apiClient.delete('/special_poojas/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete special pooja: $e');
      return false;
    }
  }

  // --- Thodar Poojais (தொடர் பூஜை / திருவிழாக்கள்) ---

  Future<List<Map<String, dynamic>>> getThodarPoojais() async {
    try {
      final response = await _apiClient.get('/thodar_poojai/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch thodar poojas: $e');
      return [];
    }
  }

  Future<bool> addThodarPoojai(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      final response = imageFile != null
          ? await _apiClient.postMultipart(
              '/thodar_poojai/create',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.post('/thodar_poojai/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add thodar pooja: $e');
      return false;
    }
  }

  Future<bool> updateThodarPoojai(
    int id,
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      final response = imageFile != null
          ? await _apiClient.putMultipart(
              '/thodar_poojai/update/$id',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.put('/thodar_poojai/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update thodar pooja: $e');
      return false;
    }
  }

  Future<bool> deleteThodarPoojai(int id) async {
    try {
      final response = await _apiClient.delete('/thodar_poojai/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete thodar pooja: $e');
      return false;
    }
  }

  // --- Visucam Neram (விஷூசம் / விசேஷங்கள்) ---

  Future<List<Map<String, dynamic>>> getVisucamNeram() async {
    try {
      final response = await _apiClient.get('/visucam_neram/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch visucam neram: $e');
      return [];
    }
  }

  Future<bool> addVisucamNeram(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      final response = imageFile != null
          ? await _apiClient.postMultipart(
              '/visucam_neram/create',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.post('/visucam_neram/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add visucam neram: $e');
      return false;
    }
  }

  Future<bool> updateVisucamNeram(
    int id,
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      final response = imageFile != null
          ? await _apiClient.putMultipart(
              '/visucam_neram/update/$id',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.put('/visucam_neram/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update visucam neram: $e');
      return false;
    }
  }

  Future<bool> deleteVisucamNeram(int id) async {
    try {
      final response = await _apiClient.delete('/visucam_neram/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete visucam neram: $e');
      return false;
    }
  }
}
