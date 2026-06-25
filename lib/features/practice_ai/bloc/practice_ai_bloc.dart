import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vsign_mobile_app/core/models/learning_models.dart';
import 'package:vsign_mobile_app/core/network/analytics_service.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';
import 'package:vsign_mobile_app/features/practice_ai/native/native_ai_service.dart';

// --- Events ---
abstract class PracticeAiEvent {}

class StartScanRequested extends PracticeAiEvent {
  final String practiceItemId;
  final String targetGloss;
  StartScanRequested({required this.practiceItemId, required this.targetGloss});
}

class StopScanRequested extends PracticeAiEvent {}

class LandmarkFrameReceived extends PracticeAiEvent {
  final List<double> coordinates;
  LandmarkFrameReceived({required this.coordinates});
}

class SubmitAttemptRequested extends PracticeAiEvent {}

// --- States ---
abstract class PracticeAiState {}

class PracticeAiInitial extends PracticeAiState {}

class PracticeAiScanning extends PracticeAiState {
  final List<double> currentFrame;
  final int totalFramesCaptured;
  PracticeAiScanning({required this.currentFrame, required this.totalFramesCaptured});
}

class PracticeAiSubmitting extends PracticeAiState {}

class PracticeAiSuccess extends PracticeAiState {
  final SignatureAttemptResponse result;
  PracticeAiSuccess({required this.result});
}

class PracticeAiFailure extends PracticeAiState {
  final String message;
  PracticeAiFailure({required this.message});
}

// --- BLoC ---
class PracticeAiBloc extends Bloc<PracticeAiEvent, PracticeAiState> {
  final LearningRepository _repository = GetIt.instance<LearningRepository>();
  final NativeAiService _nativeAi = NativeAiService();
  final AnalyticsService _analytics = GetIt.instance<AnalyticsService>();
  
  StreamSubscription<List<double>>? _streamSubscription;
  DateTime? _startTime;
  
  String? _currentPracticeItemId;
  String? _currentTargetGloss;
  final List<List<double>> _accumulatedFrames = [];

  PracticeAiBloc() : super(PracticeAiInitial()) {
    on<StartScanRequested>(_onStartScanRequested);
    on<StopScanRequested>(_onStopScanRequested);
    on<LandmarkFrameReceived>(_onLandmarkFrameReceived);
    on<SubmitAttemptRequested>(_onSubmitAttemptRequested);
  }

  Future<void> _onStartScanRequested(StartScanRequested event, Emitter<PracticeAiState> emit) async {
    emit(PracticeAiSubmitting());
    _currentPracticeItemId = event.practiceItemId;
    _currentTargetGloss = event.targetGloss;
    _accumulatedFrames.clear();
    _startTime = DateTime.now();

    final started = await _nativeAi.startLandmarkExtraction(targetLabel: event.targetGloss);
    if (!started) {
      emit(PracticeAiFailure(message: 'Không thể kết nối với phần cứng camera hoặc MediaPipe SDK.'));
      return;
    }

    await _analytics.logUseAiCamera(event.practiceItemId, event.targetGloss);
    emit(PracticeAiScanning(currentFrame: const [], totalFramesCaptured: 0));

    // Cancel old subscription if any
    await _streamSubscription?.cancel();
    _streamSubscription = _nativeAi.landmarkStream.listen((frame) {
      add(LandmarkFrameReceived(coordinates: frame));
    }, onError: (err) {
      add(StopScanRequested());
    });
  }

  void _onLandmarkFrameReceived(LandmarkFrameReceived event, Emitter<PracticeAiState> emit) {
    if (state is PracticeAiScanning) {
      _accumulatedFrames.add(event.coordinates);
      emit(PracticeAiScanning(
        currentFrame: event.coordinates,
        totalFramesCaptured: _accumulatedFrames.length,
      ));
    }
  }

  Future<void> _onStopScanRequested(StopScanRequested event, Emitter<PracticeAiState> emit) async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    await _nativeAi.stopLandmarkExtraction();
    
    if (_accumulatedFrames.isEmpty) {
      emit(PracticeAiInitial());
      return;
    }

    add(SubmitAttemptRequested());
  }

  Future<void> _onSubmitAttemptRequested(SubmitAttemptRequested event, Emitter<PracticeAiState> emit) async {
    if (_currentPracticeItemId == null || _currentTargetGloss == null || _startTime == null) {
      emit(PracticeAiFailure(message: 'Dữ liệu quét không hợp lệ.'));
      return;
    }

    emit(PracticeAiSubmitting());
    final durationMs = DateTime.now().difference(_startTime!).inMilliseconds;

    try {
      // 1. Calculate count of frames where hands are detected
      int handsDetectedFrames = 0;
      for (final frame in _accumulatedFrames) {
        if (frame.length >= 258) {
          bool hasHand = false;
          for (int i = 132; i < 258; i++) {
            if (frame[i] != 0.0) {
              hasHand = true;
              break;
            }
          }
          if (hasHand) {
            handsDetectedFrames++;
          }
        }
      }

      // 2. Call backend predict-landmarks to get actual prediction and confidence
      final prediction = await _repository.predictLandmarks(
        sequence: _accumulatedFrames,
        handsDetectedFrames: handsDetectedFrames,
        targetGloss: _currentTargetGloss!,
      );

      // 3. Format sequence to a string vector representation (similar to compact landmarker sequence)
      final String vectorString = _accumulatedFrames
          .map((frame) => frame.join(','))
          .join(';');

      // 4. Submit the attempt with real prediction data
      final correct = prediction.label.trim().toUpperCase() == _currentTargetGloss!.trim().toUpperCase();
      final response = await _repository.submitSignatureAttempt(
        practiceItemId: _currentPracticeItemId!,
        durationMs: durationMs,
        signatureVector: vectorString,
        targetGloss: _currentTargetGloss!,
        predictedGloss: prediction.label,
        confidence: prediction.confidence,
        correct: correct,
      );

      emit(PracticeAiSuccess(result: response));
    } catch (e) {
      emit(PracticeAiFailure(message: 'Không thể gửi kết quả tập luyện lên máy chủ AI.'));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    _nativeAi.stopLandmarkExtraction();
    return super.close();
  }
}
