import '../../domain/models/report_summary_model.dart';
import '../../domain/models/report_timeline_model.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/remote_reports_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl({required RemoteReportsDataSource remote})
      : _remote = remote;

  final RemoteReportsDataSource _remote;

  @override
  Future<ReportSummaryModel> getSummary({required String period}) =>
      _remote.getSummary(period: period);

  @override
  Future<ReportTimelineModel> getTimeline({
    required String period,
    required String interval,
  }) =>
      _remote.getTimeline(period: period, interval: interval);
}
