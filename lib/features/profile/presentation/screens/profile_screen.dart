import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_bottom_nav.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/cubit/navigation_cubit.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cameras/presentation/cubit/camera_cubit.dart';
import '../../../reports/presentation/cubit/reports_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthCubit>().refreshProfile();
      context.read<CameraCubit>().fetchCameras();
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
                  return Column(
                    children: [
                      // Header
                      _buildHeader(context, isSmallScreen, horizontalPadding),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Column(
                            children: [
                              SizedBox(height: isSmallScreen ? 16 : 24),
                              // Profile Card
                              _buildProfileCard(context, isSmallScreen),
                              SizedBox(height: isSmallScreen ? 16 : 24),
                              // Account Settings
                              _buildSection(
                                context,
                                'Account Settings',
                                [
                                  _SettingsItem(
                                    icon: Icons.person_outline,
                                    title: 'Edit Profile',
                                    onTap: () {
                                      // TODO: Navigate to edit profile
                                    },
                                  ),
                                  _SettingsItem(
                                    icon: Icons.notifications_outlined,
                                    title: 'Notifications',
                                    onTap: () {
                                      // TODO: Navigate to notifications settings
                                    },
                                  ),
                                  _SettingsItem(
                                    icon: Icons.lock_outline,
                                    title: 'Security',
                                    onTap: () {
                                      // TODO: Navigate to security settings
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 16 : 24),
                              // App Settings
                              _buildSection(
                                context,
                                'App Settings',
                                [
                                  _SettingsItem(
                                    icon: Icons.dark_mode_outlined,
                                    title: 'Theme',
                                    subtitle: 'Dark',
                                    onTap: () {
                                      // TODO: Show theme selector
                                    },
                                  ),
                                  _SettingsItem(
                                    icon: Icons.language_outlined,
                                    title: 'Language',
                                    subtitle: 'English',
                                    onTap: () {
                                      // TODO: Show language selector
                                    },
                                  ),
                                  _SettingsItem(
                                    icon: Icons.storage_outlined,
                                    title: 'Storage',
                                    subtitle: '2.4 GB used',
                                    onTap: () {
                                      // TODO: Navigate to storage settings
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 16 : 24),
                              // Support
                              _buildSection(
                                context,
                                'Support',
                                [
                                  _SettingsItem(
                                    icon: Icons.help_outline,
                                    title: 'Help Center',
                                    onTap: () {
                                      // TODO: Open help center
                                    },
                                  ),
                                  _SettingsItem(
                                    icon: Icons.feedback_outlined,
                                    title: 'Send Feedback',
                                    onTap: () {
                                      // TODO: Open feedback form
                                    },
                                  ),
                                  _SettingsItem(
                                    icon: Icons.info_outline,
                                    title: 'About',
                                    subtitle: 'Version 1.0.0',
                                    onTap: () {
                                      // TODO: Show about dialog
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 16 : 24),
                              // Logout Button
                              _buildLogoutButton(context, isSmallScreen),
                              SizedBox(height: 100), // Space for bottom nav
                            ],
                          ),
                        ),
                      ),
                      // Bottom Navigation
                      GlassBottomNav(
                        currentIndex: navState.selectedIndex,
                        onTap: (index) {
                          context.read<NavigationCubit>().changeIndex(index);
                          _navigateToTab(context, index);
                        },
                      ),
                    ],
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
          Text(
            'Profile',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: isSmallScreen ? 24 : 30,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          IconButton(
            onPressed: () {
              NavigationHelper.navigateToSettings(context);
            },
            icon: const Icon(
              Icons.settings,
              color: AppTheme.textPrimary,
            ),
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

  Widget _buildProfileCard(BuildContext context, bool isSmallScreen) {
    return GlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
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
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final name = authState is AuthAuthenticated &&
                      authState.profile != null
                  ? authState.profile!.username
                  : 'User';
              final email = authState is AuthAuthenticated &&
                      authState.profile?.email != null &&
                      authState.profile!.email!.isNotEmpty
                  ? authState.profile!.email!
                  : null;
              return Column(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email ?? 'Sign in to sync your profile',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<CameraCubit, CameraState>(
            builder: (context, cameraState) {
              return BlocBuilder<ReportsCubit, ReportsState>(
                builder: (context, reportsState) {
                  final camCount = cameraState is CameraLoaded
                      ? cameraState.cameras.length.toString()
                      : '—';
                  final alertTotal = reportsState is ReportsLoaded
                      ? reportsState.summary.totalAlerts.toString()
                      : '—';
                  final unique = reportsState is ReportsLoaded
                      ? reportsState.summary.uniqueCameras.toString()
                      : '—';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(label: 'Cameras', value: camCount),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      _StatItem(label: 'Alerts', value: alertTotal),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      _StatItem(label: 'Sites', value: unique),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<_SettingsItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        GlassContainer(
          borderRadius: 16,
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: AppTheme.accentCyan,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontFamily: 'Arimo',
                            ),
                          )
                        : null,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondary,
                    ),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white.withValues(alpha: 0.1),
                      indent: 60,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isSmallScreen) {
    return GlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: ShapeDecoration(
            color: AppTheme.statusError.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Icon(
            Icons.logout,
            color: AppTheme.statusError,
            size: 20,
          ),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppTheme.statusError,
            fontSize: 16,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w400,
          ),
        ),
        onTap: () {
          // TODO: Implement logout
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.secondaryDark,
              title: const Text(
                'Logout',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await context.read<AuthCubit>().logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: AppTheme.statusError),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
