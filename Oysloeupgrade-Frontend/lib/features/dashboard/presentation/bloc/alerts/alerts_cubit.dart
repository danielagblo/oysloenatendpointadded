import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/alert_entity.dart';
import '../../../domain/usecases/get_alerts_usecase.dart';
import '../../../domain/usecases/mark_alert_read_usecase.dart';
import '../../../domain/usecases/delete_alert_usecase.dart';
import 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit(this._getAlerts, this._markAlertRead, this._deleteAlert)
      : super(const AlertsState());

  final GetAlertsUseCase _getAlerts;
  final MarkAlertReadUseCase _markAlertRead;
  final DeleteAlertUseCase _deleteAlert;

  Future<void> fetchAlerts() async {
    emit(
      state.copyWith(
        status: AlertsStatus.loading,
        resetMessage: true,
      ),
    );

    final result = await _getAlerts(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AlertsStatus.failure,
          alerts: const <AlertEntity>[],
          message: failure.message,
        ),
      ),
      (alerts) => emit(
        state.copyWith(
          status: AlertsStatus.success,
          alerts: alerts,
          expandedAlertIds: <int>{},
          markingAlertIds: <int>{},
          deletingAlertIds: <int>{},
          resetMessage: true,
        ),
      ),
    );
  }

  void toggleAlert(AlertEntity alert) {
    final bool isExpanded = state.expandedAlertIds.contains(alert.id);
    final Set<int> expanded = Set<int>.from(state.expandedAlertIds);
    if (isExpanded) {
      expanded.remove(alert.id);
    } else {
      expanded.add(alert.id);
    }
    emit(state.copyWith(expandedAlertIds: expanded));
  }

  Future<void> markAlertRead(AlertEntity alert) async {
    if (alert.isRead) return;
    await _markAlert(alert);
  }

  Future<void> _markAlert(AlertEntity alert) async {
    if (state.markingAlertIds.contains(alert.id)) {
      return;
    }

    final Set<int> marking = Set<int>.from(state.markingAlertIds)
      ..add(alert.id);
    emit(state.copyWith(markingAlertIds: marking));

    final result = await _markAlertRead(MarkAlertReadParams(alert: alert));

    result.fold(
      (failure) {
        final Set<int> updatedMarking = Set<int>.from(state.markingAlertIds)
          ..remove(alert.id);
        emit(
          state.copyWith(
            markingAlertIds: updatedMarking,
            message: failure.message,
          ),
        );
      },
      (_) {
        final List<AlertEntity> updatedAlerts = state.alerts
            .map(
              (AlertEntity item) =>
                  item.id == alert.id ? item.copyWith(isRead: true) : item,
            )
            .toList();
        final Set<int> updatedMarking = Set<int>.from(state.markingAlertIds)
          ..remove(alert.id);
        emit(
          state.copyWith(
            alerts: updatedAlerts,
            markingAlertIds: updatedMarking,
            resetMessage: true,
          ),
        );
      },
    );
  }

  Future<void> deleteAlert(AlertEntity alert) async {
    if (state.deletingAlertIds.contains(alert.id)) {
      return;
    }

    final Set<int> deleting = Set<int>.from(state.deletingAlertIds)
      ..add(alert.id);
    emit(state.copyWith(deletingAlertIds: deleting));

    final result = await _deleteAlert(DeleteAlertParams(alertId: alert.id));

    result.fold(
      (failure) {
        final Set<int> updatedDeleting = Set<int>.from(state.deletingAlertIds)
          ..remove(alert.id);
        emit(
          state.copyWith(
            deletingAlertIds: updatedDeleting,
            message: failure.message,
          ),
        );
      },
      (_) {
        final List<AlertEntity> updatedAlerts = state.alerts
            .where((AlertEntity item) => item.id != alert.id)
            .toList();
        final Set<int> updatedExpanded = Set<int>.from(state.expandedAlertIds)
          ..remove(alert.id);
        final Set<int> updatedMarking = Set<int>.from(state.markingAlertIds)
          ..remove(alert.id);
        final Set<int> updatedDeleting = Set<int>.from(state.deletingAlertIds)
          ..remove(alert.id);
        emit(
          state.copyWith(
            alerts: updatedAlerts,
            expandedAlertIds: updatedExpanded,
            markingAlertIds: updatedMarking,
            deletingAlertIds: updatedDeleting,
            resetMessage: true,
          ),
        );
      },
    );
  }
}
