import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<LoginResponse> login(String email, String password) async {
    final response = await _apiClient.post('/login', {
      'email': email,
      'password': password,
    });

    return LoginResponse.fromJson(response);
  }
}
