import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vsign_mobile_app/features/practice_ai/bloc/practice_ai_bloc.dart';

class CameraPracticeScreen extends StatefulWidget {
  final String practiceItemId;
  final String targetGloss;
  final String label;

  const CameraPracticeScreen({
    required this.practiceItemId,
    required this.targetGloss,
    required this.label,
    super.key,
  });

  @override
  State<CameraPracticeScreen> createState() => _CameraPracticeScreenState();
}

class _CameraPracticeScreenState extends State<CameraPracticeScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    // Use front camera for practice if available
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // Handle camera init failure
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleScan() {
    final bloc = context.read<PracticeAiBloc>();
    if (_isScanning) {
      bloc.add(StopScanRequested());
      setState(() {
        _isScanning = false;
      });
    } else {
      bloc.add(StartScanRequested(
        practiceItemId: widget.practiceItemId,
        targetGloss: widget.targetGloss,
      ));
      setState(() {
        _isScanning = true;
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
          'Camera AI - ${widget.label}',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<PracticeAiBloc, PracticeAiState>(
        listener: (context, state) {
          if (state is PracticeAiSuccess) {
            final result = state.result;
            final isPassed = result.status == 'PASSED';
            
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Text(
                  isPassed ? 'KẾT QUẢ: ĐẠT' : 'KẾT QUẢ: CHƯA ĐẠT',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green : Colors.red,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPassed ? Icons.check_circle : Icons.replay,
                      size: 60,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Độ chính xác cử chỉ: ${(result.score * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (result.warningMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        result.warningMessage!,
                        style: const TextStyle(fontSize: 12, color: Colors.amber),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (isPassed) {
                        Navigator.of(context).pop(); // Back to lesson detail screen
                      }
                    },
                    child: Text(isPassed ? 'Tiếp tục' : 'Luyện tập lại'),
                  ),
                ],
              ),
            );
          } else if (state is PracticeAiFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera Preview
              if (_isCameraInitialized && _cameraController != null)
                CameraPreview(_cameraController!)
              else
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // Scanning Overlay Outline
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 280,
                  height: 380,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isScanning ? Colors.green : Colors.white.withAlpha(120),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: _isScanning
                      ? const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text(
                              'ĐANG QUÉT CỬ CHỈ...',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.black26,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              ),

              // Control panel
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Card(
                  color: Colors.black.withAlpha(180),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ký hiệu cần thực hiện: ${widget.label}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state is PracticeAiSubmitting)
                          const CircularProgressIndicator(color: Colors.white)
                        else
                          ElevatedButton.icon(
                            onPressed: _toggleScan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isScanning ? Colors.red : colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                            icon: Icon(_isScanning ? Icons.stop : Icons.fiber_manual_record),
                            label: Text(
                              _isScanning ? 'Hoàn thành cử chỉ' : 'Bắt đầu ghi cử chỉ',
                            ),
                          ),
                        if (state is PracticeAiScanning) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Số khung hình đã thu thập: ${state.totalFramesCaptured}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
