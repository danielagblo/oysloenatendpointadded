import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class SetProductStatusParams extends Equatable {
  const SetProductStatusParams({
    required this.productId,
    required this.status,
  });

  final int productId;
  final String status;

  @override
  List<Object?> get props => <Object?>[productId, status];
}

class SetProductStatusUseCase
    extends UseCase<ProductEntity, SetProductStatusParams> {
  SetProductStatusUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ProductEntity>> call(
    SetProductStatusParams params,
  ) {
    return _repository.setProductStatus(
      productId: params.productId,
      status: params.status,
    );
  }
}


