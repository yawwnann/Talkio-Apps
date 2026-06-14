import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../mock/mock_config.dart';
import '../mock/handlers/auth_mock_handler.dart';
import '../mock/handlers/anak_mock_handler.dart';
import '../mock/handlers/diagnosa_mock_handler.dart';
import '../mock/handlers/jadwal_mock_handler.dart';
import '../mock/handlers/laporan_mock_handler.dart';
import '../mock/handlers/pembayaran_mock_handler.dart';
import '../mock/handlers/konsultasi_mock_handler.dart';
import '../mock/handlers/admin_mock_handler.dart';

/// API Service
/// Service untuk handle HTTP requests ke backend Express.js API
/// Base URL: http://<IP>:3000/api
/// Dengan dukungan mock data toggle untuk development
class ApiService {
  final Dio? _dio;
  final Dio? _uploadDio; // For multipart uploads
  final MockConfig _mockConfig = MockConfig();

  /// Create ApiService with shared Dio instances (recommended)
  ApiService.withDio({Dio? dio, Dio? uploadDio})
      : _dio = dio,
        _uploadDio = uploadDio;

  /// Create ApiService with own Dio instances (legacy, not recommended)
  ApiService()
      : _dio = null,
        _uploadDio = null;

  /// Get Dio instance (from provider or create new)
  Dio get dio {
    if (_dio != null) return _dio!;
    // Fallback: create new instance (not recommended)
    return _createDefaultDio();
  }

  /// Get upload Dio instance (from provider or create new)
  Dio get uploadDio {
    if (_uploadDio != null) return _uploadDio!;
    // Fallback: create new instance (not recommended)
    return _createDefaultUploadDio();
  }

