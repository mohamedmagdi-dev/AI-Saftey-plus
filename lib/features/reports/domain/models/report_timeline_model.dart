class ReportTimelineModel {
  ReportTimelineModel({
    required this.period,
    required this.interval,
    required this.points,
  });

  factory ReportTimelineModel.fromJson(Map<String, dynamic> json) {
    final raw = json['timeline'];
    final list = raw is List<dynamic>
        ? raw.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    return ReportTimelineModel(
      period: json['period'] as String? ?? '',
      interval: json['interval'] as String? ?? 'day',
      points: list.map(TimelinePoint.fromJson).toList(),
    );
  }

  final String period;
  final String interval;
  final List<TimelinePoint> points;
}

class TimelinePoint {
  TimelinePoint({
    required this.timeLabel,
    required this.total,
  });

  factory TimelinePoint.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    var total = 0;
    if (data is Map<String, dynamic>) {
      final t = data['total'];
      if (t is num) total = t.toInt();
    }
    return TimelinePoint(
      timeLabel: json['time'] as String? ?? '',
      total: total,
    );
  }

  final String timeLabel;
  final int total;
}
