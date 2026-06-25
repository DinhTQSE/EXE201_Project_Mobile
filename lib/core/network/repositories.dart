import 'package:get_it/get_it.dart';
import 'package:vsign_mobile_app/core/models/auth_models.dart';
import 'package:vsign_mobile_app/core/models/learning_models.dart';
import 'package:vsign_mobile_app/core/models/payment_models.dart';
import 'package:vsign_mobile_app/core/models/gamification_models.dart';
import 'package:vsign_mobile_app/core/network/api_client.dart';

class AuthRepository {
  final ApiClient _client = GetIt.instance<ApiClient>();

  Future<LoginResponse> login(String email, String password) async {
    final response = await _client.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final loginData = LoginResponse.fromJson(response.data['data'] ?? response.data);
    await _client.saveAuthTokens(loginData.accessToken, response.data['data']?['refreshToken']?.toString());
    return loginData;
  }

  Future<bool> register(String displayName, String email, String password) async {
    final response = await _client.dio.post('/auth/register', data: {
      'displayName': displayName,
      'email': email,
      'password': password,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<User> getProfile() async {
    final response = await _client.dio.get('/me/profile');
    return User.fromJson(response.data['data'] ?? response.data);
  }

  Future<void> logout() async {
    await _client.clearAuthTokens();
  }
}

class LearningRepository {
  final ApiClient _client = GetIt.instance<ApiClient>();

  Future<List<Unit>> listUnits() async {
    final response = await _client.dio.get('/learning/units');
    final List list = response.data['data'] ?? response.data ?? [];
    return list.map((item) => Unit.fromJson(item)).toList();
  }

  Future<List<Chapter>> listChapters(String unitId) async {
    final response = await _client.dio.get('/learning/chapters', queryParameters: {
      'unitId': unitId,
    });
    final List list = response.data['data'] ?? response.data ?? [];
    return list.map((item) => Chapter.fromJson(item)).toList();
  }

  Future<List<Lesson>> listLessons(String chapterId) async {
    final response = await _client.dio.get('/learning/lessons', queryParameters: {
      'chapterId': chapterId,
    });
    final List list = response.data['data'] ?? response.data ?? [];
    return list.map((item) => Lesson.fromJson(item)).toList();
  }

  Future<LessonQuiz> getLessonQuiz(String lessonId) async {
    final response = await _client.dio.get('/learning/lessons/$lessonId/quiz');
    return LessonQuiz.fromJson(response.data['data'] ?? response.data);
  }

  Future<QuizSubmitResult> submitQuiz(String lessonId, String attemptId, int score) async {
    final response = await _client.dio.post(
      '/learning/lessons/$lessonId/quiz/attempts/$attemptId/submit',
      data: {
        'score': score,
      },
    );
    return QuizSubmitResult.fromJson(response.data['data'] ?? response.data);
  }

  Future<void> completeLesson(String lessonId) async {
    await _client.dio.post('/learning/lessons/$lessonId/complete');
  }

  Future<List<PracticeItem>> listPracticeItems() async {
    final response = await _client.dio.get('/learning/lessons/practice/items');
    final List list = response.data['data']?['content'] ?? response.data?['content'] ?? response.data ?? [];
    return list.map((item) => PracticeItem.fromJson(item)).toList();
  }

  Future<SignatureAttemptResponse> submitSignatureAttempt({
    required String practiceItemId,
    required int durationMs,
    required String signatureVector,
    required String targetGloss,
    required String predictedGloss,
    required double confidence,
    required bool correct,
  }) async {
    final response = await _client.dio.post(
      '/learning/lessons/practice/attempts',
      data: {
        'practiceItemId': practiceItemId,
        'durationMs': durationMs,
        'signatureVector': signatureVector,
        'targetGloss': targetGloss,
        'predictedGloss': predictedGloss,
        'confidence': confidence,
        'correct': correct,
        'aiStatus': correct ? 'PASSED' : 'RETRY_REQUIRED',
      },
    );
    return SignatureAttemptResponse.fromJson(response.data['data'] ?? response.data);
  }

  Future<AiPredictionResponse> predictLandmarks({
    required List<List<double>> sequence,
    required int handsDetectedFrames,
    required String targetGloss,
  }) async {
    final response = await _client.dio.post(
      '/signature-workflows/predict-landmarks',
      data: {
        'sequence': sequence,
        'hands_detected_frames': handsDetectedFrames,
        'targetGloss': targetGloss,
      },
    );
    return AiPredictionResponse.fromJson(response.data['data'] ?? response.data);
  }
}

class DictionaryRepository {
  final ApiClient _client = GetIt.instance<ApiClient>();

  Future<List<DictionaryEntry>> listEntries({String? word, String? category}) async {
    final Map<String, dynamic> params = {};
    if (word != null && word.isNotEmpty) params['word'] = word;
    if (category != null && category.isNotEmpty) params['category'] = category;

    final response = await _client.dio.get('/dictionary/entries', queryParameters: params);
    final List list = response.data['data']?['items'] ?? response.data?['items'] ?? response.data ?? [];
    return list.map((item) => DictionaryEntry.fromJson(item)).toList();
  }
}

class GamificationRepository {
  final ApiClient _client = GetIt.instance<ApiClient>();

  Future<GamificationSummary> getSummary() async {
    final response = await _client.dio.get('/gamification/summary');
    return GamificationSummary.fromJson(response.data['data'] ?? response.data);
  }

  Future<List<LeaderboardEntry>> getLeaderboard(String period) async {
    final response = await _client.dio.get('/leaderboards', queryParameters: {
      'period': period,
    });
    final List list = response.data['data']?['entries'] ?? response.data?['entries'] ?? response.data ?? [];
    return list.map((item) => LeaderboardEntry.fromJson(item)).toList();
  }
}

class PaymentRepository {
  final ApiClient _client = GetIt.instance<ApiClient>();

  Future<List<PaymentPlan>> listPlans() async {
    final response = await _client.dio.get('/subscription/plans');
    final List list = response.data['data'] ?? response.data ?? [];
    return list.map((item) => PaymentPlan.fromJson(item)).toList();
  }

  Future<PaymentOrderResponse> createPaymentOrder(String planType, String provider) async {
    final response = await _client.dio.post('/payments/orders', data: {
      'planType': planType,
      'provider': provider,
    });
    return PaymentOrderResponse.fromJson(response.data['data'] ?? response.data);
  }
}
