// lib/features/cameras/presentation/screens/live_stream_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/camera_cubit.dart';
import '../widgets/bounding_box_painter.dart';

class LiveStreamScreen extends StatefulWidget {
  final String? cameraId;

  const LiveStreamScreen({super.key, this.cameraId});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  bool _isFullScreen = false;
  Size? _streamSize;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  void _startStream() {
    if (widget.cameraId != null) {
      context.read<CameraCubit>().startStream(widget.cameraId!);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    context.read<CameraCubit>().stopStream();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isFullScreen) {
          _toggleFullScreen();
        } else {
          context.go('/home');
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.backgroundGradient,
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                top: !_isFullScreen,
                bottom: !_isFullScreen,
                child: BlocBuilder<CameraCubit, CameraState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        if (!_isFullScreen) _buildHeader(),
                        Expanded(
                          child: _buildStreamArea(state),
                        ),
                        if (!_isFullScreen) _buildControls(),
                      ],
                    );
                  },
                ),
              ),
              // Full Screen Back/Exit Controls
              if (_isFullScreen)
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  ),
                ),
              if (_isFullScreen)
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    onPressed: _toggleFullScreen,
                    icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
          ),
          const SizedBox(width: 12),
          const Text(
            'Live Stream',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            onPressed: _toggleFullScreen,
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamArea(CameraState state) {
    if (state is CameraStreamLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan));
    }

    if (state is CameraError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.statusError, size: 48),
            const SizedBox(height: 16),
            Text(state.message, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _startStream, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (state is CameraStreamActive) {
      return LayoutBuilder(
        builder: (context, constraints) {
          _streamSize = Size(constraints.maxWidth, constraints.maxHeight);

          return Center(
            child: Container(
              margin: _isFullScreen ? EdgeInsets.zero : const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: _isFullScreen ? BorderRadius.zero : BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  MJPEGStreamScreen(
                    showLiveIcon: true,
                    streamUrl: state.streamUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  // LIVE Label
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                      child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (state.boundingBoxes.isNotEmpty && _streamSize != null)
                    CustomPaint(
                      size: _streamSize!,
                      painter: BoundingBoxPainter(
                        boundingBoxes: state.boundingBoxes,
                        imageSize: _streamSize!,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    return const Center(child: Text('Stream inactive', style: TextStyle(color: Colors.white)));
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionBtn(Icons.fiber_manual_record, 'REC', Colors.red),
            _actionBtn(Icons.camera_alt, 'SNAP', AppTheme.accentCyan),
            _actionBtn(Icons.refresh, 'RELOAD', Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}