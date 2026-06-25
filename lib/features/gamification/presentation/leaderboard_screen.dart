import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vsign_mobile_app/core/models/gamification_models.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';
import 'package:vsign_mobile_app/features/gamification/bloc/gamification_bloc.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedPeriod = 'WEEKLY'; // WEEKLY, MONTHLY
  List<LeaderboardEntry> _entries = [];
  GamificationSummary? _summary;
  bool _loadingLeaderboard = false;

  @override
  void initState() {
    super.initState();
    context.read<GamificationBloc>().add(LoadGamificationSummary());
    _loadLeaderboard();
  }

  void _loadLeaderboard() async {
    setState(() {
      _loadingLeaderboard = true;
    });
    try {
      final repository = GetIt.instance<GamificationRepository>();
      final list = await repository.getLeaderboard(_selectedPeriod);
      setState(() {
        _entries = list;
        _loadingLeaderboard = false;
      });
    } catch (e) {
      setState(() {
        _loadingLeaderboard = false;
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
          'Bảng vinh danh',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: BlocConsumer<GamificationBloc, GamificationState>(
        listener: (context, state) {
          if (state is GamificationSummaryLoaded) {
            _summary = state.summary;
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User XP & Streak dashboard header card
              if (_summary != null)
                Card(
                  margin: const EdgeInsets.all(16),
                  color: colorScheme.primary.withAlpha(15),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(LucideIcons.star, color: Colors.amber, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              '${_summary!.totalXp} XP',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text('Kinh nghiệm', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(LucideIcons.flame, color: Colors.orange, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              '${_summary!.currentStreak} ngày',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text('Streak hiện tại', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(LucideIcons.award, color: Colors.purple, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              '${_summary!.badges.length}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text('Huy hiệu', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Segment controller for Weekly vs Monthly
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'WEEKLY', label: Text('Tuần này')),
                    ButtonSegment(value: 'MONTHLY', label: Text('Tháng này')),
                  ],
                  selected: {_selectedPeriod},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _selectedPeriod = selection.first;
                    });
                    _loadLeaderboard();
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Leaderboard ranks list
              Expanded(
                child: _loadingLeaderboard
                    ? const Center(child: CircularProgressIndicator())
                    : _entries.isEmpty
                        ? const Center(child: Text('Không có dữ liệu bảng xếp hạng.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              final entry = _entries[index];
                              final isTop3 = entry.rank <= 3;
                              
                              Color rankColor = colorScheme.onSurface;
                              if (entry.rank == 1) rankColor = Colors.amber;
                              if (entry.rank == 2) rankColor = Colors.grey;
                              if (entry.rank == 3) rankColor = Colors.brown;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                color: isTop3 ? colorScheme.primary.withAlpha(8) : null,
                                child: ListTile(
                                  leading: Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isTop3 ? rankColor.withAlpha(40) : Colors.transparent,
                                    ),
                                    child: isTop3
                                        ? Icon(
                                            Icons.emoji_events,
                                            color: rankColor,
                                            size: 20,
                                          )
                                        : Text(
                                            '#${entry.rank}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                  title: Text(
                                    entry.fullName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Text(
                                    '${entry.xp} XP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
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
