import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:vsign_mobile_app/core/models/learning_models.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';
import 'package:vsign_mobile_app/features/course/bloc/course_bloc.dart';
import 'package:vsign_mobile_app/features/practice_ai/bloc/practice_ai_bloc.dart';
import 'package:vsign_mobile_app/features/practice_ai/presentation/camera_practice_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final String lessonId; // Actually represents the chapterId containing lessons
  const LessonDetailScreen({required this.lessonId, super.key});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  List<Lesson> _lessons = [];
  Lesson? _activeLesson;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Quiz state
  LessonQuiz? _activeQuiz;
  int _currentQuestionIndex = 0;
  String? _selectedOptionId;
  int _score = 0;
  bool _quizSubmitted = false;
  bool _quizPassed = false;
  bool _loadingQuiz = false;

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(LoadLessons(chapterId: widget.lessonId));
  }

  @override
  void dispose() {
    _disposeVideoPlayer();
    super.dispose();
  }

  void _disposeVideoPlayer() {
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
  }

  void _initializeVideo(String url) async {
    _disposeVideoPlayer();
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoController = controller;
    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        controller.play();
      }
    } catch (e) {
      // Handle video error
    }
  }

  void _onLessonSelected(Lesson lesson) {
    setState(() {
      _activeLesson = lesson;
      _activeQuiz = null;
      _quizSubmitted = false;
      _currentQuestionIndex = 0;
      _score = 0;
    });

    if (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty) {
      _initializeVideo(lesson.videoUrl!);
    } else {
      _disposeVideoPlayer();
    }
  }

  void _loadQuizForActiveLesson() async {
    if (_activeLesson == null) return;
    setState(() {
      _loadingQuiz = true;
    });
    try {
      final repository = GetIt.instance<LearningRepository>();
      final quiz = await repository.getLessonQuiz(_activeLesson!.lessonId);
      setState(() {
        _activeQuiz = quiz;
        _loadingQuiz = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingQuiz = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có đề trắc nghiệm cho bài học này.')),
      );
    }
  }

  void _submitAnswer() async {
    if (_activeQuiz == null || _selectedOptionId == null || _activeLesson == null) return;
    final question = _activeQuiz!.questions[_currentQuestionIndex];
    if (_selectedOptionId == question.correctAnswerId) {
      _score++;
    }

    if (_currentQuestionIndex < _activeQuiz!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionId = null;
      });
    } else {
      // Submit score to backend API
      setState(() {
        _loadingQuiz = true;
      });
      try {
        final repository = GetIt.instance<LearningRepository>();
        final result = await repository.submitQuiz(
          _activeLesson!.lessonId,
          _activeQuiz!.attemptId,
          _score,
        );
        if (!mounted) return;
        setState(() {
          _quizSubmitted = true;
          _quizPassed = result.passed;
          _loadingQuiz = false;
        });
        
        // Show XP success toast if passed
        if (result.passed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chúc mừng! Bạn đã nhận được +${result.xpAwarded} XP!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _loadingQuiz = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _activeLesson == null ? 'Danh sách bài học' : _activeLesson!.title,
          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_activeLesson != null) {
              setState(() {
                _activeLesson = null;
                _disposeVideoPlayer();
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is LessonsLoaded) {
            _lessons = state.lessons;
          }
        },
        builder: (context, state) {
          if (state is CourseLoading && _lessons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // If no active lesson is selected, show the list of lessons
          if (_activeLesson == null) {
            if (_lessons.isEmpty) {
              return const Center(child: Text('Không có bài học nào trong chương này.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _lessons.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                final isCompleted = lesson.status == 'COMPLETED';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCompleted ? Colors.green.withAlpha(30) : colorScheme.primary.withAlpha(20),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.play_arrow,
                      color: isCompleted ? Colors.green : colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    lesson.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    lesson.durationSeconds > 0
                        ? '${(lesson.durationSeconds / 60).round()} phút'
                        : 'Luyện tập cử chỉ',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _onLessonSelected(lesson),
                );
              },
            );
          }

          // Render active lesson study tabs (Video / Quiz / Practice)
          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.video_library), text: 'Bài giảng'),
                    Tab(icon: Icon(Icons.quiz), text: 'Trắc nghiệm'),
                    Tab(icon: Icon(Icons.camera_alt), text: 'Luyện tập AI'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // TAB 1: Lecture video stream
                      Column(
                        children: [
                          Expanded(
                            child: _videoController != null
                                ? _isVideoInitialized
                                    ? AspectRatio(
                                        aspectRatio: _videoController!.value.aspectRatio,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            VideoPlayer(_videoController!),
                                            VideoProgressIndicator(
                                              _videoController!,
                                              allowScrubbing: true,
                                            ),
                                          ],
                                        ),
                                      )
                                    : const Center(child: CircularProgressIndicator())
                                : const Center(
                                    child: Text('Không tìm thấy tệp video bài học.'),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _activeLesson?.description ?? 'Quan sát cử chỉ mẫu và thực hiện theo hướng dẫn.',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      // TAB 2: Multiple-choice quiz
                      _loadingQuiz
                          ? const Center(child: CircularProgressIndicator())
                          : _activeQuiz == null
                              ? Center(
                                  child: ElevatedButton(
                                    onPressed: _loadQuizForActiveLesson,
                                    child: const Text('Bắt đầu làm bài thi'),
                                  ),
                                )
                              : _quizSubmitted
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _quizPassed ? Icons.check_circle : Icons.cancel,
                                            size: 64,
                                            color: _quizPassed ? Colors.green : Colors.red,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _quizPassed ? 'ĐÃ ĐẠT BÀI THI' : 'CHƯA ĐẠT YÊU CẦU',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: _quizPassed ? Colors.green : Colors.red,
                                            ),
                                          ),
                                          Text(
                                            'Số câu đúng: $_score / ${_activeQuiz!.questions.length}',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 24),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _quizSubmitted = false;
                                                _currentQuestionIndex = 0;
                                                _score = 0;
                                                _selectedOptionId = null;
                                              });
                                            },
                                            child: const Text('Làm lại bài thi'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'Câu ${_currentQuestionIndex + 1}/${_activeQuiz!.questions.length}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _activeQuiz!.questions[_currentQuestionIndex].prompt,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 20),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: _activeQuiz!.questions[_currentQuestionIndex].options.length,
                                              itemBuilder: (context, oIndex) {
                                                final option = _activeQuiz!.questions[_currentQuestionIndex].options[oIndex];
                                                final isSelected = _selectedOptionId == option.id;
                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: 12),
                                                  child: OutlinedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _selectedOptionId = option.id;
                                                      });
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      backgroundColor: isSelected ? colorScheme.primary.withAlpha(20) : null,
                                                      side: BorderSide(
                                                        color: isSelected ? colorScheme.primary : colorScheme.outline,
                                                      ),
                                                      padding: const EdgeInsets.all(16),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        option.text,
                                                        style: TextStyle(
                                                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: _selectedOptionId == null ? null : _submitAnswer,
                                            child: const Text('Tiếp tục'),
                                          ),
                                        ],
                                      ),
                                    ),

                      // TAB 3: Camera AI Practice integration
                      BlocProvider(
                        create: (context) => PracticeAiBloc(),
                        child: CameraPracticeWidget(lessonId: _activeLesson!.lessonId),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CameraPracticeWidget extends StatefulWidget {
  final String lessonId;
  const CameraPracticeWidget({required this.lessonId, super.key});

  @override
  State<CameraPracticeWidget> createState() => _CameraPracticeWidgetState();
}

class _CameraPracticeWidgetState extends State<CameraPracticeWidget> {
  PracticeItem? _practiceItem;
  bool _loadingItem = false;

  @override
  void initState() {
    super.initState();
    _loadPracticeItem();
  }

  void _loadPracticeItem() async {
    setState(() {
      _loadingItem = true;
    });
    try {
      final repository = GetIt.instance<LearningRepository>();
      final items = await repository.listPracticeItems();
      final matchingItem = items.firstWhere(
        (item) => item.lessonId == widget.lessonId,
        orElse: () => items.first,
      );
      setState(() {
        _practiceItem = matchingItem;
        _loadingItem = false;
      });
    } catch (e) {
      setState(() {
        _loadingItem = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingItem) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_practiceItem == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Bài học này không có gói luyện tập ký hiệu đi kèm.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.camera_enhance, size: 60, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'Luyện tập ký hiệu: ${_practiceItem!.label}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy giữ camera trước thẳng khuôn mặt và thực hiện ký hiệu cử chỉ tay chuẩn xác.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: () {
              // Open Camera screen via platform channel
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<PracticeAiBloc>(),
                    child: CameraPracticeScreen(
                      practiceItemId: _practiceItem!.itemId,
                      targetGloss: _practiceItem!.expectedGloss,
                      label: _practiceItem!.label,
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.videocam),
            label: const Text('Bật Camera AI để Luyện tập'),
          ),
        ],
      ),
    );
  }
}
