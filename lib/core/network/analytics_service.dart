import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('Analytics logSignUp error: $e');
    }
  }

  Future<void> logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('Analytics logLogin error: $e');
    }
  }

  Future<void> logUseAiCamera(String practiceItemId, String targetGloss) async {
    try {
      await _analytics.logEvent(
        name: 'use_AI_camera',
        parameters: {
          'practice_item_id': practiceItemId,
          'target_gloss': targetGloss,
        },
      );
    } catch (e) {
      debugPrint('Analytics logUseAiCamera error: $e');
    }
  }

  Future<void> logCompleteLesson(String lessonId) async {
    try {
      await _analytics.logEvent(
        name: 'complete_lesson',
        parameters: {
          'lesson_id': lessonId,
        },
      );
    } catch (e) {
      debugPrint('Analytics logCompleteLesson error: $e');
    }
  }

  Future<void> logPurchase(String planType, double amount, String currency) async {
    try {
      await _analytics.logEvent(
        name: 'purchase',
        parameters: {
          'plan_type': planType,
          'amount': amount,
          'currency': currency,
        },
      );
    } catch (e) {
      debugPrint('Analytics logPurchase error: $e');
    }
  }
}
