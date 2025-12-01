import 'package:equatable/equatable.dart';

import '../../../domain/entities/alert_entity.dart';

enum AlertsStatus { initial, loading, success, failure }

class AlertsState extends Equatable {
  const AlertsState({
    this.status = AlertsStatus.initial,
    this.alerts = const <AlertEntity>[],
    this.message,
    this.expandedAlertIds = const <int>{},
    this.markingAlertIds = const <int>{},
    this.deletingAlertIds = const <int>{},
  });

  final AlertsStatus status;
  final List<AlertEntity> alerts;
  final String? message;
  final Set<int> expandedAlertIds;
  final Set<int> markingAlertIds;
  final Set<int> deletingAlertIds;

  bool get isLoading => status == AlertsStatus.loading;
  bool get hasError => status == AlertsStatus.failure;
  bool get hasData => alerts.isNotEmpty;

  AlertsState copyWith({
    AlertsStatus? status,
    List<AlertEntity>? alerts,
    String? message,
    Set<int>? expandedAlertIds,
    Set<int>? markingAlertIds,
    Set<int>? deletingAlertIds,
    bool resetMessage = false,
  }) {
    return AlertsState(
      status: status ?? this.status,
      alerts: alerts ?? this.alerts,
      message: resetMessage ? null : message ?? this.message,
      expandedAlertIds: expandedAlertIds ?? this.expandedAlertIds,
      markingAlertIds: markingAlertIds ?? this.markingAlertIds,
      deletingAlertIds: deletingAlertIds ?? this.deletingAlertIds,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        alerts,
        message,
        (List<int>.from(expandedAlertIds)..sort()),
        (List<int>.from(markingAlertIds)..sort()),
        (List<int>.from(deletingAlertIds)..sort()),
      ];
}
