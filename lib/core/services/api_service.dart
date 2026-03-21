import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// API Service
/// Service untuk handle HTTP requests ke backend
class ApiService {
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptors for logging and token
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle common errors
        if (error.response?.statusCode == 401) {
          // Token expired, redirect to login
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }
  
  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Upload file
  Future<Response> uploadFile(String path, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      
      return await _dio.post(path, data: formData);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Get auth token from storage
  Future<String?> _getAuthToken() async {
    // TODO: Implement get token from SharedPreferences
    return null;
  }
  
  // Handle unauthorized access
  void _handleUnauthorized() {
    // TODO: Implement logout and redirect to login
  }
  
  // Handle API errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Koneksi timeout. Periksa koneksi internet Anda.');
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data['message'] ?? 'Terjadi kesalahan';
          
          switch (statusCode) {
            case 400:
              return Exception('Request tidak valid: $message');
            case 401:
              return Exception('Sesi telah berakhir. Silakan login kembali.');
            case 403:
              return Exception('Akses ditolak: $message');
            case 404:
              return Exception('Data tidak ditemukan: $message');
            case 500:
              return Exception('Terjadi kesalahan server: $message');
            default:
              return Exception('Terjadi kesalahan: $message');
          }
        
        case DioExceptionType.cancel:
          return Exception('Request dibatalkan');
        
        case DioExceptionType.unknown:
          return Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
        
        default:
          return Exception('Terjadi kesalahan tidak dikenal');
      }
    }
    
    return Exception('Terjadi kesalahan: ${error.toString()}');
  }
}