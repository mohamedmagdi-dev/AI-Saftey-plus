import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/glass_bottom_nav.dart';
import '../../../../core/widgets/camera_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/cubit/navigation_cubit.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../cubit/camera_cubit.dart';
import '../../domain/entities/camera_entity.dart';

class CameraListScreen extends StatefulWidget {
  const CameraListScreen({super.key});

  @override
  State<CameraListScreen> createState() => _CameraListScreenState();
}

class _CameraListScreenState extends State<CameraListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CameraCubit>().fetchCameras();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;

    return Scaffold(
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
            // Radial gradient overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.2, 0.3),
                      radius: 1.78,
                      colors: [
                        const Color(0x4C06B6D4),
                        Colors.black.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: BlocBuilder<NavigationCubit, NavigationState>(
                builder: (context, navState) {
                  return BlocBuilder<CameraCubit, CameraState>(
                    builder: (context, cameraState) {
                      return Column(
                        children: [
                          // Header
                          _buildHeader(
                            context,
                            isSmallScreen,
                            horizontalPadding,
                          ),
                          // Camera List
                          Expanded(
                            child: _buildCameraList(
                              context,
                              cameraState,
                              isSmallScreen,
                              horizontalPadding,
                            ),
                          ),
                          // Bottom Navigation
                          GlassBottomNav(
                            currentIndex: navState.selectedIndex,
                            onTap: (index) {
                              context.read<NavigationCubit>().changeIndex(
                                index,
                              );
                              _navigateToTab(context, index);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        isSmallScreen ? 16 : 24,
        horizontalPadding,
        16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cameras',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: isSmallScreen ? 24 : 28,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              BlocBuilder<CameraCubit, CameraState>(
                builder: (context, state) {
                  final count = state is CameraLoaded
                      ? state.cameras.length
                      : 0;
                  final onlineCount = state is CameraLoaded
                      ? state.cameras.where((c) => c.isOnline).length
                      : 0;
                  return Text(
                    '$onlineCount of $count online',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: isSmallScreen ? 13 : 14,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
            ],
          ),
          // Search/Filter button
          IconButton(
            onPressed: () {
              // TODO: Show search/filter dialog
            },
            icon: const Icon(Icons.search, color: AppTheme.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraList(
    BuildContext context,
    CameraState cameraState,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    if (cameraState is CameraLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
        ),
      );
    }

    if (cameraState is CameraError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppTheme.statusError, size: 48),
            const SizedBox(height: 16),
            Text(
              cameraState.message,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontFamily: 'Arimo',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<CameraCubit>().fetchCameras();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    List<CameraEntity> cameras = [];
    if (cameraState is CameraLoaded) {
      cameras = List<CameraEntity>.from(cameraState.cameras);
    }

    if (cameras.isEmpty) {
      return Center(
        child: Text(
          'No cameras found',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: isSmallScreen ? 15 : 16,
            fontFamily: 'Arimo',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      itemCount: cameras.length,
      itemBuilder: (context, index) {
        final camera = cameras[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CameraCard(
            cameraName: camera.name,
            location: camera.location,
            isOnline: camera.isOnline,
            thumbnailUrl: camera.thumbnailUrl,
            onTap: () {
              NavigationHelper.navigateToLiveStream(
                context,
                cameraId: camera.id,
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        NavigationHelper.navigateToHome(context);
        break;
      case 1:
        NavigationHelper.navigateToCameras(context);
        break;
      case 2:
        NavigationHelper.navigateToAnalytics(context);
        break;
      case 3:
        NavigationHelper.navigateToHistory(context);
        break;
      case 4:
        NavigationHelper.navigateToProfile(context);
        break;
    }
  }
}
