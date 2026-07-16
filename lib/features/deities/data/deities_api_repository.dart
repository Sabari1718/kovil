import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/network/api_client.dart';

final deitiesApiRepositoryProvider = Provider<DeitiesApiRepository>((ref) {
  final apiClient = ApiClient();
  return DeitiesApiRepository(apiClient);
});

class DeitiesApiRepository {
  final ApiClient _apiClient;

  DeitiesApiRepository(this._apiClient);

  Future<bool> addMoolavar(
    Map<String, String> data,
    List<XFile> photos,
    XFile? utsavarFile,
    XFile? chariotFile,
  ) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];

      // Add main photos array
      for (var photo in photos) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes(
            'photo', // Using 'photo' as key since server parses it into array or string
            bytes,
            filename: photo.name,
          ),
        );
      }

      // Add Utsavar file
      if (utsavarFile != null) {
        final bytes = await utsavarFile.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes(
            'utsavar_file',
            bytes,
            filename: utsavarFile.name,
          ),
        );
      }

      // Add Chariot file
      if (chariotFile != null) {
        final bytes = await chariotFile.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes(
            'chariot_file',
            bytes,
            filename: chariotFile.name,
          ),
        );
      }

      final response = await _apiClient.postMultipartFiles(
        '/moolavar/create',
        data,
        multipartFiles,
      );

      final code = response['code'] ?? response['data']?['code'];
      final result = response['result'] ?? response['data']?['result'];
      if (code == 200 || result == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add moolavar: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getMoolavars() async {
    try {
      final response = await _apiClient.get(
        '/moolavar/temple/1',
      ); // Assuming temple_id 1
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
      print('Failed to fetch moolavars: $e');
      return [];
    }
  }

  Future<bool> updateMoolavar(
    int id,
    Map<String, String> data,
    List<XFile> photos,
    XFile? utsavarFile,
    XFile? chariotFile,
  ) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];

      for (var photo in photos) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }

      if (utsavarFile != null) {
        final bytes = await utsavarFile.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes(
            'utsavar_file',
            bytes,
            filename: utsavarFile.name,
          ),
        );
      }

      if (chariotFile != null) {
        final bytes = await chariotFile.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes(
            'chariot_file',
            bytes,
            filename: chariotFile.name,
          ),
        );
      }

      final response = await _apiClient.putMultipartFiles(
        '/moolavar/update/$id',
        data,
        multipartFiles,
      );

      final code = response['code'] ?? response['data']?['code'];
      final result = response['result'] ?? response['data']?['result'];
      if (code == 200 || result == 'Success') {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update moolavar: $e');
      return false;
    }
  }

  Future<bool> deleteMoolavar(int id) async {
    try {
      try {
        final response = await _apiClient.delete('/moolavar/delete/$id');
        if (response['code'] == 200 ||
            response['result'] == 'Success' ||
            response['data']?['code'] == 200) {
          return true;
        }
      } catch (_) {
        try {
          final response = await _apiClient.post(
            '/moolavar/$id?_method=DELETE',
            {},
          );
          if (response['code'] == 200 ||
              response['result'] == 'Success' ||
              response['data']?['code'] == 200) {
            return true;
          }
        } catch (_) {
          final response = await _apiClient.delete('/moolavar/$id');
          if (response['code'] == 200 ||
              response['result'] == 'Success' ||
              response['data']?['code'] == 200) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('Failed to delete moolavar: $e');
      return false;
    }
  }

  // ==========================================
  // PARIVARA DEIVANGAL APIS
  // ==========================================

  Future<Map<String, dynamic>> fetchParivaraDeivams() async {
    try {
      final response = await _apiClient.get(
        '/parivara_deivangal/temple/1',
      ); // Assuming temple_id 1
      return response;
    } catch (e) {
      print('Failed to fetch parivara deivangal: $e');
      return {};
    }
  }

  Future<bool> addParivaraDeivam(Map<String, String> data, XFile? photo) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.postMultipartFiles(
        '/parivara_deivangal/save',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add parivara deivam: $e');
      return false;
    }
  }

  Future<bool> updateParivaraDeivam(
    int id,
    Map<String, String> data,
    XFile? photo,
  ) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.putMultipartFiles(
        '/parivara_deivangal/update/$id',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update parivara deivam: $e');
      return false;
    }
  }

  Future<bool> deleteParivaraDeivam(int id) async {
    try {
      final response = await _apiClient.delete('/parivara_deivangal/$id');
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete parivara deivam: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPigaraDeivams() async {
    try {
      final response = await _apiClient.get('/pigara_deivangal/temple/1');
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch pigara deivams: $e');
      return [];
    }
  }

  Future<bool> addPigaraDeivam(Map<String, String> data, XFile? photo) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.postMultipartFiles(
        '/pigara_deivangal/save',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add pigara deivam: $e');
      return false;
    }
  }

  Future<bool> updatePigaraDeivam(
    int id,
    Map<String, String> data,
    XFile? photo,
  ) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.putMultipartFiles(
        '/pigara_deivangal/update/$id',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update pigara deivam: $e');
      return false;
    }
  }

  Future<bool> deletePigaraDeivam(int id) async {
    try {
      final response = await _apiClient.delete('/pigara_deivangal/$id');
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete pigara deivam: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUbaDeivams() async {
    try {
      final response = await _apiClient.get('/uba_deivangal/temple/1');
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch uba deivams: $e');
      return [];
    }
  }

  Future<bool> addUbaDeivam(Map<String, String> data, XFile? photo) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.postMultipartFiles(
        '/uba_deivangal/save',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add uba deivam: $e');
      return false;
    }
  }

  Future<bool> updateUbaDeivam(
    int id,
    Map<String, String> data,
    XFile? photo,
  ) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.putMultipartFiles(
        '/uba_deivangal/update/$id',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update uba deivam: $e');
      return false;
    }
  }

  Future<bool> deleteUbaDeivam(int id) async {
    try {
      final response = await _apiClient.delete('/uba_deivangal/$id');
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete uba deivam: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getKavalDeivams() async {
    try {
      final response = await _apiClient.get('/kaval_deivangal/temple/1');
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch kaval deivams: $e');
      return [];
    }
  }

  Future<bool> addKavalDeivam(Map<String, String> data, XFile? photo) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.postMultipartFiles(
        '/kaval_deivangal/save',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add kaval deivam: $e');
      return false;
    }
  }

  Future<bool> updateKavalDeivam(
    int id,
    Map<String, String> data,
    XFile? photo,
  ) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.putMultipartFiles(
        '/kaval_deivangal/update/$id',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update kaval deivam: $e');
      return false;
    }
  }

  Future<bool> deleteKavalDeivam(int id) async {
    try {
      final response = await _apiClient.delete('/kaval_deivangal/$id');
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete kaval deivam: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getBaliDeivams() async {
    try {
      final response = await _apiClient.get('/bali_deivangal/temple/1');
      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('Failed to fetch bali deivams: $e');
      return [];
    }
  }

  Future<bool> addBaliDeivam(Map<String, String> data, XFile? photo) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.postMultipartFiles(
        '/bali_deivangal/save',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add bali deivam: $e');
      return false;
    }
  }

  Future<bool> updateBaliDeivam(
    int id,
    Map<String, String> data,
    XFile? photo,
  ) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.putMultipartFiles(
        '/bali_deivangal/update/$id',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update bali deivam: $e');
      return false;
    }
  }

  Future<bool> deleteBaliDeivam(int id) async {
    try {
      final response = await _apiClient.delete('/bali_deivangal/$id');
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete bali deivam: $e');
      return false;
    }
  }

  // ==========================================
  // KOVIL DEIVANGAL APIS
  // ==========================================

  Future<Map<String, dynamic>> fetchKovilDeivangal() async {
    try {
      final response = await _apiClient.get('/kovil_deivangal/temple/1');
      return response;
    } catch (e) {
      print('Failed to fetch kovil deivangal: $e');
      return {};
    }
  }

  Future<bool> addKovilDeivangal(Map<String, String> data, XFile? photo, {Map<String, Uint8List>? extraImages}) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      if (extraImages != null) {
        for (var entry in extraImages.entries) {
          multipartFiles.add(
            http.MultipartFile.fromBytes(entry.key, entry.value.toList(), filename: '${entry.key}.jpg'),
          );
        }
      }
      final response = await _apiClient.postMultipartFiles(
        '/kovil_deivangal/save',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add kovil deivangal: $e');
      return false;
    }
  }

  Future<bool> updateKovilDeivangal(
    int id,
    Map<String, String> data,
    XFile? photo,
  ) async {
    try {
      final List<http.MultipartFile> multipartFiles = [];
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }
      final response = await _apiClient.postMultipartFiles(
        '/kovil_deivangal/update/$id',
        data,
        multipartFiles,
      );
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to update kovil deivangal: $e');
      return false;
    }
  }

  Future<bool> deleteKovilDeivangal(int id) async {
    try {
      final response = await _apiClient.delete('/kovil_deivangal/$id');
      if (response['code'] == 200 ||
          response['result'] == 'Success' ||
          response['data']?['code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to delete kovil deivangal: $e');
      return false;
    }
  }
}
