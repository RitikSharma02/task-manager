import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:3000/auth' : 'http://localhost:3000/auth';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    print('AuthService initialized. isAndroid: ${Platform.isAndroid}, baseUrl: $baseUrl');
  }

  // Keys for storage
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      print('Registration Service Error: $e');
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Login Service Error: $e');
      print('Attempted to connect to: $baseUrl/login');
      rethrow;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Sometimes refresh endpoint returns both, sometimes just access.
        // Assuming just access based on Postman "Refresh Token" script: jsonData.accessToken
        String newAccessToken = data['accessToken'];
        // If refresh token is rotated, save it too.
        String? newRefreshToken = data['refreshToken'];
        
        await _storage.write(key: _accessTokenKey, value: newAccessToken);
        if (newRefreshToken != null) {
          await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
       // Optional: call server logout
       // final token = await getAccessToken();
       // if (token != null) {
       //   await http.post(Uri.parse('$baseUrl/logout'), headers: ...);
       // }
       await clearTokens();
    } catch (e) {
      // ignore
      await clearTokens();
    }
  }
}
