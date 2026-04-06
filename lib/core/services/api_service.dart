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

/// API Service
/// Service untuk handle HTTP requests ke backend Express.js API
/// Base URL: http://<IP>:3000/api
/// Dengan dukungan mock data toggle untuk development
class ApiService {
  late final Dio _dio;
  late final Dio _uploadDio; // For multipart uploads
  final MockConfig _mockConfig = MockConfig();

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

    // Separate Dio for file uploads (multipart)
    _uploadDio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and auth token
    _dio.interceptors.add(InterceptorsWrapper(
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

    _uploadDio.interceptors.add(InterceptorsWrapper(
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

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
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
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
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
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Register: $email');
      return AuthMockHandler.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
    }

    print('🌐 [API] POST /auth/register: $email');
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
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
      final response = await _dio.post('/auth/logout');
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
      final response = await _dio.get('/users/profile');
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
      final response = await _dio.get('/children');
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
      final response = await _dio.get('/children/$childId');
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
      final response = await _dio.post('/children', data: {
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
    required List<String> symptoms,
    bool useML = true,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Create diagnosis for child: $childId');
      return DiagnosaMockHandler.create({
        'childId': childId,
        'symptoms': symptoms,
        'useML': useML,
      });
    }

    print('🌐 [API] POST /diagnosis/check: $childId');
    try {
      final response = await _dio.post('/diagnosis/check', data: {
        'childId': childId,
        'symptoms': symptoms,
        'useML': useML,
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
      final response = await _dio.get('/diagnosis/history/$childId');
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
      final response = await _dio.post('/therapy/booking', data: data);
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
      final response = await _dio.get('/therapy/history');
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
      final response = await _dio.post('/game/log', data: {
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
      final response = await _dio.get('/game/history/$childId');
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== PROGRESS UPLOAD ENDPOINTS ==========

  /// Upload Progress (Photo/Video)
  /// POST /api/progress/upload (multipart/form-data)
  Future<MockResponse> uploadProgress({
    required String childId,
    required File file,
    String? notes,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Upload progress for child: $childId');
      return MockResponse.success({
        'message': 'Mock progress uploaded',
        'data': {
          'id': 'mock-upload-id',
          'childId': childId,
          'fileUrl': '/uploads/mock-file.jpg',
          'parentNotes': notes,
          'createdAt': DateTime.now().toIso8601String(),
        },
      });
    }

    print('🌐 [API] POST /progress/upload: $childId');
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'childId': childId,
        if (notes != null) 'notes': notes,
      });

      final response = await _uploadDio.post(
        '/progress/upload',
        data: formData,
      );
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== ML PREDICTION ENDPOINTS ==========

  /// Predict Speech Delay
  /// POST /api/v1/predict/speech-delay
  Future<MockResponse> predictSpeechDelay({
    required String childId,
    required List<num> features,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Predict speech delay: $childId');
      return MockResponse.success({
        'message': 'Prediction completed',
        'data': {
          'child_id': childId,
          'risk_level': 'MEDIUM',
          'score': 0.65,
          'confidence': 0.88,
          'recommendation': 'Observasi lanjutan direkomendasikan.',
          'model_version': 'v1.0.0',
          'next_step': '/api/therapy/booking',
        },
      });
    }

    print('🌐 [API] POST /v1/predict/speech-delay: $childId');
    try {
      final response = await _dio.post('/v1/predict/speech-delay', data: {
        'child_id': childId,
        'features': features,
      });
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Voice Analysis
  /// POST /api/v1/predict/voice-analysis (multipart)
  Future<MockResponse> voiceAnalysis({
    required String childId,
    required File audioFile,
  }) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Voice analysis: $childId');
      return MockResponse.success({
        'message': 'Voice analysis completed',
        'data': {
          'child_id': childId,
          'analysis': {},
          'recommendations': ['Lanjutkan latihan'],
          'model_version': 'v1.0.0',
        },
      });
    }

    print('🌐 [API] POST /v1/predict/voice-analysis: $childId');
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioFile.path),
        'child_id': childId,
      });

      final response = await _uploadDio.post(
        '/v1/predict/voice-analysis',
        data: formData,
      );
      return MockResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Check ML Service Health
  /// GET /api/v1/predict/health
  Future<MockResponse> checkMlHealth() async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Check ML health');
      return MockResponse.success({
        'message': 'ML service health check',
        'data': {
          'status': 'healthy',
          'service': 'http://localhost:5000',
          'model_version': 'v1.0.0',
        },
      });
    }

    print('🌐 [API] GET /v1/predict/health');
    try {
      final response = await _dio.get('/v1/predict/health');
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

      final response = await _uploadDio.post('/v1/audio/upload', data: formData);
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

      final response = await _uploadDio.post('/v1/audio/store', data: formData);
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
      final response = await _dio.get('/therapist/patients');
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
      final response = await _dio.get('/therapist/patient/$patientId');
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
      final response = await _dio.patch('/therapist/evaluate', data: {
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
      final response = await _dio.get(
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

      final response = await _dio.get(
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
      print('📦 [MOCK] Get admin users');
      return MockResponse.success({
        'message': 'Users fetched',
        'data': {
          'users': [],
          'pagination': {'page': page, 'limit': limit, 'total': 0, 'totalPages': 0},
        },
      });
    }

    print('🌐 [API] GET /admin/users');
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (role != null) queryParameters['role'] = role;
      if (search != null) queryParameters['search'] = search;

      final response = await _dio.get('/admin/users', queryParameters: queryParameters);
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
      print('📦 [MOCK] Manage user: $userId, action: $action');
      return MockResponse.success({
        'message': 'User $action successfully',
        'data': {'userId': userId, 'reason': reason},
      });
    }

    print('🌐 [API] PUT /admin/users/$userId: $action');
    try {
      final data = {'action': action};
      if (reason != null) data['reason'] = reason;

      final response = await _dio.put('/admin/users/$userId', data: data);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
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
      final response = await _dio.post('/admin/education', data: {
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

      final response = await _dio.get(
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
      final response = await _dio.get('/education/$contentId');
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
    return createDiagnosis(
      childId: diagnosaData['childId'] ?? diagnosaData['child_id'] ?? '',
      symptoms: List<String>.from(diagnosaData['symptoms'] ?? []),
      useML: diagnosaData['useML'] ?? true,
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

  /// Update anak (legacy - backend doesn't have this endpoint)
  Future<MockResponse> updateAnak(String anakId, Map<String, dynamic> anakData) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Update anak: $anakId');
      return AnakMockHandler.update(anakId, anakData);
    }
    print('🌐 [API] Update anak (not directly supported by backend)');
    return MockResponse(statusCode: 501, data: {'message': 'Not implemented in backend'});
  }

  /// Delete anak (legacy - backend doesn't have this endpoint)
  Future<MockResponse> deleteAnak(String anakId) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] Delete anak: $anakId');
      return AnakMockHandler.delete(anakId);
    }
    print('🌐 [API] Delete anak (not directly supported by backend)');
    return MockResponse(statusCode: 501, data: {'message': 'Not implemented in backend'});
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

  // ========== GENERIC HTTP METHODS ==========

  // Generic GET request
  Future<MockResponse> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (_mockConfig.useMockData) {
      print('📦 [MOCK] GET $path');
      return MockResponse.success({'message': 'Mock GET response'});
    }

    print('🌐 [API] GET $path');
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
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
      final response = await _dio.post(path, data: data);
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
      final response = await _dio.put(path, data: data);
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
      final response = await _dio.delete(path);
      return MockResponse(
        statusCode: response.statusCode ?? 200,
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
          if (error.message != null && error.message!.contains('SocketException')) {
            return Exception('Tidak dapat terhubung ke server. Pastikan backend berjalan di ${AppConstants.baseUrl}');
          }
          return Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');

        default:
          return Exception('Terjadi kesalahan tidak dikenal');
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
