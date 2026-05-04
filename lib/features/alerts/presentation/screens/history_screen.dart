import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_bottom_nav.dart';
import '../../../../core/widgets/alert_tile.dart';
import '../../../../core/widgets/status_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/cubit/navigation_cubit.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../cubit/alert_cubit.dart';
import '../../domain/entities/alert_entity.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Today', 'Week', 'Month'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AlertCubit>().fetchAlertHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  return BlocBuilder<AlertCubit, AlertState>(
                    builder: (context, alertState) {
                      return Column(
                        children: [
                          // Header
                          _buildHeader(context, isSmallScreen, horizontalPadding),
                          // Search and Filter
                          _buildSearchAndFilter(
                            context,
                            isSmallScreen,
                            horizontalPadding,
                          ),
                          // Alert List
                          Expanded(
                            child: _buildAlertList(
                              context,
                              alertState,
                              isSmallScreen,
                              horizontalPadding,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: isSmallScreen ? 24 : 30,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Past incidents timeline',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: isSmallScreen ? 14 : 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(
    BuildContext context,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          // Search Bar
          GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontFamily: 'Arimo',
              ),
              decoration: InputDecoration(
                hintText: 'Search alerts...',
                hintStyle: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 16,
                  fontFamily: 'Arimo',
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {});
                // TODO: Implement search filtering
              },
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filters.map((filter) {
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      // TODO: Implement filter logic
                    },
                    selectedColor: AppTheme.accentCyan.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.accentCyan
                          : AppTheme.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.accentCyan
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertList(
    BuildContext context,
    AlertState alertState,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    if (alertState is AlertLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
        ),
      );
    }

    if (alertState is AlertError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.statusError,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              alertState.message,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontFamily: 'Arimo',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    List<AlertEntity> alerts = [];
    if (alertState is AlertHistoryLoaded) {
      alerts = List<AlertEntity>.from(alertState.alerts);
    }

    // Apply search filter
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      alerts = alerts.where((alert) {
        return alert.title.toLowerCase().contains(searchQuery) ||
            alert.description.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Apply time filter
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Today':
        alerts = alerts.where((alert) {
          return alert.timestamp.year == now.year &&
              alert.timestamp.month == now.month &&
              alert.timestamp.day == now.day;
        }).toList();
        break;
      case 'Week':
        final weekAgo = now.subtract(const Duration(days: 7));
        alerts = alerts.where((alert) => alert.timestamp.isAfter(weekAgo)).toList();
        break;
      case 'Month':
        final monthAgo = now.subtract(const Duration(days: 30));
        alerts = alerts.where((alert) => alert.timestamp.isAfter(monthAgo)).toList();
        break;
    }

    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              color: AppTheme.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No alerts found',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        100,
      ),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AlertTile(
            title: alert.title,
            description: alert.description,
            timestamp: alert.timestamp,
            severity: _mapAlertSeverityToStatusType(alert.severity),
            onTap: () {
              // TODO: Navigate to alert details
            },
          ),
        );
      },
    );
  }

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
