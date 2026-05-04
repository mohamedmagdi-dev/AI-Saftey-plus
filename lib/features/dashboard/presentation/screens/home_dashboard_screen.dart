import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_bottom_nav.dart';
import '../../../../core/widgets/alert_tile.dart';
import '../../../../core/widgets/status_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/cubit/navigation_cubit.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../alerts/presentation/cubit/alert_cubit.dart';
import '../../../alerts/domain/entities/alert_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cameras/presentation/cubit/camera_cubit.dart';
import '../../../reports/presentation/cubit/reports_cubit.dart';
import '../widgets/stats_grid.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthCubit>().refreshProfile();
      context.read<CameraCubit>().fetchCameras();
      context.read<AlertCubit>().fetchAlerts();
      context.read<ReportsCubit>().loadSummary(period: 'week');
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
                      return BlocBuilder<ReportsCubit, ReportsState>(
                        builder: (context, reportsState) {
                          return BlocBuilder<AlertCubit, AlertState>(
                            builder: (context, alertState) {
                              return _buildMainColumn(
                                context,
                                navState,
                                cameraState,
                                reportsState,
                                alertState,
                                isSmallScreen,
                                horizontalPadding,
                              );
                            },
                          );
                        },
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

  Widget _buildMainColumn(
    BuildContext context,
    NavigationState navState,
    CameraState cameraState,
    ReportsState reportsState,
    AlertState alertState,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    final totalCameras =
        cameraState is CameraLoaded ? cameraState.cameras.length : 0;
    final onlineCameras = cameraState is CameraLoaded
        ? cameraState.cameras.where((c) => c.isOnline).length
        : 0;
    final activeAlerts = reportsState is ReportsLoaded
        ? reportsState.summary.criticalAlerts
        : (alertState is AlertLoaded ? alertState.alerts.length : 0);
    final totalDetections = reportsState is ReportsLoaded
        ? reportsState.summary.totalAlerts
        : (alertState is AlertLoaded ? alertState.alerts.length : 0);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isSmallScreen ? 16 : 24),
                _buildHeader(context, isSmallScreen),
                SizedBox(height: isSmallScreen ? 24 : 32),
                StatsGrid(
                  totalCameras: totalCameras,
                  activeAlerts: activeAlerts,
                  totalDetections: totalDetections,
                  onlineCameras: onlineCameras,
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
                _buildRecentAlertsSection(
                  context,
                  alertState,
                  isSmallScreen,
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
                _buildQuickActions(context, isSmallScreen),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
        GlassBottomNav(
          currentIndex: navState.selectedIndex,
          onTap: (index) {
            context.read<NavigationCubit>().changeIndex(index);
            _navigateToTab(context, index);
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: isSmallScreen ? 13 : 14,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 4),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final displayName = authState is AuthAuthenticated &&
                          authState.profile != null
                      ? authState.profile!.username
                      : 'User';
                  return Text(
                    displayName,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Profile Avatar
        GestureDetector(
          onTap: () => NavigationHelper.navigateToProfile(context),
          child: Container(
            width: isSmallScreen ? 44 : 48,
            height: isSmallScreen ? 44 : 48,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.accentCyan, AppTheme.accentCyanDark],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              shadows: [
                BoxShadow(
                  color: AppTheme.accentGold.withValues(alpha: 0.3),
                  blurRadius: 0,
                  offset: Offset.zero,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAlertsSection(
    BuildContext context,
    AlertState alertState,
    bool isSmallScreen,
  ) {
    final recentAlerts = <_AlertDisplay>[];
    if (alertState is AlertLoaded && alertState.alerts.isNotEmpty) {
      recentAlerts.addAll(
        alertState.alerts.take(3).map(
              (alert) => _AlertDisplay(
                title: alert.title,
                description: alert.description,
                timestamp: alert.timestamp,
                severity: _mapAlertSeverityToStatusType(alert.severity),
              ),
            ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Alerts',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: isSmallScreen ? 18 : 20,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
              ),
            ),
            TextButton(
              onPressed: () => NavigationHelper.navigateToHistory(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppTheme.accentCyan,
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentAlerts.isEmpty)
          Text(
            alertState is AlertLoading
                ? 'Loading alerts...'
                : 'No recent alerts',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: isSmallScreen ? 14 : 15,
              fontFamily: 'Arimo',
            ),
          )
        else
          ...recentAlerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AlertTile(
                  title: alert.title,
                  description: alert.description,
                  timestamp: alert.timestamp,
                  severity: alert.severity,
                  onTap: () {
                    NavigationHelper.navigateToHistory(context);
                  },
                ),
              )),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: isSmallScreen ? 18 : 20,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.videocam,
                label: 'View Cameras',
                color: AppTheme.accentCyan,
                onTap: () => NavigationHelper.navigateToCameras(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.analytics,
                label: 'Analytics',
                color: AppTheme.accentGold,
                onTap: () => NavigationHelper.navigateToAnalytics(context),
              ),
            ),
          ],
        ),
      ],
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: ShapeDecoration(
                color: color.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alert display helper class
class _AlertDisplay {
  final String title;
  final String description;
  final DateTime timestamp;
  final StatusType severity;

  _AlertDisplay({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
  });
}

// Helper to map AlertSeverity to StatusType
StatusType _mapAlertSeverityToStatusType(AlertSeverity severity) {
  switch (severity) {
    case AlertSeverity.low:
      return StatusType.online;
    case AlertSeverity.medium:
      return StatusType.warning;
    case AlertSeverity.high:
      return StatusType.warning;
    case AlertSeverity.critical:
      return StatusType.error;
  }
}
