import 'package:equatable/equatable.dart';

enum DeletionReasonsStatus {
  initial,
  loading,
  success,
  failure,
}

class DeletionReasonsState extends Equatable {
  const DeletionReasonsState({
    this.status = DeletionReasonsStatus.initial,
    this.reasons = const <String>[],
    this.message,
    this.resetMessage = false,
  });

  final DeletionReasonsStatus status;
  final List<String> reasons;
  final String? message;
  final bool resetMessage;

  bool get isLoading => status == DeletionReasonsStatus.loading;
  bool get hasData => status == DeletionReasonsStatus.success && reasons.isNotEmpty;
  bool get hasError => status == DeletionReasonsStatus.failure;

  DeletionReasonsState copyWith({
    DeletionReasonsStatus? status,
    List<String>? reasons,
    String? message,
    bool? resetMessage,
  }) {
    return DeletionReasonsState(
      status: status ?? this.status,
      reasons: reasons ?? this.reasons,
      message: resetMessage == true ? null : (message ?? this.message),
      resetMessage: resetMessage ?? false,
    );
  }

  @override
  List<Object?> get props => [status, reasons, message, resetMessage];
}

