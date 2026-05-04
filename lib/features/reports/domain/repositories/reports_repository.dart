import '../models/report_summary_model.dart';
import '../models/report_timeline_model.dart';

abstract class ReportsRepository {
  /// period: `today` | `week` | `month` | `all`
  Future<ReportSummaryModel> getSummary({required String period});

  Future<ReportTimelineModel> getTimeline({
    required String period,
    required String interval,
  });
}