  Dio _createDefaultDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      requestHeader: false,
      responseHeader: false,
      error: true,
      logPrint: (obj) => print('🌐 API Error: $obj'),
    ));

    return dio;
  }

  Dio _createDefaultUploadDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  // ========== AUTH ENDPOINTS ==========

  /// Login
  /// POST /api/auth/login
  Future<MockResponse> login(String email, String password) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Login: $email');
      return AuthMockHandler.login(email, password);
    }

    print('🌐 [API] POST /auth/login: $email');
    print('🌐 [API] Using baseUrl: ${dio.options.baseUrl}');
    try {
      print('🌐 [API] Sending request...');
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      print('🌐 [API] Response status: ${response.statusCode}');
      print('🌐 [API] Response data type: ${response.data.runtimeType}');
      print('🌐 [API] Response data: ${response.data}');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e, stackTrace) {
      print('🌐 [API] ERROR: $e');
      print('🌐 [API] Stack trace: $stackTrace');
      throw _handleError(e);
    }
  }

  /// Register
  /// POST /api/auth/register
  Future<MockResponse> register({
    required String name,
    required String email,
    required String password,
    String role = 'PARENT',
    String? recoveryPin,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Register: $email');
      return AuthMockHandler.register(
        name: name,
        email: email,
        password: password,
        role: role,
        recoveryPin: recoveryPin,
      );
    }

    print('🌐 [API] POST /auth/register: $email');
    try {
      final data = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };
      if (recoveryPin != null) data['recoveryPin'] = recoveryPin;

      final response = await dio.post('/auth/register', data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Forgot Password - Step 1 & 2: verify email + PIN
  /// POST /api/auth/forgot-password
  Future<MockResponse> forgotPassword({
    required String email,
    String? recoveryPin,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Forgot password: $email');
      return AuthMockHandler.forgotPassword(email: email, recoveryPin: recoveryPin);
    }

    print('🌐 [API] POST /auth/forgot-password: $email');
    try {
      final data = <String, dynamic>{'email': email};
      if (recoveryPin != null) data['recoveryPin'] = recoveryPin;

      final response = await dio.post('/auth/forgot-password', data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Reset Password - Step 3: reset with token
  /// POST /api/auth/reset-password
  Future<MockResponse> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Reset password');
      return AuthMockHandler.resetPassword(token: token, newPassword: newPassword);
    }

    print('🌐 [API] POST /auth/reset-password');
    try {
      final response = await dio.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Set/Change Recovery PIN (authenticated user)
  /// PUT /api/auth/recovery-pin
  Future<MockResponse> setRecoveryPin({
    required String newPin,
    String? oldPin,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Set recovery PIN');
      return MockResponse.success({
        'status': 'success',
        'message': 'PIN pemulihan berhasil diubah.',
      });
    }

    print('🌐 [API] PUT /auth/recovery-pin');
    try {
      final data = <String, dynamic>{'newPin': newPin};
      if (oldPin != null) data['oldPin'] = oldPin;

      final response = await dio.put('/auth/recovery-pin', data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Admin: Reset User Recovery PIN
  /// PUT /api/admin/users/:id/reset-pin
  Future<MockResponse> resetUserPin({
    required String userId,
    required String recoveryPin,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Reset user PIN: $userId');
      return MockResponse.success({
        'message': 'PIN pemulihan berhasil direset',
        'data': {'userId': userId},
      });
    }

    print('🌐 [API] PUT /admin/users/$userId/reset-pin');
    try {
      final response = await dio.put('/admin/users/$userId/reset-pin', data: {
        'recoveryPin': recoveryPin,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout
  Future<MockResponse> logout() async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Logout');
      return AuthMockHandler.logout();
    }

    print('🌐 [API] POST /auth/logout');
    try {
      final response = await dio.post('/auth/logout');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update Profile
  /// PUT /api/users/profile
  Future<MockResponse> updateProfile({String? name}) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Update profile');
      return MockResponse.success({
        'message': 'Profil berhasil diperbarui',
        'data': {'name': name},
      });
    }

    print('🌐 [API] PUT /users/profile');
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;

      final response = await dio.put('/users/profile', data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== USER ENDPOINTS ==========

  /// Get My Profile
  /// GET /api/users/profile
  Future<MockResponse> getMyProfile() async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get my profile');
      return MockResponse.success({'message': 'Mock profile'});
    }

    print('🌐 [API] GET /users/profile');
    try {
      final response = await dio.get('/users/profile');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== CHILDREN ENDPOINTS ==========

  /// Get All My Children
  /// GET /api/children
  Future<MockResponse> getChildren() async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get children');
      return AnakMockHandler.getByParentId('mock-parent-id');
    }

    print('🌐 [API] GET /children');
    try {
      final response = await dio.get('/children');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Child Detail
  /// GET /api/children/:id
  Future<MockResponse> getChildById(String childId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get child by id: $childId');
      return AnakMockHandler.getById(childId);
    }

    print('🌐 [API] GET /children/$childId');
    try {
      final response = await dio.get('/children/$childId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create Child
  /// POST /api/children
  Future<MockResponse> createChild({
    required String name,
    required String dateOfBirth, // ISO 8601 date
    required String gender, // MALE or FEMALE
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Create child: $name');
      return AnakMockHandler.create({
        'name': name,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
      });
    }

    print('🌐 [API] POST /children: $name');
    try {
      final response = await dio.post('/children', data: {
        'name': name,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== DIAGNOSIS ENDPOINTS ==========

  /// Create Diagnosis (Check Symptoms)
  /// POST /api/diagnosis/check
  Future<MockResponse> createDiagnosis({
    required String childId,
    required Map<String, String> answers,  // Changed from symptoms to answers
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Create diagnosis for child: $childId');
      return DiagnosaMockHandler.create({
        'childId': childId,
        'answers': answers,  // Changed from symptoms to answers
      });
    }

    print('🌐 [API] POST /diagnosis/check: $childId');
    try {
      final response = await dio.post('/diagnosis/check', data: {
        'childId': childId,
        'answers': answers,  // Changed from symptoms to answers
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Diagnosis History
  /// GET /api/diagnosis/history/:childId
  Future<MockResponse> getDiagnosisHistory(String childId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get diagnosis history: $childId');
      return DiagnosaMockHandler.getByAnakId(childId);
    }

    print('🌐 [API] GET /diagnosis/history/$childId');
    try {
      final response = await dio.get('/diagnosis/history/$childId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Diagnosis By ID
  /// GET /api/diagnosis/:id
  Future<MockResponse> getDiagnosisById(String id) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get diagnosis by id: $id');
      return DiagnosaMockHandler.getById(id);
    }

    print('🌐 [API] GET /diagnosis/$id');
    try {
      final response = await dio.get('/diagnosis/$id');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== THERAPY BOOKING ENDPOINTS ==========

  /// Book Therapy Session
  /// POST /api/therapy/booking
  Future<MockResponse> bookTherapy({
    required String childId,
    String? therapistId,
    required String schedule, // ISO 8601 datetime
    required String therapyType,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Book therapy: $childId');
      return JadwalMockHandler.create({
        'childId': childId,
        'therapistId': therapistId,
        'schedule': schedule,
        'therapyType': therapyType,
      });
    }

    print('🌐 [API] POST /therapy/booking: $childId');
    try {
      final data = {
        'childId': childId,
        'schedule': schedule,
        'therapyType': therapyType,
      };
      if (therapistId != null) {
        data['therapistId'] = therapistId;
      }
      final response = await dio.post('/therapy/booking', data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Therapy History
  /// GET /api/therapy/history
  Future<MockResponse> getTherapyHistory() async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get therapy history');
      return JadwalMockHandler.getByParent('mock-parent-id');
    }

    print('🌐 [API] GET /therapy/history');
    try {
      final response = await dio.get('/therapy/history');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== GAME LOG ENDPOINTS ==========

  /// Log Game Result
  /// POST /api/game/log
  Future<MockResponse> logGame({
    required String childId,
    required int gameScore,
    required int duration, // seconds
    required String gameType,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Log game: $gameType');
      return MockResponse.success({
        'message': 'Mock game log saved',
        'data': {
          'id': 'mock-log-id',
          'childId': childId,
          'gameScore': gameScore,
          'duration': duration,
          'gameType': gameType,
          'playedAt': DateTime.now().toIso8601String(),
        },
      });
    }

    print('🌐 [API] POST /game/log: $gameType');
    try {
      final response = await dio.post('/game/log', data: {
        'childId': childId,
        'gameScore': gameScore,
        'duration': duration,
        'gameType': gameType,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Game History
  /// GET /api/game/history/:childId
  Future<MockResponse> getGameHistory(String childId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get game history: $childId');
      return MockResponse.success({
        'message': 'Mock game history',
        'data': [],
      });
    }

    print('🌐 [API] GET /game/history/$childId');
    try {
      final response = await dio.get('/game/history/$childId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Game Recommendations (age-based)
  /// GET /api/game/recommendations/:childId
  Future<MockResponse> getGameRecommendations(String childId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get game recommendations: $childId');
      return MockResponse.success({
        'status': 'success',
        'success': true,
        'message': 'Mock game recommendations',
        'data': {
          'childId': childId,
          'ageMonths': 24,
          'band': {'label': '18–24 months', 'minMonths': 18, 'maxMonths': 24},
          'games': [
            {
              'gameType': 'Kata Bergambar',
              'params': {'choicesCount': 2, 'rounds': 6, 'hintMode': 'highlight'},
              'reason': 'Mock recommendation',
            },
          ],
        },
      });
    }

    print('🌐 [API] GET /game/recommendations/$childId');
    try {
      final response = await dio.get('/game/recommendations/$childId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== CLOUDINARY UPLOAD ENDPOINTS ==========

  /// Upload file to Cloudinary via backend
  /// POST /api/cloudinary/upload (multipart/form-data)
  Future<MockResponse> uploadToCloudinary({
    required File file,
    required String childId,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Upload to Cloudinary: $childId');
      return MockResponse.success({
        'message': 'File uploaded successfully',
        'data': {
          'secureUrl': 'https://res.cloudinary.com/demo/image/upload/v1/mock.jpg',
          'publicId': 'mock_public_id',
          'resourceType': 'image',
          'bytes': 1024,
          'duration': null,
        },
      });
    }

    print('🌐 [API] POST /cloudinary/upload: $childId');

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'childId': childId,
      });

      // Use dio with longer timeout for video uploads (5 minutes)
      final response = await dio.post(
        '/cloudinary/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent, total);
          }
        },
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete file from Cloudinary via backend
  /// DELETE /api/cloudinary/delete
  Future<MockResponse> deleteFromCloudinary(String publicId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Delete from Cloudinary: $publicId');
      return MockResponse.success({'message': 'File deleted successfully'});
    }

    print('🌐 [API] DELETE /cloudinary/delete');
    try {
      final response = await dio.delete('/cloudinary/delete', data: {
        'publicId': publicId,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== PROGRESS UPLOAD ENDPOINTS ==========

  /// Upload Progress (Photo/Video/Audio)
  /// POST /api/progress/upload (multipart/form-data)
  Future<MockResponse> uploadProgress({
    required String childId,
    required String fileUrl,
    String? cloudinaryPublicId,
    String? fileType,
    int? duration,
    String? notes,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Upload progress for child: $childId');
      return MockResponse.success({
        'message': 'Mock progress uploaded',
        'data': {
          'id': 'mock-upload-id',
          'childId': childId,
          'fileUrl': fileUrl,
          'cloudinaryPublicId': cloudinaryPublicId,
          'parentNotes': notes,
          'fileType': fileType ?? 'image',
          'duration': duration,
          'createdAt': DateTime.now().toIso8601String(),
        },
      });
    }

    print('🌐 [API] POST /progress/upload: $childId');
    try {
      final response = await dio.post(
        '/progress/upload',
        data: {
          'childId': childId,
          'fileUrl': fileUrl,
          if (cloudinaryPublicId != null) 'cloudinaryPublicId': cloudinaryPublicId,
          if (fileType != null) 'fileType': fileType,
          if (duration != null) 'duration': duration,
          if (notes != null) 'notes': notes,
        },
      );
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }


  // ========== AUDIO UPLOAD ENDPOINTS ==========

  /// Upload & Analyze Audio
  /// POST /api/v1/audio/upload (multipart)
  Future<MockResponse> uploadAndAnalyzeAudio({
    required String childId,
    required File audioFile,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Upload & analyze audio: $childId');
      return MockResponse.success({
        'message': 'Audio uploaded and analyzed',
        'data': {
          'child_id': childId,
          'file_info': {'name': 'recording.m4a', 'size': '2.5MB', 'type': 'audio/mp4'},
          'analysis': {},
          'recommendations': ['Rec 1', 'Rec 2'],
          'ml_service_available': true,
        },
      });
    }

    print('🌐 [API] POST /v1/audio/upload: $childId');
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioFile.path),
        'child_id': childId,
      });

      final response = await uploadDio.post('/v1/audio/upload', data: formData);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Store Audio Only
  /// POST /api/v1/audio/store (multipart)
  Future<MockResponse> storeAudio({
    required String childId,
    required File audioFile,
    String? notes,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Store audio: $childId');
      return MockResponse.success({
        'message': 'Audio stored successfully',
        'data': {
          'upload_id': 'upload-uuid',
          'file_info': {
            'name': 'recording.m4a',
            'size': '2.5MB',
            'type': 'audio/mp4',
            'url': '/uploads/audio-uuid.m4a',
          },
        },
      });
    }

    print('🌐 [API] POST /v1/audio/store: $childId');
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioFile.path),
        'child_id': childId,
        if (notes != null) 'notes': notes,
      });

      final response = await uploadDio.post('/v1/audio/store', data: formData);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== ARTIKULASI ENDPOINTS ==========

  /// Log Articulation Session
  /// POST /api/artikulasi/log (multipart/form-data)
  Future<MockResponse> logArtikulasiSession({
    required String childId,
    required String targetWord,
    required String targetSound,
    required bool parentRating,
    String? parentNotes,
    File? audioFile,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Log artikulasi session: $targetWord ($targetSound)');
      return MockResponse.success({
        'status': 'success',
        'message': 'Artikulasi sesi disimpan',
        'data': {
          'session': {
            'id': 'mock-session-id',
            'childId': childId,
            'targetWord': targetWord,
            'targetSound': targetSound,
            'parentRating': parentRating,
            'sessionScore': 15,
            'createdAt': DateTime.now().toIso8601String(),
          },
          'hints': ['Bunyi $targetSound berkembang baik!'],
          'nextRecommendation': 'Lanjutkan latihan!',
          'soundStats': {
            'sound': targetSound,
            'total': 1,
            'correct': parentRating ? 1 : 0,
            'incorrect': parentRating ? 0 : 1,
            'rate': parentRating ? 100 : 0,
            'status': 'practicing',
          },
        },
      });
    }

    print('🌐 [API] POST /artikulasi/log: $targetWord ($targetSound)');
    try {
      final formData = FormData();

      // Add text fields
      formData.fields.add(MapEntry('childId', childId));
      formData.fields.add(MapEntry('targetWord', targetWord));
      formData.fields.add(MapEntry('targetSound', targetSound));
      formData.fields.add(MapEntry('parentRating', parentRating.toString()));
      formData.fields.add(MapEntry('parentNotes', parentNotes ?? ''));
      formData.fields.add(MapEntry('sessionScore', '15'));

      // Add audio file if provided
      if (audioFile != null) {
        print('🌐 [API] Audio file path: ${audioFile.path}');
        print('🌐 [API] Audio file exists: ${audioFile.existsSync()}');
        if (audioFile.existsSync()) {
          final stat = audioFile.statSync();
          print('🌐 [API] Audio file size: ${stat.size} bytes');
        }

        formData.files.add(MapEntry(
          'audio',
          await MultipartFile.fromFile(audioFile.path, filename: 'articulation.m4a'),
        ));
      } else {
        print('🌐 [API] No audio file provided');
      }

      final response = await uploadDio.post(
        '/artikulasi/log',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      return MockResponse(
        statusCode: response.statusCode ?? 201,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Artikulasi Sessions for Child
  /// GET /api/artikulasi/:childId
  Future<MockResponse> getArtikulasiSessions(String childId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get artikulasi sessions: $childId');
      return MockResponse.success({
        'status': 'success',
        'message': 'Data artikulasi berhasil diambil',
        'data': {
          'sessions': [],
          'soundStats': {},
          'nextRecommendation': 'Mulai latihan!',
          'nextSound': null,
        },
      });
    }

    print('🌐 [API] GET /artikulasi/$childId');
    try {
      final response = await dio.get('/artikulasi/$childId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Artikulasi Summary for Therapist
  /// GET /api/artikulasi/:childId/summary
  Future<MockResponse> getArtikulasiSummary(String childId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get artikulasi summary: $childId');
      return MockResponse.success({
        'status': 'success',
        'message': 'Ringkasan artikulasi berhasil diambil',
        'data': {
          'soundStats': {
            'R': {'sound': 'R', 'total': 5, 'correct': 3, 'incorrect': 2, 'rate': 60, 'status': 'practicing'},
            'S': {'sound': 'S', 'total': 3, 'correct': 1, 'incorrect': 2, 'rate': 33, 'status': 'practicing'},
            'L': {'sound': 'L', 'total': 0, 'correct': 0, 'incorrect': 0, 'rate': 0, 'status': 'not_started'},
            'N': {'sound': 'N', 'total': 0, 'correct': 0, 'incorrect': 0, 'rate': 0, 'status': 'not_started'},
          },
          'summary': {
            'masteredSounds': [],
            'strugglingSounds': [],
            'totalPractice': 8,
          },
          'timeline': [],
          'latestSessions': [
            {
              'id': 'session-1',
              'targetWord': 'RAJA',
              'targetSound': 'R',
              'parentRating': true,
              'audioUrl': '/uploads/recordings/session-1.m4a',
              'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
              'needsReview': true,
            },
            {
              'id': 'session-2',
              'targetWord': 'RUSAK',
              'targetSound': 'R',
              'parentRating': null,
              'audioUrl': '/uploads/recordings/session-2.m4a',
              'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
              'needsReview': true,
            },
          ],
          'needsReview': 2,
          'trends': {},
          'chartData': [],
          'evaluation': {
            'hints': [],
            'recommendation': 'Fokus ke bunyi S yang masih perlu latihan.',
          },
        },
      });
    }

    print('🌐 [API] GET /artikulasi/$childId/summary');
    try {
      final response = await dio.get('/artikulasi/$childId/summary');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Unreviewed Artikulasi Sessions (for therapist)
  /// GET /api/artikulasi/:childId/unreviewed
  Future<MockResponse> getUnreviewedSessions(String childId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get unreviewed artikulasi sessions: $childId');
      return MockResponse.success({
        'status': 'success',
        'message': 'Sesi yang perlu direview',
        'data': [
          {
            'id': 'session-1',
            'targetWord': 'RAJA',
            'targetSound': 'R',
            'parentRating': true,
            'audioUrl': '/uploads/recordings/session-1.m4a',
            'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            'needsReview': true,
          },
          {
            'id': 'session-2',
            'targetWord': 'RUSUK',
            'targetSound': 'R',
            'parentRating': false,
            'audioUrl': '/uploads/recordings/session-2.m4a',
            'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
            'needsReview': true,
          },
        ],
      });
    }

    print('🌐 [API] GET /artikulasi/$childId/unreviewed');
    try {
      final response = await dio.get('/artikulasi/$childId/unreviewed');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Review Articulation Session (Therapist)
  /// POST /api/artikulasi/:sessionId/review
  Future<MockResponse> reviewArtikulasiSession({
    required String sessionId,
    required String therapistRating, // "OKE" or "BELUM_OK"
    required int therapistScore, // 0-100
    String? therapistNotes,
    List<String>? suggestedWords,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Review artikulasi session: $sessionId');
      return MockResponse.success({
        'status': 'success',
        'message': 'Review berhasil disimpan',
        'data': {
          'session': {
            'id': sessionId,
            'therapistRating': therapistRating,
            'therapistScore': therapistScore,
            'therapistNotes': therapistNotes,
            'suggestedWords': suggestedWords,
            'reviewedAt': DateTime.now().toIso8601String(),
          },
          'notification': 'Notifikasi telah dikirim ke orang tua',
        },
      });
    }

    print('🌐 [API] POST /artikulasi/$sessionId/review');
    try {
      final response = await dio.post(
        '/artikulasi/$sessionId/review',
        data: {
          'therapistRating': therapistRating,
          'therapistScore': therapistScore,
          if (therapistNotes != null) 'therapistNotes': therapistNotes,
          if (suggestedWords != null) 'suggestedWords': suggestedWords,
        },
      );
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== THERAPIST ENDPOINTS ==========

  /// Get My Patients
  /// GET /api/therapist/patients
  Future<MockResponse> getTherapistPatients() async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get therapist patients');
      return MockResponse.success({
        'message': 'Patients fetched',
        'data': [],
      });
    }

    print('🌐 [API] GET /therapist/patients');
    try {
      final response = await dio.get('/therapist/patients');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Patient Detail
  /// GET /api/therapist/patient/:id
  Future<MockResponse> getPatientDetail(String patientId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get patient detail: $patientId');
      return MockResponse.success({
        'message': 'Patient detail fetched',
        'data': {},
      });
    }

    print('🌐 [API] GET /therapist/patient/$patientId');
    try {
      final response = await dio.get('/therapist/patient/$patientId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Evaluate Patient Progress
  /// PATCH /api/therapist/evaluate
  Future<MockResponse> evaluatePatientProgress({
    required String progressId,
    required String evaluation,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Evaluate patient: $progressId');
      return MockResponse.success({
        'message': 'Evaluation submitted',
        'data': {
          'id': progressId,
          'therapistEvaluation': evaluation,
        },
      });
    }

    print('🌐 [API] PATCH /therapist/evaluate: $progressId');
    try {
      final response = await dio.patch('/therapist/evaluate', data: {
        'progressId': progressId,
        'evaluation': evaluation,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate Patient Report (PDF)
  /// GET /api/therapist/report/:id
  Future<MockResponse> generatePatientReport(String patientId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Generate report: $patientId');
      return MockResponse.success({
        'message': 'Report generated',
        'data': {'reportUrl': '/reports/mock-report.pdf'},
      });
    }

    print('🌐 [API] GET /therapist/report/$patientId');
    try {
      final response = await dio.get(
        '/therapist/report/$patientId',
        options: Options(responseType: ResponseType.bytes),
      );
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Therapist Schedule
  /// GET /api/therapist/schedule
  Future<MockResponse> getSchedule({String? startDate, String? endDate}) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get schedule');
      return MockResponse.success({
        'message': 'Schedule fetched successfully',
        'data': [],
      });
    }

    print('🌐 [API] GET /therapist/schedule');
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      
      final response = await dio.get('/therapist/schedule', queryParameters: queryParams);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Complete Schedule
  /// PUT /api/therapist/schedule/:id/complete
  Future<MockResponse> completeSchedule(String id) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Complete schedule');
      return MockResponse.success({
        'message': 'Schedule completed successfully',
        'data': {'id': id, 'sessionStatus': 'COMPLETED'},
      });
    }

    print('🌐 [API] PUT /therapist/schedule/$id/complete');
    try {
      final response = await dio.put('/therapist/schedule/$id/complete');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Start Session
  /// PUT /api/therapist/schedule/:id/start
  Future<MockResponse> startSession(String id) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Start session');
      return MockResponse.success({
        'message': 'Session started successfully',
        'data': {'id': id, 'sessionStatus': 'ONGOING'},
      });
    }

    print('🌐 [API] PUT /therapist/schedule/$id/start');
    try {
      final response = await dio.put('/therapist/schedule/$id/start');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create Schedule
  /// POST /api/therapist/schedule
  Future<MockResponse> createSchedule({
    required String childId,
    required String schedule,
    required String therapyType,
    bool? isActive,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Create schedule');
      return MockResponse.success({
        'message': 'Schedule created successfully',
        'data': {'id': 'mock-schedule-id'},
      });
    }

    print('🌐 [API] POST /therapist/schedule');
    try {
      final response = await dio.post('/therapist/schedule', data: {
        'childId': childId,
        'schedule': schedule,
        'therapyType': therapyType,
        'isActive': isActive ?? false,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update Schedule
  /// PATCH /api/therapist/schedule/:id
  Future<MockResponse> updateSchedule(
    String scheduleId, {
    String? schedule,
    String? therapyType,
    bool? isActive,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Update schedule: $scheduleId');
      return MockResponse.success({
        'message': 'Schedule updated successfully',
        'data': {'id': scheduleId},
      });
    }

    print('🌐 [API] PATCH /therapist/schedule/$scheduleId');
    try {
      final response = await dio.patch('/therapist/schedule/$scheduleId', data: {
        if (schedule != null) 'schedule': schedule,
        if (therapyType != null) 'therapyType': therapyType,
        if (isActive != null) 'isActive': isActive,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== NOTIFICATION ENDPOINTS ==========

  /// Get Notifications
  /// GET /api/notifications
  Future<MockResponse> getNotifications() async {
    if (_mockConfig.useMockData) {
      return MockResponse.success({'data': []});
    }
    try {
      final response = await dio.get('/notifications');
      return MockResponse(statusCode: response.statusCode ?? 200, data: response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark Notification as Read
  /// PUT /api/notifications/:id/read
  Future<MockResponse> markNotificationAsRead(String id) async {
    if (_mockConfig.useMockData) {
      return MockResponse.success({'data': {}});
    }
    try {
      final response = await dio.put('/notifications/$id/read');
      return MockResponse(statusCode: response.statusCode ?? 200, data: response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Admin Notifications
  /// GET /api/admin/notifications
  Future<MockResponse> getAdminNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    String? priority,
  }) async {
    if (_mockConfig.useMockData) {
      return MockResponse.success({
        'data': [],
        'summary': {'high': 0, 'medium': 0, 'low': 0, 'total': 0},
      });
    }
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
        if (priority != null) 'priority': priority,
      };
      final response = await dio.get('/admin/notifications', queryParameters: queryParams);
      return MockResponse(statusCode: response.statusCode ?? 200, data: response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark All Admin Notifications as Read
  /// PUT /api/admin/notifications/read-all
  Future<MockResponse> markAllAdminNotificationsRead() async {
    if (_mockConfig.useMockData) {
      return MockResponse.success({'message': 'All notifications marked as read'});
    }
    try {
      final response = await dio.put('/admin/notifications/read-all');
      return MockResponse(statusCode: response.statusCode ?? 200, data: response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete Schedule
  /// DELETE /api/therapist/schedule/:id
  Future<MockResponse> deleteSchedule(String scheduleId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Delete schedule: $scheduleId');
      return MockResponse.success({
        'message': 'Schedule deleted successfully',
      });
    }

    print('🌐 [API] DELETE /therapist/schedule/$scheduleId');
    try {
      final response = await dio.delete('/therapist/schedule/$scheduleId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Dashboard Stats
  /// GET /api/therapist/dashboard/stats
  Future<MockResponse> getDashboardStats() async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get dashboard stats');
      return MockResponse.success({
        'status': 'success',
        'message': 'Dashboard stats fetched successfully',
        'data': {
          'todaySchedule': {'count': 0, 'sessions': []},
          'recentUpdates': [],
          'activePatients': {'count': 0, 'patients': []},
          'trends': {
            'averageImprovement': '0%',
            'vocabularyScore': '0%',
            'dailyEngagement': '0%',
          },
          'summary': {'newRecordings': 0, 'pendingReports': 0},
        },
      });
    }

    print('🌐 [API] GET /therapist/dashboard/stats');
    try {
      final response = await dio.get('/therapist/dashboard/stats');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Report History
  /// GET /api/therapist/reports
  Future<MockResponse> getReportHistory() async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get report history');
      return MockResponse.success({
        'message': 'Report history fetched',
        'data': [],
      });
    }

    print('🌐 [API] GET /therapist/reports');
    try {
      final response = await dio.get('/therapist/reports');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create Report
  /// POST /api/therapist/report
  Future<MockResponse> createReport({
    required String childId,
    required String title,
    required String progressNotes,
    String? sessionDate,
    double? speechClarity,
    double? vocabulary,
    double? socialInteraction,
    String? barriers,
    List<String>? parentExercises,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Create report');
      return MockResponse.success({
        'message': 'Report created successfully',
        'data': {'id': 'mock-report-id'},
      });
    }

    print('🌐 [API] POST /therapist/report');
    try {
      final data = <String, dynamic>{
        'childId': childId,
        'title': title,
        'progressNotes': progressNotes,
      };
      if (sessionDate != null) data['sessionDate'] = sessionDate;
      if (speechClarity != null) data['speechClarity'] = speechClarity;
      if (vocabulary != null) data['vocabulary'] = vocabulary;
      if (socialInteraction != null) data['socialInteraction'] = socialInteraction;
      if (barriers != null) data['barriers'] = barriers;
      if (parentExercises != null) data['parentExercises'] = parentExercises;
      
      final response = await dio.post('/therapist/report', data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Patient Progress
  /// GET /api/therapist/patients/:id/progress
  Future<MockResponse> getPatientProgress(String patientId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get patient progress: $patientId');
      return MockResponse.success({
        'message': 'Patient progress fetched',
        'data': {'progressNotes': [], 'progressUploads': []},
      });
    }

    print('🌐 [API] GET /therapist/patients/$patientId/progress');
    try {
      final response = await dio.get('/therapist/patients/$patientId/progress');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Patient Exercises
  /// GET /api/therapist/patients/:id/exercises
  Future<MockResponse> getPatientExercises(String patientId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get patient exercises: $patientId');
      return MockResponse.success({
        'message': 'Patient exercises fetched',
        'data': [],
      });
    }

    print('🌐 [API] GET /therapist/patients/$patientId/exercises');
    try {
      final response = await dio.get('/therapist/patients/$patientId/exercises');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create Therapist Note
  /// POST /api/therapist/notes
  Future<MockResponse> createNote({
    required String childId,
    required String title,
    required String content,
    String? date,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Create note');
      return MockResponse.success({
        'message': 'Note created successfully',
        'data': {'id': 'mock-note-id'},
      });
    }

    print('🌐 [API] POST /therapist/notes');
    try {
      final data = <String, dynamic>{
        'childId': childId,
        'title': title,
        'content': content,
      };
      if (date != null) data['date'] = date;
      
      final response = await dio.post('/therapist/notes', data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Notes by Child
  /// GET /api/therapist/notes/:childId
  Future<MockResponse> getNotesByChild(String childId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get notes by child: $childId');
      return MockResponse.success({
        'message': 'Notes fetched successfully',
        'data': [],
      });
    }

    print('🌐 [API] GET /therapist/notes/$childId');
    try {
      final response = await dio.get('/therapist/notes/$childId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update Note
  /// PATCH /api/therapist/notes/:id
  Future<MockResponse> updateNote(
    String noteId, {
    String? title,
    String? content,
    String? date,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Update note: $noteId');
      return MockResponse.success({
        'message': 'Note updated successfully',
        'data': {'id': noteId},
      });
    }

    print('🌐 [API] PATCH /therapist/notes/$noteId');
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (date != null) data['date'] = date;
      
      final response = await dio.patch('/therapist/notes/$noteId', data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete Note
  /// DELETE /api/therapist/notes/:id
  Future<MockResponse> deleteNote(String noteId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Delete note: $noteId');
      return MockResponse.success({
        'message': 'Note deleted successfully',
      });
    }

    print('🌐 [API] DELETE /therapist/notes/$noteId');
    try {
      final response = await dio.delete('/therapist/notes/$noteId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Payment URL for existing pending session
  /// POST /api/therapy/payment-url
  Future<MockResponse> getPaymentUrl(String sessionId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get payment URL for session: $sessionId');
      return MockResponse.success({
        'message': 'Payment URL generated',
        'data': {
          'paymentUrl': 'https://app.sandbox.midtrans.com/snap/v2/vtweb/example',
          'orderId': 'THERAPY-$sessionId',
        },
      });
    }

    print('🌐 [API] POST /therapy/payment-url: $sessionId');
    try {
      final response = await dio.post('/therapy/payment-url', data: {
        'sessionId': sessionId,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== ADMIN ENDPOINTS ==========

  /// Get Dashboard Statistics
  /// GET /api/admin/dashboard
  Future<MockResponse> getAdminDashboard({
    String? startDate,
    String? endDate,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get admin dashboard');
      return MockResponse.success({
        'message': 'Dashboard stats fetched',
        'data': {
          'userCount': 50,
          'parentCount': 35,
          'therapistCount': 10,
          'childrenCount': 45,
          'sessionCount': 120,
          'activeTherapyCount': 25,
          'diagnosisCount': 80,
          'highRiskCount': 15,
          'revenue': 19800000,
          'revenueFormatted': 'Rp 19.800.000',
        },
      });
    }

    print('🌐 [API] GET /admin/dashboard');
    try {
      final queryParameters = <String, dynamic>{};
      if (startDate != null) queryParameters['startDate'] = startDate;
      if (endDate != null) queryParameters['endDate'] = endDate;

      final response = await dio.get(
        '/admin/dashboard',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get All Users
  /// GET /api/admin/users
  Future<MockResponse> getAdminUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
  }) async {
    if (_mockConfig.useMockData) {
      return AdminMockHandler.getUsers(
        page: page,
        limit: limit,
        role: role,
        search: search,
      );
    }

    print('🌐 [API] GET /admin/users');
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (role != null) queryParameters['role'] = role;
      if (search != null) queryParameters['search'] = search;

      final response = await dio.get('/admin/users', queryParameters: queryParameters);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Manage User (Block/Unblock/Delete)
  /// PUT /api/admin/users/:id
  Future<MockResponse> manageUser({
    required String userId,
    required String action, // block, unblock, delete
    String? reason,
  }) async {
    if (_mockConfig.useMockData) {
      return AdminMockHandler.manageUser(
        userId: userId,
        action: action,
        reason: reason,
      );
    }

    print('🌐 [API] PUT /admin/users/$userId: $action');
    try {
      final data = {'action': action};
      if (reason != null) data['reason'] = reason;

      final response = await dio.put('/admin/users/$userId', data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Reset User Password (Admin)
  /// POST /api/admin/users/:id/reset-password
  Future<MockResponse> resetUserPassword({
    required String userId,
  }) async {
    if (_mockConfig.useMockData) {
      return AdminMockHandler.resetUserPassword(userId: userId);
    }

    print('🌐 [API] POST /admin/users/$userId/reset-password');
    try {
      final response = await dio.post('/admin/users/$userId/reset-password');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create User (Admin)
  /// POST /api/admin/users
  Future<MockResponse> createAdminUser({
    required String name,
    required String email,
    required String password,
    String role = 'THERAPIST',
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Create admin user');
      return MockResponse.success({
        'message': 'User created',
        'data': {
          'id': 'new-uuid',
          'name': name,
          'email': email,
          'role': role,
          'isBlocked': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      });
    }

    print('🌐 [API] POST /admin/users');
    try {
      final response = await dio.post('/admin/users', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 201,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Add Education Content
  /// POST /api/admin/education
  Future<MockResponse> addEducationContent({
    required String title,
    required String content,
    required String type, // ARTICLE or VIDEO
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Add education content');
      return MockResponse.success({
        'message': 'Content added',
        'data': {
          'id': 'content-uuid',
          'title': title,
          'content': content,
          'type': type,
          'createdAt': DateTime.now().toIso8601String(),
        },
      });
    }

    print('🌐 [API] POST /admin/education');
    try {
      final response = await dio.post('/admin/education', data: {
        'title': title,
        'content': content,
        'type': type,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Admin Payments
  /// GET /api/admin/payments
  Future<MockResponse> getAdminPayments({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get admin payments');
      return MockResponse.success({
        'message': 'Payments fetched',
        'data': {
          'transactions': [],
          'summary': {'success': 0, 'pending': 0, 'failed': 0},
          'pagination': {'page': page, 'limit': limit, 'total': 0, 'totalPages': 0},
        },
      });
    }

    print('🌐 [API] GET /admin/payments');
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParameters['status'] = status;
      if (search != null) queryParameters['search'] = search;

      final response = await dio.get('/admin/payments', queryParameters: queryParameters);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Admin Reports
  /// GET /api/admin/reports
  Future<MockResponse> getAdminReports({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get admin reports');
      return MockResponse.success({
        'message': 'Reports fetched',
        'data': {
          'reports': [],
          'summary': {'sent': 0, 'draft': 0},
          'pagination': {'page': page, 'limit': limit, 'total': 0, 'totalPages': 0},
        },
      });
    }

    print('🌐 [API] GET /admin/reports');
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParameters['status'] = status;
      if (search != null) queryParameters['search'] = search;

      final response = await dio.get('/admin/reports', queryParameters: queryParameters);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== EDUCATION ENDPOINTS ==========

  /// Get All Education Content
  /// GET /api/education
  Future<MockResponse> getEducationContent({
    String? type, // 'ARTICLE' or 'VIDEO'
    bool? isActive,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get education content');
      return MockResponse.success({
        'message': 'Education contents fetched',
        'data': {
          'contents': [
            {
              'id': 'article-1',
              'title': '5 Tanda Anak Mengalami Speech Delay',
              'description': 'Kenali tanda-tanda awal speech delay pada anak',
              'content': '/uploads/education/artikel-speech-delay.pdf',
              'type': 'ARTICLE',
              'isActive': true,
              'order': 1,
              'createdAt': DateTime.now().toIso8601String(),
            },
            {
              'id': 'video-1',
              'title': 'Latihan Mengucapkan Huruf R',
              'description': 'Video terapi wicara untuk anak',
              'content': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
              'type': 'VIDEO',
              'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
              'embedUrl': 'https://www.youtube.com/embed/dQw4w9WgXcQ',
              'videoId': 'dQw4w9WgXcQ',
              'isActive': true,
              'order': 2,
              'createdAt': DateTime.now().toIso8601String(),
            },
          ],
          'pagination': {
            'page': page,
            'limit': limit,
            'total': 2,
            'totalPages': 1,
          },
        },
      });
    }

    print('🌐 [API] GET /education');
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (type != null) queryParameters['type'] = type;
      if (isActive != null) queryParameters['isActive'] = isActive;
      if (search != null) queryParameters['search'] = search;

      final response = await dio.get(
        '/education',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Education Content by ID
  /// GET /api/education/:id
  Future<MockResponse> getEducationContentById(String contentId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get education content by id: $contentId');
      return MockResponse.success({
        'message': 'Education content fetched',
        'data': {
          'id': contentId,
          'title': 'Sample Article',
          'content': '/uploads/education/sample.pdf',
          'type': 'ARTICLE',
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
        },
      });
    }

    print('🌐 [API] GET /education/$contentId');
    try {
      final response = await dio.get('/education/$contentId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== LEGACY/EXISTING ENDPOINTS (backward compatibility) ==========
  // These wrap the old naming for existing code that uses them

  /// Get diagnosa by anak ID (legacy alias → getDiagnosisHistory)
  Future<MockResponse> getDiagnosaByAnakId(String anakId) async {
    return getDiagnosisHistory(anakId);
  }

  /// Create diagnosa (legacy alias → createDiagnosis)
  Future<MockResponse> createDiagnosa(Map<String, dynamic> diagnosaData) async {
    // Check if it's using the new answers format or legacy symptoms format
    final answers = diagnosaData['answers'];
    final symptoms = diagnosaData['symptoms'];

    Map<String, String> answersMap;
    if (answers is Map) {
      // New format: answers is already a Map<String, String>
      answersMap = Map<String, String>.from(answers);
    } else if (symptoms is List) {
      // Legacy format: symptoms is a List<String>, convert to answers map
      answersMap = {};
      for (var i = 0; i < symptoms.length; i++) {
        answersMap['symptom_$i'] = symptoms[i].toString();
      }
    } else {
      answersMap = {};
    }

    return createDiagnosis(
      childId: diagnosaData['childId'] ?? diagnosaData['child_id'] ?? '',
      answers: answersMap,
    );
  }

  /// Get jadwal by terapis ID (legacy - therapist view)
  Future<MockResponse> getJadwalByTerapis(String terapisId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get jadwal by terapis_id: $terapisId');
      return JadwalMockHandler.getByTerapis(terapisId);
    }
    print('🌐 [API] GET /therapist/patients (therapist schedule)');
    return getTherapistPatients();
  }

  /// Get jadwal by parent ID (legacy alias → getTherapyHistory)
  Future<MockResponse> getJadwalByParent(String parentId) async {
    return getTherapyHistory();
  }

  /// Create jadwal (legacy alias → bookTherapy)
  Future<MockResponse> createJadwal(Map<String, dynamic> jadwalData) async {
    return bookTherapy(
      childId: jadwalData['childId'] ?? jadwalData['child_id'] ?? '',
      therapistId: jadwalData['therapistId'] ?? jadwalData['therapist_id'],
      schedule: jadwalData['schedule'] ?? DateTime.now().toIso8601String(),
      therapyType: jadwalData['therapyType'] ?? jadwalData['therapy_type'] ?? 'Speech Therapy',
    );
  }

  /// Update jadwal (legacy - may not map directly to backend)
  Future<MockResponse> updateJadwal(String jadwalId, Map<String, dynamic> jadwalData) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Update jadwal: $jadwalId');
      return JadwalMockHandler.update(jadwalId, jadwalData);
    }
    print('🌐 [API] Update jadwal (not directly supported by backend)');
    return MockResponse(statusCode: 501, data: {'message': 'Not implemented in backend'});
  }

  /// Delete jadwal (legacy)
  Future<MockResponse> deleteJadwal(String jadwalId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Delete jadwal: $jadwalId');
      return JadwalMockHandler.delete(jadwalId);
    }
    print('🌐 [API] Delete jadwal (not directly supported by backend)');
    return MockResponse(statusCode: 501, data: {'message': 'Not implemented in backend'});
  }

  /// Get pembayaran by user ID (legacy alias → getTherapyHistory)
  Future<MockResponse> getPembayaranByUser(String userId) async {
    return getTherapyHistory();
  }

  /// Create pembayaran (legacy alias → bookTherapy)
  Future<MockResponse> createPembayaran(Map<String, dynamic> pembayaranData) async {
    return bookTherapy(
      childId: pembayaranData['childId'] ?? pembayaranData['child_id'] ?? '',
      therapistId: pembayaranData['therapistId'] ?? pembayaranData['therapist_id'],
      schedule: pembayaranData['schedule'] ?? DateTime.now().toIso8601String(),
      therapyType: pembayaranData['therapyType'] ?? pembayaranData['therapy_type'] ?? 'Speech Therapy',
    );
  }

  /// Update payment status (legacy)
  Future<MockResponse> updatePaymentStatus(String pembayaranId, Map<String, dynamic> statusData) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Update payment status: $pembayaranId');
      return PembayaranMockHandler.updateStatus(pembayaranId, statusData);
    }
    print('🌐 [API] Update payment status (handled via Midtrans webhook)');
    return MockResponse.success({'message': 'Payment status updated via webhook'});
  }

  /// Get konsultasi by parent ID (legacy - may not map to backend)
  Future<MockResponse> getKonsultasiByParent(String parentId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get konsultasi by parent_id: $parentId');
      return KonsultasiMockHandler.getByParent(parentId);
    }
    print('🌐 [API] Get konsultasi (not directly in backend)');
    return MockResponse.success({'message': 'Konsultasi not available', 'data': []});
  }

  /// Create konsultasi (legacy)
  Future<MockResponse> createKonsultasi(Map<String, dynamic> konsultasiData) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Create konsultasi');
      return KonsultasiMockHandler.create(konsultasiData);
    }
    print('🌐 [API] Create konsultasi (not directly in backend)');
    return MockResponse.success({'message': 'Konsultasi created'});
  }

  /// Update konsultasi response (legacy)
  Future<MockResponse> updateKonsultasiResponse(String konsultasiId, String response) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Update konsultasi response: $konsultasiId');
      return KonsultasiMockHandler.updateResponse(konsultasiId, response);
    }
    print('🌐 [API] Update konsultasi response (not directly in backend)');
    return MockResponse.success({'message': 'Konsultasi response updated'});
  }

  /// Get anak by parent ID (legacy alias → getChildren)
  Future<MockResponse> getAnakByParentId(String parentId) async {
    return getChildren();
  }

  /// Get anak by ID (legacy alias → getChildById)
  Future<MockResponse> getAnakById(String anakId) async {
    return getChildById(anakId);
  }

  /// Create anak (legacy alias → createChild)
  Future<MockResponse> createAnak(Map<String, dynamic> anakData) async {
    return createChild(
      name: anakData['name'] ?? '',
      dateOfBirth: anakData['dateOfBirth'] ?? anakData['date_of_birth'] ?? DateTime.now().toIso8601String(),
      gender: anakData['gender'] ?? 'MALE',
    );
  }

  /// Update anak
  Future<MockResponse> updateAnak(String anakId, Map<String, dynamic> anakData) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Update anak: $anakId');
      return AnakMockHandler.update(anakId, anakData);
    }
    try {
      final response = await dio.put(
        '/children/$anakId',
        data: anakData,
      );
      print('🌐 [API] Update anak: ${response.statusCode}');
      return MockResponse(statusCode: response.statusCode ?? 200, data: response.data);
    } catch (e) {
      print('❌ [API] Update anak error: $e');
      throw _handleError(e);
    }
  }

  /// Delete anak
  /// DELETE /api/children/:id
  Future<MockResponse> deleteAnak(String anakId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Delete anak: $anakId');
      return AnakMockHandler.delete(anakId);
    }
    print('🌐 [API] DELETE /children/$anakId');
    try {
      final response = await dio.delete('/children/$anakId');
      print('🌐 [API] Delete anak: ${response.statusCode}');
      return MockResponse(statusCode: response.statusCode ?? 200, data: response.data);
    } catch (e) {
      print('❌ [API] Delete anak error: $e');
      throw _handleError(e);
    }
  }

  /// Get laporan by terapis ID (legacy)
  Future<MockResponse> getLaporanByTerapis(String terapisId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get laporan by terapis_id: $terapisId');
      return LaporanMockHandler.getLaporanByTerapis(terapisId);
    }
    print('🌐 [API] Get laporan (not directly in backend)');
    return MockResponse.success({'message': 'Laporan not available', 'data': []});
  }

  // ========== INVENTARIS ASSET ENDPOINTS ==========

  /// Get All Assets (Inventaris)
  /// GET /api/assets
  Future<MockResponse> getAssets({String? search, String? kategori}) async {
    if (_mockConfig.useMockData) {
      return MockResponse.success({'message': 'Assets fetched', 'data': []});
    }
    print('🌐 [API] GET /assets');
    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (kategori != null && kategori.isNotEmpty) params['kategori'] = kategori;
      final response = await dio.get('/assets', queryParameters: params);
      return MockResponse(statusCode: response.statusCode ?? 200, data: response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create Asset (Inventaris)
  /// POST /api/assets
  Future<MockResponse> createAsset({
    required String kode,
    required String nama,
    int jumlah = 0,
    String? satuan,
    String? keterangan,
  }) async {
    if (_mockConfig.useMockData) {
      return MockResponse.success({'message': 'Asset created', 'data': {}});
    }
    print('🌐 [API] POST /assets: $nama');
    try {
      final response = await dio.post('/assets', data: {
        'kode': kode,
        'nama': nama,
        'jumlah': jumlah,
        if (satuan != null) 'satuan': satuan,
        if (keterangan != null) 'keterangan': keterangan,
      });
      return MockResponse(statusCode: response.statusCode ?? 200, data: response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update Asset (Inventaris)
  /// PUT /api/assets/:id
  Future<MockResponse> updateAsset(String id, Map<String, dynamic> data) async {
    if (_mockConfig.useMockData) {
      return MockResponse.success({'message': 'Asset updated', 'data': {}});
    }
    print('🌐 [API] PUT /assets/$id');
    try {
      final response = await dio.put('/assets/$id', data: data);
      return MockResponse(statusCode: response.statusCode ?? 200, data: response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete Asset (Inventaris)
  /// DELETE /api/assets/:id
  Future<MockResponse> deleteAsset(String id) async {
    if (_mockConfig.useMockData) {
      return MockResponse.success({'message': 'Asset deleted'});
    }
    print('🌐 [API] DELETE /assets/$id');
    try {
      final response = await dio.delete('/assets/$id');
      return MockResponse(statusCode: response.statusCode ?? 200, data: response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== GENERIC HTTP METHODS ==========

  // Generic GET request
  Future<MockResponse> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] GET $path');
      return MockResponse.success({'message': 'Mock GET response'});
    }

    print('🌐 [API] GET $path');
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<MockResponse> post(String path, {dynamic data}) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] POST $path');
      return MockResponse.success({'message': 'Mock POST response'});
    }

    print('🌐 [API] POST $path');
    try {
      final response = await dio.post(path, data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<MockResponse> put(String path, {dynamic data}) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] PUT $path');
      return MockResponse.success({'message': 'Mock PUT response'});
    }

    print('🌐 [API] PUT $path');
    try {
      final response = await dio.put(path, data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<MockResponse> delete(String path) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] DELETE $path');
      return MockResponse.success({'message': 'Mock DELETE response'});
    }

    print('🌐 [API] DELETE $path');
    try {
      final response = await dio.delete(path);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== THERAPIST DETAIL & TESTIMONIAL ENDPOINTS ==========

  /// Get Therapist Detail
  /// GET /api/therapist/detail/:id
  Future<MockResponse> getTherapistDetail(String therapistId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Get therapist detail: $therapistId');
      return MockResponse.success({
        'message': 'Therapist detail fetched successfully',
        'data': {
          'id': therapistId,
          'name': 'Dr. Sarah Wijaya',
          'email': 'therapist1@example.com',
          'totalSessions': 15,
          'rating': 4.8,
          'specialization': 'Terapi Bicara & Wicara',
          'experience': '5+ Tahun',
          'bio': 'Dr. Sarah Wijaya adalah terapis bicara profesional yang berdedikasi untuk membantu anak-anak mengatasi keterlambatan bicara. Dengan pengalaman di berbagai klinik tumbuh kembang anak, beliau merancang sesi terapi yang interaktif dan menyenangkan agar anak berkembang secara optimal.',
          'reviews': [
            {
              'id': '1',
              'parentId': 'parent-id-1',
              'parentName': 'Ibu Anna',
              'rating': 5,
              'developmentTime': '3 Bulan',
              'comment': 'Anak saya sekarang sudah pintar berbicara 2-3 kata setelah terapi rutin.',
              'createdAt': '2026-05-20T10:00:00.000Z'
            }
          ]
        }
      });
    }

    print('🌐 [API] GET /therapist/detail/$therapistId');
    try {
      final response = await dio.get('/therapist/detail/$therapistId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Submit Therapist Review
  /// POST /api/therapist/review
  Future<MockResponse> submitTherapistReview({
    required String therapistId,
    required int rating,
    required String developmentTime,
    required String comment,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Submit review for: $therapistId');
      return MockResponse.success({
        'message': 'Ulasan berhasil disimpan',
        'data': {
          'id': 'mock-review-uuid',
          'therapistId': therapistId,
          'rating': rating,
          'developmentTime': developmentTime,
          'comment': comment,
          'createdAt': DateTime.now().toIso8601String(),
        }
      });
    }

    print('🌐 [API] POST /therapist/review');
    try {
      final response = await dio.post('/therapist/review', data: {
        'therapistId': therapistId,
        'rating': rating,
        'developmentTime': developmentTime,
        'comment': comment,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 201,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== HELPER METHODS ==========

  // Get auth token from storage
  Future<String?> _getAuthToken() async {
    return StorageService.getString(AppConstants.tokenKey);
  }

  // Handle unauthorized access
  void _handleUnauthorized() async {
    await StorageService.remove(AppConstants.tokenKey);
    await StorageService.remove(AppConstants.userKey);
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
          String message = 'Terjadi kesalahan';
          try {
            final data = error.response?.data;
            if (data is Map) {
              message = data['message']?.toString() ?? 'Terjadi kesalahan';
            }
          } catch (_) {}

          switch (statusCode) {
            case 400:
              return Exception('Request tidak valid: $message');
            case 401:
              return Exception('Email atau password salah.');
            case 403:
              return Exception('Akses ditolak: $message');
            case 404:
              return Exception('Data tidak ditemukan: $message');
            case 500:
              return Exception('Terjadi kesalahan server: $message');
            default:
              return Exception('Terjadi kesalahan ($statusCode): $message');
          }

        case DioExceptionType.cancel:
          return Exception('Request dibatalkan');

        case DioExceptionType.connectionError:
          // Dio 5.x - connection error (network unreachable, SSL error, etc.)
          return Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');

        case DioExceptionType.unknown:
          final msg = error.message ?? '';
          if (msg.contains('SocketException') || msg.contains('Connection refused')) {
            return Exception('Tidak dapat terhubung ke server. Pastikan internet Anda aktif.');
          }
          if (msg.contains('HandshakeException') || msg.contains('CERTIFICATE')) {
            return Exception('Koneksi tidak aman. Gagal verifikasi sertifikat SSL.');
          }
          return Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');

        default:
          final detail = error.message ?? error.toString();
          return Exception('Terjadi kesalahan: $detail');
      }
    }

    return Exception('Terjadi kesalahan: ${error.toString()}');
  }

  // ========== MOCK CONFIG METHODS ==========

  /// Initialize mock config
  Future<void> initMockConfig() async {
    await _mockConfig.init();
  }

  /// Toggle mock mode
  Future<void> toggleMockMode(bool enabled) async {
    await _mockConfig.setMockMode(enabled);
    print('🔄 Mock mode ${enabled ? 'ENABLED' : 'DISABLED'}');
  }

  /// Get current mock mode
  bool get useMockData => _mockConfig.useMockData;
}
