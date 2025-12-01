import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class MarkProductAsTakenParams extends Equatable {
  const MarkProductAsTakenParams({required this.productId});

  final int productId;

  @override
  List<Object?> get props => <Object?>[productId];
}

class MarkProductAsTakenUseCase
    extends UseCase<ProductEntity, MarkProductAsTakenParams> {
  MarkProductAsTakenUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ProductEntity>> call(
    MarkProductAsTakenParams params,
  ) {
    return _repository.markProductAsTaken(productId: params.productId);
  }
}


