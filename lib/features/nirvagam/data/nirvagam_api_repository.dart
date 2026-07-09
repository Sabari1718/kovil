import 'dart:convert';
import 'dart:io';
import '../../../core/network/api_client.dart';

class NirvagamApiRepository {
  final ApiClient _apiClient;

  NirvagamApiRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getTharumakatha() async {
    try {
      final response = await _apiClient.get('/tharumakatha/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch tharumakatha: $e');
      return [];
    }
  }

  Future<bool> addTharumakatha(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      final response = imageFile != null
          ? await _apiClient.postMultipart(
              '/tharumakatha/create',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.post('/tharumakatha/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add tharumakatha: $e');
      return false;
    }
  }

  Future<bool> updateTharumakatha(
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
              '/tharumakatha/update/$id',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.put('/tharumakatha/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update tharumakatha: $e');
      return false;
    }
  }

  Future<bool> deleteTharumakatha(int id) async {
    try {
      final response = await _apiClient.delete('/tharumakatha/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete tharumakatha: $e');
      return false;
    }
  }

  // --- Donors & Volunteers ---
  Future<List<Map<String, dynamic>>> getDonorsVolunteers() async {
    try {
      final response = await _apiClient.get('/donors-volunteers/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch donors & volunteers: $e');
      return [];
    }
  }

  Future<bool> addDonorVolunteer(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      final response = imageFile != null
          ? await _apiClient.postMultipart(
              '/donors-volunteers',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.post('/donors-volunteers', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add donor/volunteer: $e');
      return false;
    }
  }

  Future<bool> updateDonorVolunteer(
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
              '/donors-volunteers/$id',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.put('/donors-volunteers/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update donor/volunteer: $e');
      return false;
    }
  }

  Future<bool> deleteDonorVolunteer(int id) async {
    try {
      final response = await _apiClient.delete('/donors-volunteers/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete donor/volunteer: $e');
      return false;
    }
  }

  // --- Aranilaiyatturai (Religious Endowments) ---
  Future<List<Map<String, dynamic>>> getAranilaiyatturai() async {
    try {
      final response = await _apiClient.get('/aranilaiyatturai/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch aranilaiyatturai: $e');
      return [];
    }
  }

  Future<bool> addAranilaiyatturai(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      final response = imageFile != null
          ? await _apiClient.postMultipart(
              '/aranilaiyatturai/create',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.post('/aranilaiyatturai/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add aranilaiyatturai: $e');
      return false;
    }
  }

  Future<bool> updateAranilaiyatturai(
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
              '/aranilaiyatturai/update/$id',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.put('/aranilaiyatturai/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update aranilaiyatturai: $e');
      return false;
    }
  }

  Future<bool> deleteAranilaiyatturai(int id) async {
    try {
      final response = await _apiClient.delete('/aranilaiyatturai/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete aranilaiyatturai: $e');
      return false;
    }
  }

  // --- Porulatar (Economy) ---
  Future<List<Map<String, dynamic>>> getPorulatar() async {
    try {
      final response = await _apiClient.get('/porulatar/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch porulatar: $e');
      return [];
    }
  }

  Future<bool> addPorulatar(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/porulatar/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add porulatar: $e');
      return false;
    }
  }

  Future<bool> updatePorulatar(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/porulatar/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update porulatar: $e');
      return false;
    }
  }

  Future<bool> deletePorulatar(int id) async {
    try {
      final response = await _apiClient.delete('/porulatar/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete porulatar: $e');
      return false;
    }
  }

  // --- Annatanam ---
  Future<List<Map<String, dynamic>>> getAnnatanam() async {
    try {
      final response = await _apiClient.get('/annatanam/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch annatanam: $e');
      return [];
    }
  }

  Future<bool> addAnnatanam(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      final response = imageFile != null
          ? await _apiClient.postMultipart(
              '/annatanam/create',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.post('/annatanam/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add annatanam: $e');
      return false;
    }
  }

  Future<bool> updateAnnatanam(
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
              '/annatanam/update/$id',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.put('/annatanam/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update annatanam: $e');
      return false;
    }
  }

  Future<bool> deleteAnnatanam(int id) async {
    try {
      final response = await _apiClient.delete('/annatanam/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete annatanam: $e');
      return false;
    }
  }

  // --- Visucam (Committee / Bhakthargal Kuzhu) ---
  Future<List<Map<String, dynamic>>> getVisucam() async {
    try {
      final response = await _apiClient.get('/visucam/temple/1');
      if (response['data'] != null && response['data']['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch visucam: $e');
      return [];
    }
  }

  Future<bool> addVisucam(Map<String, dynamic> data, {File? imageFile}) async {
    try {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      final response = imageFile != null
          ? await _apiClient.postMultipart(
              '/visucam/create',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.post('/visucam/create', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add visucam: $e');
      return false;
    }
  }

  Future<bool> updateVisucam(
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
              '/visucam/update/$id',
              stringData,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.put('/visucam/update/$id', data);
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update visucam: $e');
      return false;
    }
  }

  Future<bool> deleteVisucam(int id) async {
    try {
      final response = await _apiClient.delete('/visucam/delete/$id');
      if (response['data']?['code'] == 200 ||
          response['code'] == 200 ||
          response['data']?['result'] == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete visucam: $e');
      return false;
    }
  }
}
