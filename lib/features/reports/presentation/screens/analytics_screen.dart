import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_bottom_nav.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/cubit/navigation_cubit.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../domain/models/report_summary_model.dart';
import '../../domain/models/report_timeline_model.dart';
import '../cubit/reports_cubit.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTimeRange = '7 Days';
  final List<String> _timeRanges = ['24 Hours', '7 Days', '30 Days', '90 Days'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReportsCubit>().loadAnalytics(
            period: _apiPeriodForRange(_selectedTimeRange),
          );
    });
  }

  String _apiPeriodForRange(String range) {
    switch (range) {
      case '24 Hours':
        return 'today';
      case '7 Days':
        return 'week';
      case '30 Days':
        return 'month';
      case '90 Days':
        return 'all';
      default:
        return 'week';
    }
  }

  String _shortLabel(String label, int index, int total) {
    if (label.length <= 6) return label;
    if (total <= 8) return label.length > 8 ? '${label.substring(0, 7)}…' : label;
    if (index % ((total / 6).ceil()) != 0 && index != total - 1) return '';
    return label.length > 5 ? '${label.substring(0, 4)}…' : label;
  }

  List<FlSpot> _spotsFromSummary(ReportSummaryModel summary) {
    final pts = summary.timeDistribution;
    if (pts.isEmpty) {
      return [const FlSpot(0, 0)];
    }
    return List.generate(
      pts.length,
      (i) => FlSpot(i.toDouble(), pts[i].count.toDouble()),
    );
  }

  List<FlSpot> _spotsFromTimeline(ReportTimelineModel? timeline) {
    if (timeline == null || timeline.points.isEmpty) {
      return [const FlSpot(0, 0)];
    }
    final pts = timeline.points;
    return List.generate(
      pts.length,
      (i) => FlSpot(i.toDouble(), pts[i].total.toDouble()),
    );
  }

  double _maxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;
    final m = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    return m <= 0 ? 10 : m * 1.15;
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
                        child: BlocBuilder<ReportsCubit, ReportsState>(
                          builder: (context, reportsState) {
                            if (reportsState is ReportsLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.accentCyan,
                                  ),
                                ),
                              );
                            }
                            if (reportsState is ReportsError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
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
                                        reportsState.message,
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
                                          context.read<ReportsCubit>().loadAnalytics(
                                                period: _apiPeriodForRange(
                                                  _selectedTimeRange,
                                                ),
                                              );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.accentCyan,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            if (reportsState is! ReportsLoaded) {
                              return const SizedBox.shrink();
                            }
                            final summary = reportsState.summary;
                            final timeline = reportsState.timeline;
                            return SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: isSmallScreen ? 16 : 24),
                                  _buildTimeRangeSelector(
                                    context,
                                    isSmallScreen,
                                  ),
                                  SizedBox(height: isSmallScreen ? 16 : 24),
                                  _buildSummaryStats(
                                    context,
                                    isSmallScreen,
                                    summary,
                                  ),
                                  SizedBox(height: isSmallScreen ? 16 : 24),
                                  _buildDetectionChart(
                                    context,
                                    isSmallScreen,
                                    summary,
                                  ),
                                  SizedBox(height: isSmallScreen ? 16 : 24),
                                  _buildActivityChart(
                                    context,
                                    isSmallScreen,
                                    summary,
                                    timeline,
                                  ),
                                  SizedBox(height: isSmallScreen ? 16 : 24),
                                  _buildTopDetections(
                                    context,
                                    isSmallScreen,
                                    summary,
                                  ),
                                  SizedBox(height: 100),
                                ],
                              ),
                            );
                          },
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
            'Reports',
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
              // TODO: Show export/share options
            },
            icon: const Icon(
              Icons.share,
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

  Widget _buildTimeRangeSelector(BuildContext context, bool isSmallScreen) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _timeRanges.map((range) {
          final isSelected = range == _selectedTimeRange;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTimeRange = range;
                });
                context.read<ReportsCubit>().loadAnalytics(
                      period: _apiPeriodForRange(range),
                    );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 8 : 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentCyan.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  range,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.accentCyan
                        : AppTheme.textSecondary,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryStats(
    BuildContext context,
    bool isSmallScreen,
    ReportSummaryModel summary,
  ) {
    final total = summary.totalAlerts.toString();
    final critical = summary.criticalAlerts.toString();
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total alerts',
            value: total,
            subtitle: '${summary.uniqueCameras} cameras in period',
            icon: Icons.analytics,
            iconColor: AppTheme.accentCyan,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: StatCard(
            title: 'Critical / high',
            value: critical,
            subtitle: 'Needs attention',
            icon: Icons.notifications_active,
            iconColor: AppTheme.statusWarning,
          ),
        ),
      ],
    );
  }

  Widget _buildDetectionChart(
    BuildContext context,
    bool isSmallScreen,
    ReportSummaryModel summary,
  ) {
    final spots = _spotsFromSummary(summary);
    final pts = summary.timeDistribution;
    final maxY = _maxY(spots);
    final maxX = spots.length > 1 ? spots.length - 1.0 : 1.0;

    return GlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detection trends',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: isSmallScreen ? 18 : 20,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isSmallScreen ? 180 : 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= pts.length) return const Text('');
                        final label =
                            _shortLabel(pts[i].label, i, pts.length);
                        if (label.isEmpty) return const Text('');
                        return Text(
                          label,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                            fontFamily: 'Arimo',
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Arimo',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: maxX,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.accentCyan,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentCyan.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(
    BuildContext context,
    bool isSmallScreen,
    ReportSummaryModel summary,
    ReportTimelineModel? timeline,
  ) {
    final useTimeline =
        timeline != null && timeline.points.isNotEmpty;
    final spots =
        useTimeline ? _spotsFromTimeline(timeline) : _spotsFromSummary(summary);
    final pts = useTimeline ? null : summary.timeDistribution;
    final timelinePts =
        (timeline != null && timeline.points.isNotEmpty)
            ? timeline.points
            : null;
    final maxY = _maxY(spots);
    final maxX = spots.length > 1 ? spots.length - 1.0 : 1.0;

    return GlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            useTimeline ? 'Activity timeline' : 'Distribution',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: isSmallScreen ? 18 : 20,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isSmallScreen ? 180 : 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (useTimeline && timelinePts != null) {
                          if (i < 0 || i >= timelinePts.length) {
                            return const Text('');
                          }
                          final raw = timelinePts[i].timeLabel;
                          final label = raw.length > 12
                              ? '${raw.substring(0, 11)}…'
                              : raw;
                          return Text(
                            label,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontFamily: 'Arimo',
                            ),
                          );
                        }
                        if (pts != null && i >= 0 && i < pts.length) {
                          final label =
                              _shortLabel(pts[i].label, i, pts.length);
                          if (label.isEmpty) return const Text('');
                          return Text(
                            label,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontFamily: 'Arimo',
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Arimo',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: maxX,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.accentGold,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAlertTypeLabel(String key) {
    if (key.isEmpty) return key;
    return key
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Widget _buildTopDetections(
    BuildContext context,
    bool isSmallScreen,
    ReportSummaryModel summary,
  ) {
    final entries = summary.alertsByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();
    if (top.isEmpty) {
      return GlassContainer(
        borderRadius: 16,
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Text(
          'No alert types in this period',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: isSmallScreen ? 14 : 15,
            fontFamily: 'Arimo',
          ),
        ),
      );
    }

    final colors = [
      AppTheme.accentCyan,
      AppTheme.accentGold,
      AppTheme.statusOnline,
      AppTheme.statusWarning,
      AppTheme.textSecondary,
      AppTheme.accentCyanDark,
    ];
    final maxCount = top.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return GlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alerts by type',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: isSmallScreen ? 18 : 20,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          ...top.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final color = colors[i % colors.length];
            final percentage = maxCount > 0 ? e.value / maxCount : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _formatAlertTypeLabel(e.key),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        '${e.value}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
