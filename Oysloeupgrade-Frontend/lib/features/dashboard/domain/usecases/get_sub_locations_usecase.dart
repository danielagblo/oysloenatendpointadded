import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/location_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetSubLocationsUseCase
    extends UseCase<List<LocationEntity>, GetSubLocationsParams> {
  GetSubLocationsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<LocationEntity>>> call(
      GetSubLocationsParams params) async {
    return _repository.getSubLocations(params.regionId);
  }
}

class GetSubLocationsParams {
  const GetSubLocationsParams({required this.regionId});

  final int regionId;
}
