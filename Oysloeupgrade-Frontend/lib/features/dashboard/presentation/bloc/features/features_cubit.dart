import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/feature_entity.dart';
import '../../../domain/usecases/get_features_usecase.dart';
import 'features_state.dart';

class FeaturesCubit extends Cubit<FeaturesState> {
  FeaturesCubit(this._getFeatures) : super(const FeaturesState());

  final GetFeaturesUseCase _getFeatures;

  Future<void> fetch({int? subcategoryId}) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: FeaturesStatus.loading,
        resetMessage: true,
      ),
    );

    final result = await _getFeatures(
      GetFeaturesParams(subcategoryId: subcategoryId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FeaturesStatus.failure,
          features: const <FeatureEntity>[],
          message: failure.message,
        ),
      ),
      (features) => emit(
        state.copyWith(
          status: FeaturesStatus.success,
          features: features,
          resetMessage: true,
        ),
      ),
    );
  }

  void clear() {
    emit(const FeaturesState());
  }
}
