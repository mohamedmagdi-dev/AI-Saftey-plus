import 'dart:async';
import '../../features/alerts/domain/entities/alert_entity.dart';
import '../../features/alerts/domain/repositories/alert_repository.dart';

class AlertPollingService {
  final AlertRepository repository;
  Timer? _timer;
  final _controller = StreamController<List<AlertEntity>>.broadcast();
  DateTime? _lastAlertTimestamp;
  bool _isPolling = false;

  AlertPollingService(this.repository);

  Stream<List<AlertEntity>> get alertStream => _controller.stream;

  void startPolling({int intervalSeconds = 30}) {
    if (_isPolling) return;
    _isPolling = true;

    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) => _poll());
    // Initial poll
    _poll();
  }

  void stopPolling() {
    _timer?.cancel();
    _isPolling = false;
  }

  Future<void> _poll() async {
    try {
      final alerts = await repository.getAlerts();
      if (alerts.isNotEmpty) {
        final newAlerts = _lastAlertTimestamp == null
            ? alerts
            : alerts.where((a) => a.timestamp.isAfter(_lastAlertTimestamp!)).toList();

        if (newAlerts.isNotEmpty) {
          _lastAlertTimestamp = alerts.map((a) => a.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);
          _controller.add(newAlerts);
        }
      }
    } catch (e) {
      // Log error or add to stream as error
      _controller.addError(e);
    }
  }

  void dispose() {
    stopPolling();
    _controller.close();
  }
}
