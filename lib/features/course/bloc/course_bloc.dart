import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vsign_mobile_app/core/models/learning_models.dart';
import 'package:vsign_mobile_app/core/network/analytics_service.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';

// --- Events ---
abstract class CourseEvent {}

class LoadUnits extends CourseEvent {}

class LoadChapters extends CourseEvent {
  final String unitId;
  LoadChapters({required this.unitId});
}

class LoadLessons extends CourseEvent {
  final String chapterId;
  LoadLessons({required this.chapterId});
}

class CompleteLessonRequested extends CourseEvent {
  final String lessonId;
  CompleteLessonRequested({required this.lessonId});
}

class LoadQuizRequested extends CourseEvent {
  final String lessonId;
  LoadQuizRequested({required this.lessonId});
}

class SubmitQuizRequested extends CourseEvent {
  final String lessonId;
  final String attemptId;
  final int score;
  SubmitQuizRequested({
    required this.lessonId,
    required this.attemptId,
    required this.score,
  });
}

// --- States ---
abstract class CourseState {}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class UnitsLoaded extends CourseState {
  final List<Unit> units;
  UnitsLoaded({required this.units});
}

class ChaptersLoaded extends CourseState {
  final List<Chapter> chapters;
  ChaptersLoaded({required this.chapters});
}

class LessonsLoaded extends CourseState {
  final List<Lesson> lessons;
  LessonsLoaded({required this.lessons});
}

class LessonCompletedSuccess extends CourseState {
  final String lessonId;
  LessonCompletedSuccess({required this.lessonId});
}

class QuizLoaded extends CourseState {
  final LessonQuiz quiz;
  QuizLoaded({required this.quiz});
}

class QuizSubmittedState extends CourseState {
  final QuizSubmitResult result;
  QuizSubmittedState({required this.result});
}

class CourseError extends CourseState {
  final String message;
  CourseError({required this.message});
}

// --- BLoC ---
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final LearningRepository _repository = GetIt.instance<LearningRepository>();
  final AnalyticsService _analytics = GetIt.instance<AnalyticsService>();

  CourseBloc() : super(CourseInitial()) {
    on<LoadUnits>(_onLoadUnits);
    on<LoadChapters>(_onLoadChapters);
    on<LoadLessons>(_onLoadLessons);
    on<CompleteLessonRequested>(_onCompleteLessonRequested);
    on<LoadQuizRequested>(_onLoadQuizRequested);
    on<SubmitQuizRequested>(_onSubmitQuizRequested);
  }

  Future<void> _onLoadUnits(LoadUnits event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final units = await _repository.listUnits();
      emit(UnitsLoaded(units: units));
    } catch (e) {
      emit(CourseError(message: 'Không thể tải danh sách khóa học.'));
    }
  }

  Future<void> _onLoadChapters(LoadChapters event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final chapters = await _repository.listChapters(event.unitId);
      emit(ChaptersLoaded(chapters: chapters));
    } catch (e) {
      emit(CourseError(message: 'Không thể tải danh sách chương học.'));
    }
  }

  Future<void> _onLoadLessons(LoadLessons event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final lessons = await _repository.listLessons(event.chapterId);
      emit(LessonsLoaded(lessons: lessons));
    } catch (e) {
      emit(CourseError(message: 'Không thể tải danh sách bài học.'));
    }
  }

  Future<void> _onCompleteLessonRequested(CompleteLessonRequested event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      await _repository.completeLesson(event.lessonId);
      await _analytics.logCompleteLesson(event.lessonId);
      emit(LessonCompletedSuccess(lessonId: event.lessonId));
    } catch (e) {
      emit(CourseError(message: 'Hoàn thành bài học thất bại. Vui lòng thử lại.'));
    }
  }

  Future<void> _onLoadQuizRequested(LoadQuizRequested event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final quiz = await _repository.getLessonQuiz(event.lessonId);
      emit(QuizLoaded(quiz: quiz));
    } catch (e) {
      emit(CourseError(message: 'Không thể tải đề thi trắc nghiệm.'));
    }
  }

  Future<void> _onSubmitQuizRequested(SubmitQuizRequested event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final result = await _repository.submitQuiz(event.lessonId, event.attemptId, event.score);
      emit(QuizSubmittedState(result: result));
    } catch (e) {
      emit(CourseError(message: 'Nộp bài thi thất bại. Vui lòng kiểm tra kết nối.'));
    }
  }
}
