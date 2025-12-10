import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class ToggleFavouriteParams extends Equatable {
  const ToggleFavouriteParams({required this.productId});

  final int productId;

  @override
  List<Object> get props => <Object>[productId];
}

class ToggleFavouriteUseCase
    extends UseCase<ProductEntity, ToggleFavouriteParams> {
  ToggleFavouriteUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ProductEntity>> call(ToggleFavouriteParams params) {
    return _repository.toggleFavourite(productId: params.productId);
  }
}

class GetFavouritesUseCase extends UseCase<List<ProductEntity>, NoParams> {
  GetFavouritesUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) {
    return _repository.getFavourites();
  }
}


