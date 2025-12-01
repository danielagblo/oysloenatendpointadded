import '../../../domain/entities/account_delete_request_entity.dart';

enum AccountDeleteStatus {
  initial,
  loading,
  success,
  failure,
}

class AccountDeleteState {
  const AccountDeleteState({
    this.status = AccountDeleteStatus.initial,
    this.requests = const <AccountDeleteRequestEntity>[],
    this.isSubmitting = false,
    this.message,
  });

  final AccountDeleteStatus status;
  final List<AccountDeleteRequestEntity> requests;
  final bool isSubmitting;
  final String? message;

  bool get hasData => requests.isNotEmpty;

  bool get hasPendingRequest {
    return requests.any(
      (AccountDeleteRequestEntity r) =>
          r.status.toLowerCase().contains('pending'),
    );
  }

  AccountDeleteState copyWith({
    AccountDeleteStatus? status,
    List<AccountDeleteRequestEntity>? requests,
    bool? isSubmitting,
    String? message,
    bool resetMessage = false,
  }) {
    return AccountDeleteState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: resetMessage ? null : message ?? this.message,
    );
  }
}


