import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient;
  static const String _registeredUsersKey = 'registered_users_db';

  // Pre-registered official & developer accounts
  static final Map<String, Map<String, String>> _defaultRegisteredUsers = {
    'admin@example.com': {
      'password': 'admin',
      'name': 'Administrator',
      'username': 'admin',
    },
    'sabarishwaran1718@gmail.com': {
      'password': '123456',
      'name': 'Sabarishwaran',
      'username': 'sabari',
    },
    'sabarishwaran1718@gamil.com': {
      'password': '123456',
      'name': 'Sabarishwaran',
      'username': 'sabari',
    },
    'sabarishwaran1717@gamil.com': {
      'password': '123456',
      'name': 'Sabarishwaran',
      'username': 'sabari',
    },
    'sabarishwaran17178@gmail.com': {
      'password': '123456',
      'name': 'Sabarishwaran',
      'username': 'sabari',
    },
    'sabari': {
      'password': '123456',
      'name': 'Sabarishwaran',
      'username': 'sabari',
    },
    'admin': {
      'password': 'admin',
      'name': 'Administrator',
      'username': 'admin',
    },
  };

  static String normalizeEmail(String email) {
    var clean = email.trim().toLowerCase();
    if (clean.endsWith('@gamil.com')) {
      clean = clean.replaceFirst('@gamil.com', '@gmail.com');
    } else if (clean.endsWith('@gmial.com')) {
      clean = clean.replaceFirst('@gmial.com', '@gmail.com');
    } else if (clean.endsWith('@gmai.com')) {
      clean = clean.replaceFirst('@gmai.com', '@gmail.com');
    }
    return clean;
  }

  AuthRepository(this._apiClient);

  Future<Map<String, Map<String, String>>> getRegisteredUsers() async {
    final map = Map<String, Map<String, String>>.from(
      _defaultRegisteredUsers.map(
        (key, value) => MapEntry(key, Map<String, String>.from(value)),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(_registeredUsersKey);
      if (savedStr != null && savedStr.isNotEmpty) {
        final decoded = jsonDecode(savedStr);
        if (decoded is Map) {
          decoded.forEach((key, val) {
            if (val is Map) {
              map[key.toString().toLowerCase()] = val.map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              );
            }
          });
        }
      }
    } catch (_) {}

    return map;
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = normalizeEmail(email);
    final cleanName = name.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty || cleanName.isEmpty) {
      throw ApiException(
        'அனைத்து விவரங்களையும் நிரப்பவும் (Please fill all fields)',
      );
    }

    final users = await getRegisteredUsers();
    if (users.containsKey(cleanEmail)) {
      throw ApiException(
        'இந்த மின்னஞ்சல் ஏற்கனவே பதிவு செய்யப்பட்டுள்ளது (Email already registered)',
      );
    }

    users[cleanEmail] = {
      'name': cleanName,
      'password': cleanPassword,
      'username': cleanEmail.split('@').first,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registeredUsersKey, jsonEncode(users));
    return true;
  }

  Future<LoginResponse> login(String email, String password) async {
    final cleanEmail = normalizeEmail(email);
    final rawEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // 1. First, check remote API with normalized email
    try {
      final response = await _apiClient.post('/login', {
        'email': cleanEmail,
        'password': cleanPassword,
      });

      return LoginResponse.fromJson(response);
    } on ApiException catch (e) {
      final errorMsg = e.message.toLowerCase();
      if (errorMsg.contains('password')) {
        throw ApiException('தவறான கடவுச்சொல்! (Invalid password)');
      }
    } catch (_) {
      // Network unreachable or timeout -> continue to check registered database
    }

    // 2. Developer / Owner login for Sabarishwaran (any typo in domain/number handled)
    if (cleanEmail.contains('sabari') || rawEmail.contains('sabari')) {
      if (cleanPassword == '123456' || cleanPassword == 'admin') {
        return LoginResponse(
          result: 'Success',
          code: 200,
          message: 'Login successful',
          user: UserModel(
            id: 1,
            username: 'sabari',
            name: 'Sabarishwaran',
            email: 'sabarishwaran1718@gmail.com',
          ),
        );
      } else {
        throw ApiException('தவறான கடவுச்சொல்! (Invalid password)');
      }
    }

    // 3. Check registered users database
    final registeredUsers = await getRegisteredUsers();

    final matchedKey = registeredUsers.keys.firstWhere(
      (k) => k == cleanEmail || k == rawEmail,
      orElse: () => '',
    );

    if (matchedKey.isNotEmpty) {
      final user = registeredUsers[matchedKey]!;
      if (user['password'] == cleanPassword) {
        return LoginResponse(
          result: 'Success',
          code: 200,
          message: 'Login successful',
          user: UserModel(
            id: 1,
            username: user['username'] ?? cleanEmail.split('@').first,
            name: user['name'] ?? 'User',
            email: cleanEmail,
          ),
        );
      } else {
        throw ApiException('தவறான கடவுச்சொல்! (Invalid password)');
      }
    }

    // 4. User is neither in backend DB nor in registered users -> New user!
    throw ApiException(
      'நீங்கள் இன்னும் பதிவு செய்யவில்லை! (You have not registered yet)',
    );
  }
}
