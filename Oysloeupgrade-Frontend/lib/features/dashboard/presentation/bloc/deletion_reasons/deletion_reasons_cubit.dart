import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/get_deletion_reasons_usecase.dart';
import 'deletion_reasons_state.dart';

class DeletionReasonsCubit extends Cubit<DeletionReasonsState> {
  DeletionReasonsCubit(this._getDeletionReasons)
      : super(const DeletionReasonsState());

  final GetDeletionReasonsUseCase _getDeletionReasons;

  Future<void> fetch() async {
    if (state.isLoading) return;
    if (state.hasData) {
      return; // Already loaded
    }

    emit(
      state.copyWith(
        status: DeletionReasonsStatus.loading,
        resetMessage: true,
      ),
    );

    final result = await _getDeletionReasons(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DeletionReasonsStatus.failure,
          reasons: const <String>[],
          message: failure.message,
        ),
      ),
      (reasons) => emit(
        state.copyWith(
          status: DeletionReasonsStatus.success,
          reasons: reasons,
          resetMessage: true,
        ),
      ),
    );
  }

  void clear() {
    emit(const DeletionReasonsState());
  }
}

