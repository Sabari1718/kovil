import 'package:kulatheivam/core/network/api_client.dart';

class KulamApiRepository {
  final ApiClient _apiClient;

  KulamApiRepository(this._apiClient);

  Future<List<dynamic>> fetchCommunities() async {
    final response = await _apiClient.get('/communities');
    if (response['data'] != null && response['data']['data'] != null) {
      return response['data']['data'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> fetchSubCommunities() async {
    final response = await _apiClient.get('/sub-communities');
    if (response['data'] != null && response['data']['data'] != null) {
      return response['data']['data'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> fetchKulas() async {
    final response = await _apiClient.get('/kulas');
    if (response['data'] != null && response['data']['data'] != null) {
      return response['data']['data'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> fetchKulaDeivams() async {
    final response = await _apiClient.get('/kula-deivams');
    if (response['data'] != null && response['data']['data'] != null) {
      return response['data']['data'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> fetchVagaiyaras() async {
    final response = await _apiClient.get('/vagaiyaras');
    if (response['data'] != null && response['data']['data'] != null) {
      return response['data']['data'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> fetchCommunitySelections() async {
    final response = await _apiClient.get('/community-selections');
    if (response['data'] != null && response['data']['data'] != null) {
      return response['data']['data'] as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> createCommunitySelection(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post('/community-selection/create', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteCommunitySelection(int id) async {
    final response = await _apiClient.delete('/community-selection/delete/$id');
    return response;
  }

  Future<Map<String, dynamic>> createCommunity(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post('/community/create', data);
    return response;
  }

  Future<Map<String, dynamic>> updateCommunity(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put('/community/update/$id', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteCommunity(int id) async {
    final response = await _apiClient.delete('/community/delete/$id');
    return response;
  }

  // Sub-Community APIs

  Future<Map<String, dynamic>> createSubCommunity(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post('/sub-community/create', data);
    return response;
  }

  Future<Map<String, dynamic>> updateSubCommunity(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put('/sub-community/update/$id', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteSubCommunity(int id) async {
    final response = await _apiClient.delete('/sub-community/delete/$id');
    return response;
  }

  // Kulam APIs
  Future<Map<String, dynamic>> createKula(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/kula/create', data);
    return response;
  }

  Future<Map<String, dynamic>> updateKula(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put('/kula/update/$id', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteKula(int id) async {
    final response = await _apiClient.delete('/kula/delete/$id');
    return response;
  }

  // Kula Deivam APIs

  Future<Map<String, dynamic>> createKulaDeivam(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post('/kula-deivam/create', data);
    return response;
  }

  Future<Map<String, dynamic>> updateKulaDeivam(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put('/kula-deivam/update/$id', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteKulaDeivam(int id) async {
    final response = await _apiClient.delete('/kula-deivam/delete/$id');
    return response;
  }

  // Vagaiyara APIs

  Future<Map<String, dynamic>> createVagaiyara(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post('/vagaiyara/create', data);
    return response;
  }

  Future<Map<String, dynamic>> updateVagaiyara(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put('/vagaiyara/update/$id', data);
    return response;
  }

  Future<Map<String, dynamic>> deleteVagaiyara(int id) async {
    final response = await _apiClient.delete('/vagaiyara/delete/$id');
    return response;
  }
}
