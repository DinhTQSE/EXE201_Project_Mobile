import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:vsign_mobile_app/core/models/payment_models.dart';
import 'package:vsign_mobile_app/features/dictionary/bloc/dictionary_bloc.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'Chào hỏi',
    'Gia đình',
    'Ăn uống',
    'Thời gian',
    'Cảm xúc',
    'Du lịch',
    'Công việc',
    'Chuyên ngành',
  ];

  @override
  void initState() {
    super.initState();
    context.read<DictionaryBloc>().add(SearchWordRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<DictionaryBloc>().add(SearchWordRequested(
          word: _searchController.text.trim(),
          category: _selectedCategory,
        ));
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    context.read<DictionaryBloc>().add(SearchWordRequested(
          word: _searchController.text.trim(),
          category: category,
        ));
  }

  void _showWordVideoDialog(BuildContext context, DictionaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => DictionaryVideoDialog(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Từ điển Ký hiệu',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm từ vựng...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          // Categories horizontal chips list
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isAllSelected = _selectedCategory == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Tất cả'),
                      selected: isAllSelected,
                      onSelected: (_) => _onCategorySelected(null),
                    ),
                  );
                }

                final cat = _categories[index - 1];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      _onCategorySelected(selected ? cat : null);
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Dictionary Search results
          Expanded(
            child: BlocBuilder<DictionaryBloc, DictionaryState>(
              builder: (context, state) {
                if (state is DictionaryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DictionaryError) {
                  return Center(child: Text(state.message));
                }

                if (state is DictionaryLoaded) {
                  final entries = state.entries;
                  if (entries.isEmpty) {
                    return const Center(child: Text('Không tìm thấy từ vựng nào.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            entry.word,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(entry.category),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              entry.difficulty,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          onTap: () => _showWordVideoDialog(context, entry),
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text('Bắt đầu tra cứu từ điển'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DictionaryVideoDialog extends StatefulWidget {
  final DictionaryEntry entry;
  const DictionaryVideoDialog({required this.entry, super.key});

  @override
  State<DictionaryVideoDialog> createState() => _DictionaryVideoDialogState();
}

class _DictionaryVideoDialogState extends State<DictionaryVideoDialog> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  String _selectedRegion = 'BAC'; // Defaults to North region

  @override
  void initState() {
    super.initState();
    _loadRegionVideo();
  }

  void _loadRegionVideo() async {
    _videoController?.dispose();
    _videoController = null;
    _isInitialized = false;

    // Standard R2 video URL matching regions from the backfill rules
    String suffix = '';
    if (_selectedRegion == 'TRUNG') suffix = 'T';
    if (_selectedRegion == 'NAM') suffix = 'N';

    // Parse R2 filename representation e.g. videos/W00489.mp4
    final originalUrl = widget.entry.videoUrl ?? '';
    String videoUrl = originalUrl;
    
    if (suffix.isNotEmpty && originalUrl.contains('.mp4')) {
      videoUrl = originalUrl.replaceAll('.mp4', '$suffix.mp4');
    }

    if (videoUrl.isEmpty) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoController = controller;

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        controller.play();
      }
    } catch (e) {
      // Handle loading error - fallback to original url if region fails
      if (videoUrl != originalUrl) {
        setState(() {
          _selectedRegion = 'BAC';
        });
        _loadRegionVideo();
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.entry.word,
              style: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video Player
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _videoController != null
                ? _isInitialized
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator())
                : const Center(child: Text('Không có video cho từ vựng này.')),
          ),
          const SizedBox(height: 16),

          // Region selector buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRegionButton('Bắc', 'BAC', colorScheme),
              _buildRegionButton('Trung', 'TRUNG', colorScheme),
              _buildRegionButton('Nam', 'NAM', colorScheme),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            widget.entry.description,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRegionButton(String label, String value, ColorScheme colorScheme) {
    final isSelected = _selectedRegion == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRegion = value;
          });
          _loadRegionVideo();
        }
      },
    );
  }
}
