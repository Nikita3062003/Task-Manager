import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  final StorageService _storageService;

  ApiService(this._storageService) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final refreshToken = await _storageService.getRefreshToken();
            
            if (refreshToken != null) {
              try {
                // Try to refresh the token using a separate Dio instance to avoid interceptor loop
                final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
                final response = await refreshDio.post(
                  '/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );
                
                if (response.statusCode == 200) {
                  final newAccessToken = response.data['data']['accessToken'];
                  final newRefreshToken = response.data['data']['refreshToken'];
                  
                  await _storageService.saveTokens(newAccessToken, newRefreshToken);
                  
                  // Retry original request with new token
                  e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  
                  final retryOptions = Options(
                    method: e.requestOptions.method,
                    headers: e.requestOptions.headers,
                  );
                  
                  final retryResponse = await dio.request(
                    e.requestOptions.path,
                    options: retryOptions,
                    data: e.requestOptions.data,
                    queryParameters: e.requestOptions.queryParameters,
                  );
                  
                  return handler.resolve(retryResponse);
                }
              } catch (refreshError) {
                // If refresh fails, clear tokens and pass the error
                await _storageService.clearTokens();
                // We'd ideally notify the app to logout here
                return handler.next(e);
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
