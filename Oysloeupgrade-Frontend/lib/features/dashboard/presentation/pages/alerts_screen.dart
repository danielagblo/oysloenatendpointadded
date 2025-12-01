import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:oysloe_mobile/core/common/widgets/adaptive_progress_indicator.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/utils/alert_time_utils.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/alert_entity.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/alerts/alerts_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/alerts/alerts_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/alert_tile.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AlertsCubit>()..fetchAlerts(),
      child: const _AlertsView(),
    );
  }
}

class _AlertsView extends StatelessWidget {
  const _AlertsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: CustomAppBar(
        title: 'Alerts',
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF817F7F),
                size: 24,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (sheetContext) {
                    final cubit =
                        context.read<AlertsCubit>(); // use parent context
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.mark_email_read_outlined,
                                color: Color(0xFF374957)),
                            title: const Text('Mark all as read'),
                            onTap: () {
                              cubit.markAllAlertsRead();
                              Navigator.of(sheetContext).pop();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.clear_all,
                                color: Color(0xFF374957)),
                            title: const Text('Clear'),
                            onTap: () {
                              final currentAlerts =
                                  List<AlertEntity>.from(cubit.state.alerts);
                              for (final alert in currentAlerts) {
                                cubit.deleteAlert(alert);
                              }
                              Navigator.of(sheetContext).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: BlocListener<AlertsCubit, AlertsState>(
        listenWhen: (previous, current) =>
            current.message != null && previous.message != current.message,
        listener: (context, state) {
          if (state.status != AlertsStatus.failure && state.message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
          }
        },
        child: BlocBuilder<AlertsCubit, AlertsState>(
          builder: (context, state) {
            if (state.isLoading && !state.hasData) {
              return const Center(child: AdaptiveProgressIndicator());
            }

            if (state.hasData) {
              return _buildAlertsContent(context, state);
            }

            if (state.hasError) {
              return _buildMessage(
                state.message ?? 'Unable to load alerts',
              );
            }

            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/big_bell.png',
            width: 120,
            height: 120,
          ),
          SizedBox(height: 24),
          Text(
            'No notifications to show',
            style: AppTypography.body.copyWith(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blueGray374957,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You currently do not have any notification yet.\nwe\'re going to notify you when \nsomething new happens',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontSize: 14.sp,
                color: AppColors.blueGray374957.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.body.copyWith(
          color: AppColors.blueGray374957,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildAlertsContent(BuildContext context, AlertsState state) {
    final AlertsCubit cubit = context.read<AlertsCubit>();
    final DateTime now = DateTime.now();
    final List<_AlertSection> sections = _groupAlerts(state.alerts, now);

    final List<Widget> groups = <Widget>[];
    for (int index = 0; index < sections.length; index++) {
      final _AlertSection section = sections[index];
      groups.add(
        _AlertGroup(
          title: section.title,
          alerts: section.alerts,
          expandedAlertIds: state.expandedAlertIds,
          onToggle: cubit.toggleAlert,
          onDelete: cubit.deleteAlert,
          onMarkRead: cubit.markAlertRead,
        ),
      );
      if (index != sections.length - 1) {
        groups.add(SizedBox(height: 2.5.h));
      }
    }

    return RefreshIndicator(
      color: AppColors.blueGray374957,
      onRefresh: () => cubit.fetchAlerts(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SlidableAutoCloseBehavior(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: groups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertGroup extends StatelessWidget {
  const _AlertGroup({
    required this.title,
    required this.alerts,
    required this.expandedAlertIds,
    required this.onToggle,
    required this.onDelete,
    required this.onMarkRead,
  });

  final String title;
  final List<AlertEntity> alerts;
  final Set<int> expandedAlertIds;
  final void Function(AlertEntity alert) onToggle;
  final void Function(AlertEntity alert) onDelete;
  final void Function(AlertEntity alert) onMarkRead;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 16),
          child: Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF646161),
            ),
          ),
        ),
        ...alerts.map(
          (AlertEntity alert) => AlertTile(
            alert: alert,
            timeLabel: AlertTimeUtils.formatAlertTimeLabel(alert.createdAt),
            isExpanded: expandedAlertIds.contains(alert.id),
            onTap: () {
              onToggle(alert);
              if (!alert.isRead) {
                onMarkRead(alert);
              }
            },
            onDelete: () => onDelete(alert),
            onMarkRead: () => onMarkRead(alert),
          ),
        ),
      ],
    );
  }
}

class _AlertSection {
  const _AlertSection({
    required this.title,
    required this.alerts,
  });

  final String title;
  final List<AlertEntity> alerts;
}

List<_AlertSection> _groupAlerts(List<AlertEntity> alerts, DateTime now) {
  final Map<DateTime, List<AlertEntity>> grouped =
      <DateTime, List<AlertEntity>>{};

  for (final AlertEntity alert in alerts) {
    final DateTime local = alert.createdAt.toLocal();
    final DateTime dayKey = DateTime(local.year, local.month, local.day);
    grouped.putIfAbsent(dayKey, () => <AlertEntity>[]).add(alert);
  }

  final List<DateTime> keys = grouped.keys.toList()
    ..sort((DateTime a, DateTime b) => b.compareTo(a));

  return keys
      .map(
        (DateTime date) => _AlertSection(
          title: AlertTimeUtils.describeAlertDay(date, now),
          alerts: List<AlertEntity>.from(grouped[date]!)
            ..sort(
              (AlertEntity a, AlertEntity b) =>
                  b.createdAt.compareTo(a.createdAt),
            ),
        ),
      )
      .toList();
}

extension AlertsCubitExtensions on AlertsCubit {
  void markAllAlertsRead() {
    final currentAlerts = List<AlertEntity>.from(state.alerts);
    for (final alert in currentAlerts) {
      markAlertRead(alert);
    }
  }
}
