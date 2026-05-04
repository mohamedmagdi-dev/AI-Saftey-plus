import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/report_summary_model.dart';
import '../../domain/models/report_timeline_model.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../../../core/network/api_exception.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({required ReportsRepository repository})
      : _repository = repository,
        super(ReportsInitial());

  final ReportsRepository _repository;

  Future<void> loadSummary({required String period}) async {
    emit(ReportsLoading());
    try {
      final summary = await _repository.getSummary(period: period);
      emit(ReportsLoaded(summary: summary));
    } catch (e) {
      emit(ReportsError(message: errorMessage(mapToException(e))));
    }
  }

  /// Loads summary plus timeline for charts (analytics). Timeline interval matches API rules.
  Future<void> loadAnalytics({required String period}) async {
    emit(ReportsLoading());
    try {
      final summary = await _repository.getSummary(period: period);
      ReportTimelineModel? timeline;
      try {
        if (period == 'today') {
          timeline =
              await _repository.getTimeline(period: 'today', interval: 'hour');
        } else if (period == 'week' || period == 'month') {
          timeline =
              await _repository.getTimeline(period: period, interval: 'day');
        } else if (period == 'all') {
          timeline =
              await _repository.getTimeline(period: 'month', interval: 'day');
        }
      } catch (_) {
        timeline = null;
      }
      emit(ReportsLoaded(summary: summary, timeline: timeline));
    } catch (e) {
      emit(ReportsError(message: errorMessage(mapToException(e))));
    }
  }
}
