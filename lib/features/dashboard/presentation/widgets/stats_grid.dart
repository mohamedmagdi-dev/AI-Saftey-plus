import 'package:flutter/material.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/theme/app_theme.dart';

class StatsGrid extends StatelessWidget {
  final int totalCameras;
  final int activeAlerts;
  final int totalDetections;
  final int onlineCameras;

  const StatsGrid({
    super.key,
    required this.totalCameras,
    required this.activeAlerts,
    required this.totalDetections,
    required this.onlineCameras,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final crossAxisCount = isSmallScreen ? 2 : 2;
    final childAspectRatio = isSmallScreen ? 1.1 : 1.2;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [

        StatCard(
          title: 'Total Cameras',
          value: totalCameras.toString(),
          subtitle: '$onlineCameras online',
          icon: Icons.videocam,
          iconColor: AppTheme.accentCyan,
          onTap: () {
            // Navigate to cameras screen
            NavigationHelper.navigateToCameras(context);
          },
        ),
        StatCard(
          title: 'Active Alerts',
          value: activeAlerts.toString(),
          subtitle: 'Requires attention',
          icon: Icons.notifications_active,
          iconColor: AppTheme.statusWarning,
          onTap: () {
            // Navigate to alerts screen
            //NavigationHelper.(context);
          },
        ),
        StatCard(
          title: 'Total Detections',
          value: totalDetections.toString(),
          subtitle: 'Today',
          icon: Icons.analytics,
          iconColor: AppTheme.accentGold,
          onTap: () {
            // Navigate to analytics screen
            NavigationHelper.navigateToAnalytics(context);
          },
        ),
        StatCard(
          title: 'System Status',
          value: 'Operational',
          subtitle: 'All systems normal',
          icon: Icons.check_circle,
          iconColor: AppTheme.statusOnline,
          onTap: () {
            // Navigate to settings
            NavigationHelper.navigateToSettings(context);
          },
        ),
      ],
    );
  }
}
