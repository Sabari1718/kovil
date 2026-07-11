import 'package:kulatheivam/core/network/api_client.dart';
import 'kovil_dropdown_models.dart';
import 'package:image_picker/image_picker.dart';

class KovilApiRepository {
  final ApiClient _apiClient;

  KovilApiRepository(this._apiClient);

  Future<List<SectorModel>> getSectors() async {
    try {
      final response = await _apiClient.get('/outsideapis/sectors');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final allSectors = data
            .map((json) => SectorModel.fromJson(json))
            .toList();
        return allSectors
            .where(
              (s) => s.sectorTitleId == 63 || s.sectorTitleName == 'Devotees',
            )
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch sectors: $e');
    }
  }

  Future<List<SubSectorModel>> getSubSectors() async {
    try {
      final response = await _apiClient.get('/outsideapis/sub-sectors');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => SubSectorModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch sub-sectors: $e');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get('/outsideapis/categories');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<int?> addTemple(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/temple_basic_detail/create',
        data,
      );

      if (response['data'] != null && response['data'] is Map) {
        if (response['data']['result'] == 'Success' ||
            response['data']['code'] == 200) {
          return response['data']['data']?['id'];
        }
      }

      if (response['result'] == 'Success' || response['code'] == 200) {
        return response['data']?['id'];
      }
      return null;
    } catch (e) {
      throw Exception('Failed to add temple: $e');
    }
  }

  Future<Map<String, dynamic>?> getBasicDetail(int id) async {
    try {
      final response = await _apiClient.get('/temple_detail/basic/$id');
      if (response['data'] != null && response['data'] is Map) {
        final dataMap = response['data'];
        if ((dataMap['code'] == 200 || dataMap['result'] == 'Success') &&
            dataMap['data'] != null) {
          final detailData = dataMap['data'];
          if (detailData is List && detailData.isNotEmpty) {
            return Map<String, dynamic>.from(detailData[0]);
          } else if (detailData is Map) {
            return Map<String, dynamic>.from(detailData);
          }
        }
      }
      return null;
    } catch (e) {
      print('Failed to fetch basic detail: $e');
      return null;
    }
  }

  Future<bool> addTempleDetails(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/temple_detail/create', data);
      if (response['data'] != null && response['data'] is Map) {
        final dataMap = response['data'];
        if (dataMap['code'] == 200 || dataMap['result'] == 'Success') {
          return true;
        }
      }
      return response['code'] == 200 || response['success'] == true;
    } catch (e) {
      print('Failed to add temple details: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getTempleDetails() async {
    try {
      final response = await _apiClient.get('/temple_details');
      if (response['data'] != null) {
        final dataMap = response['data'];
        if ((dataMap['code'] == 200 || dataMap['result'] == 'Success') &&
            dataMap['data'] != null) {
          if (dataMap['data'] is List) {
            return List<Map<String, dynamic>>.from(dataMap['data']);
          }
        }
      }
      return [];
    } catch (e) {
      print('Failed to fetch temple details: $e');
      return [];
    }
  }

  Future<bool> updateTempleDetails(int id, Map<String, dynamic> data) async {
    try {
      // Best guess for the update endpoint based on common patterns.
      // If the API uses PUT, change this to .put()
      final response = await _apiClient.put('/temple_detail/update/$id', data);

      // Handle nested success format if present
      if (response['data'] != null && response['data'] is Map) {
        final dataMap = response['data'];
        if (dataMap['code'] == 200 || dataMap['result'] == 'Success') {
          return true;
        }
      }
      return response['code'] == 200 || response['success'] == true;
    } catch (e) {
      print('Failed to update temple details: $e');
      return false;
    }
  }

  Future<bool> deleteTempleDetails(int id) async {
    try {
      // Correct endpoint as per the network tab screenshot
      final response = await _apiClient.delete('/temple_detail/delete/$id');
      
      final code = response['code'] ?? response['data']?['code'];
      final result = response['result'] ?? response['data']?['result'];
      if (code == 200 || result == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete temple details: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTempleAddressContact() async {
    try {
      final response = await _apiClient.get('/temple_address_contact');
      if (response['data'] != null) {
        final dataMap = response['data'];
        if ((dataMap['code'] == 200 || dataMap['result'] == 'Success') &&
            dataMap['data'] != null) {
          if (dataMap['data'] is List && dataMap['data'].isNotEmpty) {
            return dataMap['data'][0];
          }
        }
      }
      return null;
    } catch (e) {
      print('Failed to fetch temple address: $e');
      return null;
    }
  }

  Future<bool> updateTempleAddressContact(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '/temple_address_contact/update/$id',
        data,
      );
      if (response['data'] != null && response['data'] is Map) {
        final dataMap = response['data'];
        if (dataMap['code'] == 200 || dataMap['result'] == 'Success') {
          return true;
        }
      }
      return response['code'] == 200 || response['success'] == true;
    } catch (e) {
      print('Failed to update temple address: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTakaval() async {
    try {
      final response = await _apiClient.get('/takaval');
      if (response['data'] != null) {
        final dataMap = response['data'];
        if ((dataMap['code'] == 200 || dataMap['result'] == 'Success') &&
            dataMap['data'] != null) {
          if (dataMap['data'] is List && dataMap['data'].isNotEmpty) {
            return dataMap['data'][0];
          }
        }
      }
      return null;
    } catch (e) {
      print('Failed to fetch takaval: $e');
      return null;
    }
  }

  Future<bool> updateTakaval(
    int id,
    Map<String, String> data, {
    XFile? imageFile,
  }) async {
    try {
      List<int>? fileBytes;
      String? fileName;
      if (imageFile != null) {
        fileBytes = await imageFile.readAsBytes();
        fileName = imageFile.name;
      }

      final response = await _apiClient.putMultipart(
        '/takaval/update/$id',
        data,
        fileKey: 'image',
        fileBytes: fileBytes,
        fileName: fileName,
      );

      final code = response['code'] ?? response['data']?['code'];
      final result = response['result'] ?? response['data']?['result'];
      if (code == 200 || result == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update takaval: $e');
      return false;
    }
  }

  Future<bool> addTempleHistory(
    Map<String, String> data, {
    XFile? imageFile,
  }) async {
    try {
      List<int>? fileBytes;
      String? fileName;
      if (imageFile != null) {
        fileBytes = await imageFile.readAsBytes();
        fileName = imageFile.name;
      }

      final response = await _apiClient.postMultipart(
        '/temple_history/create',
        data,
        fileKey: 'photo_path',
        fileBytes: fileBytes,
        fileName: fileName,
      );

      final code = response['code'] ?? response['data']?['code'];
      final result = response['result'] ?? response['data']?['result'];
      if (code == 200 || result == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add temple history: $e');
      return false;
    }
  }

  Future<bool> updateTempleHistory(
    int id,
    Map<String, String> data, {
    XFile? imageFile,
  }) async {
    try {
      String? fileKey;
      List<int>? fileBytes;
      String? fileName;

      final response = imageFile != null
          ? await _apiClient.putMultipart(
              '/temple_history/update/$id',
              data,
              fileKey: 'photo',
              fileBytes: await imageFile.readAsBytes(),
              fileName: imageFile.path.split('/').last.split('\\').last,
            )
          : await _apiClient.put('/temple_history/update/$id', data);

      final code = response['code'] ?? response['data']?['code'];
      final result = response['result'] ?? response['data']?['result'];
      if (code == 200 || result == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update temple history: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getTempleHistories() async {
    try {
      final response = await _apiClient.get('/temple_histories');
      if (response['data'] != null) {
        if (response['data'] is List) {
          return List<Map<String, dynamic>>.from(
            response['data'].map((e) => Map<String, dynamic>.from(e)),
          );
        } else if (response['data'] is Map &&
            response['data']['data'] is List) {
          return List<Map<String, dynamic>>.from(
            response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
          );
        }
      }
      return [];
    } catch (e) {
      print('Failed to fetch temple histories: $e');
      return [];
    }
  }

  Future<bool> deleteTempleHistory(int id) async {
    try {
      try {
        final response = await _apiClient.delete('/temple_history/$id');
        return true;
      } catch (e) {
        final response = await _apiClient.get('/temple_history/delete/$id');
        return true;
      }
    } catch (e) {
      print('Failed to delete temple history: $e');
      return false;
    }
  }

  Future<bool> addKudamuzhukku(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/kudamuzhukku/create', data);
      final code = response['code'] ?? response['data']?['code'];
      final result = response['result'] ?? response['data']?['result'];
      if (code == 200 || result == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add kudamuzhukku: $e');
      return false;
    }
  }

  Future<bool> updateKudamuzhukku(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/kudamuzhukku/update/$id', data);
      final code = response['code'] ?? response['data']?['code'];
      final result = response['result'] ?? response['data']?['result'];
      if (code == 200 || result == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update kudamuzhukku: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getKudamuzhukkus() async {
    try {
      final response = await _apiClient.get('/kudamuzhukkus');
      if (response['data'] != null) {
        if (response['data'] is List) {
          return List<Map<String, dynamic>>.from(
            response['data'].map((e) => Map<String, dynamic>.from(e)),
          );
        } else if (response['data'] is Map &&
            response['data']['data'] is List) {
          return List<Map<String, dynamic>>.from(
            response['data']['data'].map((e) => Map<String, dynamic>.from(e)),
          );
        }
      }
      return [];
    } catch (e) {
      print('Failed to fetch kudamuzhukkus: $e');
      return [];
    }
  }

  Future<bool> deleteKudamuzhukku(int id) async {
    try {
      try {
        await _apiClient.delete('/kudamuzhukku/$id');
        return true;
      } catch (e) {
        await _apiClient.get('/kudamuzhukku/delete/$id');
        return true;
      }
    } catch (e) {
      print('Failed to delete kudamuzhukku: $e');
      return false;
    }
  }

  Future<List<CommunityModel>> getCommunities() async {
    try {
      final response = await _apiClient.get('/communities');
      final list = _extractListFromResponse(response);
      return list.map((json) => CommunityModel.fromJson(json)).toList();
    } catch (e) {
      print('Failed to fetch communities: $e');
      return [];
    }
  }

  Future<List<SubCommunityModel>> getSubCommunities() async {
    try {
      final response = await _apiClient.get('/sub-communities');
      final list = _extractListFromResponse(response);
      return list.map((json) => SubCommunityModel.fromJson(json)).toList();
    } catch (e) {
      print('Failed to fetch sub-communities: $e');
      return [];
    }
  }

  Future<List<KulamModel>> getKulas() async {
    try {
      final response = await _apiClient.get('/kulas');
      final list = _extractListFromResponse(response);
      return list.map((json) => KulamModel.fromJson(json)).toList();
    } catch (e) {
      print('Failed to fetch kulas: $e');
      return [];
    }
  }

  Future<List<KulaDeivamModel>> getKulaDeivams() async {
    try {
      final response = await _apiClient.get('/kula-deivams');
      final list = _extractListFromResponse(response);
      return list.map((json) => KulaDeivamModel.fromJson(json)).toList();
    } catch (e) {
      print('Failed to fetch kula-deivams: $e');
      return [];
    }
  }

  Future<List<VagaiyaraModel>> getVagaiyaras() async {
    try {
      final response = await _apiClient.get('/vagaiyaras');
      final list = _extractListFromResponse(response);
      return list.map((json) => VagaiyaraModel.fromJson(json)).toList();
    } catch (e) {
      print('Failed to fetch vagaiyaras: $e');
      return [];
    }
  }

  Future<List<SectorModel>> getDeitySectors() async {
    try {
      final response = await _apiClient.get('/outsideapis/deity-sectors');
      final list = _extractListFromResponse(response);
      return list.map((json) => SectorModel.fromJson(json)).toList();
    } catch (e) {
      print('Failed to fetch deity-sectors: $e');
      return [];
    }
  }

  List<dynamic> _extractListFromResponse(Map<String, dynamic> response) {
    if (response['data'] != null && response['data'] is Map) {
      final dataMap = response['data'];
      if ((dataMap['code'] == 200 || dataMap['result'] == 'Success') &&
          dataMap['data'] != null) {
        if (dataMap['data'] is List) {
          return dataMap['data'];
        }
      }
    }
    if (response['code'] == 200 || response['success'] == true) {
      if (response['data'] is List) {
        return response['data'];
      }
    }
    return [];
  }
}
