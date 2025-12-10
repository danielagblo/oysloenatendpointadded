import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/feature_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetFeaturesParams {
  const GetFeaturesParams({this.subcategoryId});

  final int? subcategoryId;
}

class GetFeaturesUseCase {
  const GetFeaturesUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, List<FeatureEntity>>> call(
    GetFeaturesParams params,
  ) {
    return _repository.getFeatures(
      subcategoryId: params.subcategoryId,
    );
  }
}
