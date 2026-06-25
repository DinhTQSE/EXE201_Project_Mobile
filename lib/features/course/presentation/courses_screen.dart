import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:vsign_mobile_app/core/models/learning_models.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';
import 'package:vsign_mobile_app/features/course/bloc/course_bloc.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String? _selectedUnitId;
  List<Unit> _units = [];
  List<Chapter> _chapters = [];
  bool _loadingChapters = false;

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(LoadUnits());
  }

  void _onUnitSelected(String unitId) async {
    setState(() {
      _selectedUnitId = unitId;
      _loadingChapters = true;
      _chapters = [];
    });
    try {
      final repository = GetIt.instance<LearningRepository>();
      final list = await repository.listChapters(unitId);
      setState(() {
        _chapters = list;
        _loadingChapters = false;
      });
    } catch (e) {
      setState(() {
        _loadingChapters = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'V-Sign - Học tập',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is UnitsLoaded && state.units.isNotEmpty) {
            _units = state.units;
            if (_selectedUnitId == null) {
              _onUnitSelected(state.units.first.unitId);
            }
          }
        },
        builder: (context, state) {
          if (state is CourseLoading && _units.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CourseError && _units.isEmpty) {
            return Center(child: Text(state.message));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Horizontal Units list
              if (_units.isNotEmpty)
                Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _units.length,
                    itemBuilder: (context, index) {
                      final unit = _units[index];
                      final isSelected = _selectedUnitId == unit.unitId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            unit.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: colorScheme.primary,
                          onSelected: (selected) {
                            if (selected) {
                              _onUnitSelected(unit.unitId);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

              // Chapters list in selected Unit
              Expanded(
                child: _loadingChapters
                    ? const Center(child: CircularProgressIndicator())
                    : _chapters.isEmpty
                        ? const Center(child: Text('Chưa có chương học nào cho phần này.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _chapters.length,
                            itemBuilder: (context, index) {
                              final chapter = _chapters[index];
                              final isLocked = chapter.locked;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: InkWell(
                                  onTap: () {
                                    if (isLocked) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Chương học này yêu cầu tài khoản PREMIUM.'),
                                          backgroundColor: Colors.amber,
                                        ),
                                      );
                                    } else {
                                      // Push to chapter's lessons list
                                      context.push('/lesson/${chapter.chapterId}');
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                chapter.title,
                                                style: GoogleFonts.baloo2(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isLocked ? Colors.grey : colorScheme.onSurface,
                                                ),
                                              ),
                                            ),
                                            if (isLocked)
                                              const Icon(Icons.lock, color: Colors.grey)
                                            else
                                              Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.primary),
                                          ],
                                        ),
                                        if (chapter.description != null && chapter.description!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            chapter.description!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${chapter.lessonCount} bài học',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${chapter.completionPercent}% hoàn thành',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        LinearPercentIndicator(
                                          lineHeight: 6.0,
                                          percent: chapter.completionPercent / 100.0,
                                          barRadius: const Radius.circular(3),
                                          padding: EdgeInsets.zero,
                                          progressColor: colorScheme.primary,
                                          backgroundColor: colorScheme.primary.withAlpha(30),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
