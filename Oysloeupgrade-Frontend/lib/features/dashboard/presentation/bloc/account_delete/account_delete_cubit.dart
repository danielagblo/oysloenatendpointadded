import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/account_delete_request_entity.dart';
import '../../../domain/usecases/account_delete_requests_usecases.dart';
import 'account_delete_state.dart';

class AccountDeleteCubit extends Cubit<AccountDeleteState> {
  AccountDeleteCubit(
    this._getRequests,
    this._createRequest,
  ) : super(const AccountDeleteState());

  final GetAccountDeleteRequestsUseCase _getRequests;
  final CreateAccountDeleteRequestUseCase _createRequest;

  Future<void> loadRequests() async {
    emit(
      state.copyWith(
        status: AccountDeleteStatus.loading,
        resetMessage: true,
      ),
    );

    final result = await _getRequests(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AccountDeleteStatus.failure,
          requests: const <AccountDeleteRequestEntity>[],
          message: failure.message,
        ),
      ),
      (items) => emit(
        state.copyWith(
          status: AccountDeleteStatus.success,
          requests: items,
          resetMessage: true,
        ),
      ),
    );
  }

  Future<void> submitDeleteRequest({String? reason}) async {
    if (state.isSubmitting) return;

    emit(
      state.copyWith(
        isSubmitting: true,
        resetMessage: true,
      ),
    );

    final result = await _createRequest(
      CreateAccountDeleteRequestParams(reason: reason),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          message: failure.message,
        ),
      ),
      (created) {
        final List<AccountDeleteRequestEntity> updated =
            <AccountDeleteRequestEntity>[created, ...state.requests];
        emit(
          state.copyWith(
            isSubmitting: false,
            requests: updated,
            message: 'Account delete request submitted successfully',
          ),
        );
      },
    );
  }
}


