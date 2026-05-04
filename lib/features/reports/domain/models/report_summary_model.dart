class ReportSummaryModel {
  ReportSummaryModel({
    required this.period,
    required this.totalAlerts,
    required this.criticalAlerts,
    required this.uniqueCameras,
    required this.alertsByType,
    required this.timeDistribution,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    final byType = json['alerts_by_type'];
    final distribution = json['time_distribution'];
    return ReportSummaryModel(
      period: json['period'] as String? ?? 'week',
      totalAlerts: (json['total_alerts'] as num?)?.toInt() ?? 0,
      criticalAlerts: (json['critical_alerts'] as num?)?.toInt() ?? 0,
      uniqueCameras: (json['unique_cameras'] as num?)?.toInt() ?? 0,
      alertsByType: byType is Map<String, dynamic>
          ? byType.map((k, v) => MapEntry(k, (v as num).toInt()))
          : <String, int>{},
      timeDistribution: distribution is List
          ? distribution
              .whereType<Map<String, dynamic>>()
              .map(TimeDistributionPoint.fromJson)
              .toList()
          : <TimeDistributionPoint>[],
    );
  }

  final String period;
  final int totalAlerts;
  final int criticalAlerts;
  final int uniqueCameras;
  final Map<String, int> alertsByType;
  final List<TimeDistributionPoint> timeDistribution;
}

class TimeDistributionPoint {
  TimeDistributionPoint({required this.label, required this.count});

  factory TimeDistributionPoint.fromJson(Map<String, dynamic> json) {
    final label = json['date'] as String? ??
        json['time'] as String? ??
        json['day'] as String? ??
        '';
    return TimeDistributionPoint(
      label: label,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  /// API may send calendar dates or hour labels (e.g. `0:00`, `2026-04-25`).
  final String label;
  final int count;
}
