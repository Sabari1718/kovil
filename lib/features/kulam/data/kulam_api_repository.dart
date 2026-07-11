import 'package:kulatheivam/core/network/api_client.dart';

class KulamApiRepository {
  final ApiClient _apiClient;

  KulamApiRepository(this._apiClient);

  // Static cache variables to share data globally across repository instances
  static List<dynamic>? _cachedCommunities;
  static List<dynamic>? _cachedSubCommunities;
  static List<dynamic>? _cachedKulas;
  static List<dynamic>? _cachedKulaDeivams;
  static List<dynamic>? _cachedVagaiyaras;
  static List<dynamic>? _cachedCommunitySelections;

  // Clear all caches when any modifying action is performed (Create/Update/Delete)
  static void clearCache() {
    _cachedCommunities = null;
    _cachedSubCommunities = null;
    _cachedKulas = null;
    _cachedKulaDeivams = null;
    _cachedVagaiyaras = null;
    _cachedCommunitySelections = null;
  }

  Future<List<dynamic>> fetchCommunities({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCommunities != null) {
      return _cachedCommunities!;
    }
    final response = await _apiClient.get('/communities');
    if (response['data'] != null && response['data']['data'] != null) {
      _cachedCommunities = response['data']['data'] as List<dynamic>;
      return _cachedCommunities!;
    }
    return [];
  }

  Future<List<dynamic>> fetchSubCommunities({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedSubCommunities != null) {
      return _cachedSubCommunities!;
    }
    final response = await _apiClient.get('/sub-communities');
    if (response['data'] != null && response['data']['data'] != null) {
      _cachedSubCommunities = response['data']['data'] as List<dynamic>;
      return _cachedSubCommunities!;
    }
    return [];
  }

  Future<List<dynamic>> fetchKulas({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedKulas != null) {
      return _cachedKulas!;
    }
    final response = await _apiClient.get('/kulas');
    if (response['data'] != null && response['data']['data'] != null) {
      _cachedKulas = response['data']['data'] as List<dynamic>;
      return _cachedKulas!;
    }
    return [];
  }

  Future<List<dynamic>> fetchKulaDeivams({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedKulaDeivams != null) {
      return _cachedKulaDeivams!;
    }
    final response = await _apiClient.get('/kula-deivams');
    if (response['data'] != null && response['data']['data'] != null) {
      _cachedKulaDeivams = response['data']['data'] as List<dynamic>;
      return _cachedKulaDeivams!;
    }
    return [];
  }

  Future<List<dynamic>> fetchVagaiyaras({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedVagaiyaras != null) {
      return _cachedVagaiyaras!;
    }
    final response = await _apiClient.get('/vagaiyaras');
    if (response['data'] != null && response['data']['data'] != null) {
      _cachedVagaiyaras = response['data']['data'] as List<dynamic>;
      return _cachedVagaiyaras!;
    }
    return [];
  }

  Future<List<dynamic>> fetchCommunitySelections({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCommunitySelections != null) {
      return _cachedCommunitySelections!;
    }
    final response = await _apiClient.get('/community-selections');
    if (response['data'] != null && response['data']['data'] != null) {
      _cachedCommunitySelections = response['data']['data'] as List<dynamic>;
      return _cachedCommunitySelections!;
    }
    return [];
  }

  Future<Map<String, dynamic>> createCommunitySelection(
    Map<String, dynamic> data,
  ) async {
    clearCache();
    final response = await _apiClient.post('/community-selection/create', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteCommunitySelection(int id) async {
    clearCache();
    final response = await _apiClient.delete('/community-selection/delete/$id');
    return response;
  }

  Future<Map<String, dynamic>> createCommunity(
    Map<String, dynamic> data,
  ) async {
    clearCache();
    final response = await _apiClient.post('/community/create', data);
    return response;
  }

  Future<Map<String, dynamic>> updateCommunity(
    int id,
    Map<String, dynamic> data,
  ) async {
    clearCache();
    final response = await _apiClient.put('/community/update/$id', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteCommunity(int id) async {
    clearCache();
    final response = await _apiClient.delete('/community/delete/$id');
    return response;
  }

  // Sub-Community APIs

  Future<Map<String, dynamic>> createSubCommunity(
    Map<String, dynamic> data,
  ) async {
    clearCache();
    final response = await _apiClient.post('/sub-community/create', data);
    return response;
  }

  Future<Map<String, dynamic>> updateSubCommunity(
    int id,
    Map<String, dynamic> data,
  ) async {
    clearCache();
    final response = await _apiClient.put('/sub-community/update/$id', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteSubCommunity(int id) async {
    clearCache();
    final response = await _apiClient.delete('/sub-community/delete/$id');
    return response;
  }

  // Kulam APIs
  Future<Map<String, dynamic>> createKula(Map<String, dynamic> data) async {
    clearCache();
    final response = await _apiClient.post('/kula/create', data);
    return response;
  }

  Future<Map<String, dynamic>> updateKula(
    int id,
    Map<String, dynamic> data,
  ) async {
    clearCache();
    final response = await _apiClient.put('/kula/update/$id', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteKula(int id) async {
    clearCache();
    final response = await _apiClient.delete('/kula/delete/$id');
    return response;
  }

  // Kula Deivam APIs

  Future<Map<String, dynamic>> createKulaDeivam(
    Map<String, dynamic> data,
  ) async {
    clearCache();
    final response = await _apiClient.post('/kula-deivam/create', data);
    return response;
  }

  Future<Map<String, dynamic>> updateKulaDeivam(
    int id,
    Map<String, dynamic> data,
  ) async {
    clearCache();
    final response = await _apiClient.put('/kula-deivam/update/$id', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteKulaDeivam(int id) async {
    clearCache();
    final response = await _apiClient.delete('/kula-deivam/delete/$id');
    return response;
  }

  // Vagaiyara APIs

  Future<Map<String, dynamic>> createVagaiyara(
    Map<String, dynamic> data,
  ) async {
    clearCache();
    final response = await _apiClient.post('/vagaiyara/create', data);
    return response;
  }

  Future<Map<String, dynamic>> updateVagaiyara(
    int id,
    Map<String, dynamic> data,
  ) async {
    clearCache();
    final response = await _apiClient.put('/vagaiyara/update/$id', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteVagaiyara(int id) async {
    clearCache();
    final response = await _apiClient.delete('/vagaiyara/delete/$id');
    return response;
  }
}
