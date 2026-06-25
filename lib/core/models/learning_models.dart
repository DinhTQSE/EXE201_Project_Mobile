class Unit {
  final String unitId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final int chapterCount;
  final int orderIndex;

  Unit({
    required this.unitId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.chapterCount,
    required this.orderIndex,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unitId: json['unitId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      chapterCount: json['chapterCount'] is int ? json['chapterCount'] : int.tryParse(json['chapterCount']?.toString() ?? '') ?? 0,
      orderIndex: json['orderIndex'] is int ? json['orderIndex'] : int.tryParse(json['orderIndex']?.toString() ?? '') ?? 0,
    );
  }
}

class Chapter {
  final String chapterId;
  final String title;
  final String? description;
  final int lessonCount;
  final int orderIndex;
  final bool requiresPremium;
  final bool locked;
  final int completionPercent;

  Chapter({
    required this.chapterId,
    required this.title,
    this.description,
    required this.lessonCount,
    required this.orderIndex,
    required this.requiresPremium,
    required this.locked,
    required this.completionPercent,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      lessonCount: json['lessonCount'] is int ? json['lessonCount'] : int.tryParse(json['lessonCount']?.toString() ?? '') ?? 0,
      orderIndex: json['orderIndex'] is int ? json['orderIndex'] : int.tryParse(json['orderIndex']?.toString() ?? '') ?? 0,
      requiresPremium: json['requiresPremium'] == true,
      locked: json['locked'] == true,
      completionPercent: json['completionPercent'] is int ? json['completionPercent'] : int.tryParse(json['completionPercent']?.toString() ?? '') ?? 0,
    );
  }
}

class Lesson {
  final String lessonId;
  final String title;
  final String? description;
  final String? videoUrl;
  final int durationSeconds;
  final int orderIndex;
  final bool requiresPremium;
  final bool locked;
  final String status; // NOT_STARTED, IN_PROGRESS, COMPLETED

  Lesson({
    required this.lessonId,
    required this.title,
    this.description,
    this.videoUrl,
    required this.durationSeconds,
    required this.orderIndex,
    required this.requiresPremium,
    required this.locked,
    required this.status,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lessonId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      durationSeconds: json['durationSeconds'] is int ? json['durationSeconds'] : int.tryParse(json['durationSeconds']?.toString() ?? '') ?? 0,
      orderIndex: json['orderIndex'] is int ? json['orderIndex'] : int.tryParse(json['orderIndex']?.toString() ?? '') ?? 0,
      requiresPremium: json['requiresPremium'] == true,
      locked: json['locked'] == true,
      status: json['status']?.toString() ?? 'NOT_STARTED',
    );
  }
}

class PracticeItem {
  final String itemId;
  final String lessonId;
  final String label;
  final String category;
  final String level;
  final String expectedGloss;
  final String? sourceVideoFile;
  final String? videoUrl;

  PracticeItem({
    required this.itemId,
    required this.lessonId,
    required this.label,
    required this.category,
    required this.level,
    required this.expectedGloss,
    this.sourceVideoFile,
    this.videoUrl,
  });

  factory PracticeItem.fromJson(Map<String, dynamic> json) {
    return PracticeItem(
      itemId: json['itemId']?.toString() ?? json['id']?.toString() ?? '',
      lessonId: json['lessonId']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      expectedGloss: json['expectedGloss']?.toString() ?? '',
      sourceVideoFile: json['sourceVideoFile']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
    );
  }
}

class QuizOption {
  final String id;
  final String text;
  final String? videoUrl;

  QuizOption({
    required this.id,
    required this.text,
    this.videoUrl,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString(),
    );
  }
}

class QuizQuestion {
  final String id;
  final String prompt;
  final List<QuizOption> options;
  final String? correctAnswerId;

  QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    this.correctAnswerId,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      options: (json['options'] as List? ?? [])
          .map((item) => QuizOption.fromJson(item))
          .toList(),
      correctAnswerId: json['correctAnswerId']?.toString(),
    );
  }
}

class LessonQuiz {
  final String lessonId;
  final String quizId;
  final String attemptId;
  final List<QuizQuestion> questions;

  LessonQuiz({
    required this.lessonId,
    required this.quizId,
    required this.attemptId,
    required this.questions,
  });

  factory LessonQuiz.fromJson(Map<String, dynamic> json) {
    return LessonQuiz(
      lessonId: json['lessonId']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      attemptId: json['attemptId']?.toString() ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((item) => QuizQuestion.fromJson(item))
          .toList(),
    );
  }
}

class QuizSubmitResult {
  final String attemptId;
  final int score;
  final bool passed;
  final int xpAwarded;

  QuizSubmitResult({
    required this.attemptId,
    required this.score,
    required this.passed,
    required this.xpAwarded,
  });

  factory QuizSubmitResult.fromJson(Map<String, dynamic> json) {
    return QuizSubmitResult(
      attemptId: json['attemptId']?.toString() ?? '',
      score: json['score'] is int ? json['score'] : int.tryParse(json['score']?.toString() ?? '') ?? 0,
      passed: json['passed'] == true,
      xpAwarded: json['xpAwarded'] is int ? json['xpAwarded'] : int.tryParse(json['xpAwarded']?.toString() ?? '') ?? 0,
    );
  }
}

class SignatureAttemptResponse {
  final String attemptId;
  final String practiceItemId;
  final String status; // SUBMITTED, PASSED, RETRY_REQUIRED
  final double score;
  final String? warningMessage;

  SignatureAttemptResponse({
    required this.attemptId,
    required this.practiceItemId,
    required this.status,
    required this.score,
    this.warningMessage,
  });

  factory SignatureAttemptResponse.fromJson(Map<String, dynamic> json) {
    return SignatureAttemptResponse(
      attemptId: json['attemptId']?.toString() ?? '',
      practiceItemId: json['practiceItemId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'RETRY_REQUIRED',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      warningMessage: json['warningMessage']?.toString(),
    );
  }
}

class AiPredictionResponse {
  final String status;
  final String label;
  final double confidence;
  final int framesProcessed;
  final int handsDetectedFrames;
  final String? message;
  final double inferenceMs;
  final String? modelVersion;
  final String? labelVersion;

  AiPredictionResponse({
    required this.status,
    required this.label,
    required this.confidence,
    required this.framesProcessed,
    required this.handsDetectedFrames,
    this.message,
    required this.inferenceMs,
    this.modelVersion,
    this.labelVersion,
  });

  factory AiPredictionResponse.fromJson(Map<String, dynamic> json) {
    return AiPredictionResponse(
      status: json['status']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      framesProcessed: json['frames_processed'] is int
          ? json['frames_processed']
          : json['framesProcessed'] is int
              ? json['framesProcessed']
              : int.tryParse((json['frames_processed'] ?? json['framesProcessed'])?.toString() ?? '') ?? 0,
      handsDetectedFrames: json['hands_detected_frames'] is int
          ? json['hands_detected_frames']
          : json['handsDetectedFrames'] is int
              ? json['handsDetectedFrames']
              : int.tryParse((json['hands_detected_frames'] ?? json['handsDetectedFrames'])?.toString() ?? '') ?? 0,
      message: json['message']?.toString(),
      inferenceMs: (json['inference_ms'] ?? json['inferenceMs'] as num?)?.toDouble() ?? 0.0,
      modelVersion: (json['model_version'] ?? json['modelVersion'])?.toString(),
      labelVersion: (json['label_version'] ?? json['labelVersion'])?.toString(),
    );
  }
}
