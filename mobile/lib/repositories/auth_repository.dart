import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository(this._apiService, this._storageService);

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      await _storageService.saveTokens(data['accessToken'], data['refreshToken']);
      
      return User.fromJson(data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      final data = response.data['data'];
      await _storageService.saveTokens(data['accessToken'], data['refreshToken']);
      
      return User.fromJson(data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await _apiService.dio.get('/auth/profile');
      return User.fromJson(response.data['data']['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        await _apiService.dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      }
    } catch (_) {
      // Ignore errors on logout
    } finally {
      await _storageService.clearTokens();
    }
  }

  String _handleError(DioException error) {
    if (error.response?.data != null && error.response?.data['message'] != null) {
      return error.response?.data['message'];
    }
    return 'An unexpected error occurred';
  }
}
