part of 'reports_cubit.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  const ReportsLoaded({required this.summary, this.timeline});

  final ReportSummaryModel summary;
  final ReportTimelineModel? timeline;

  @override
  List<Object?> get props => [summary, timeline];
}

class ReportsError extends ReportsState {
  const ReportsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
