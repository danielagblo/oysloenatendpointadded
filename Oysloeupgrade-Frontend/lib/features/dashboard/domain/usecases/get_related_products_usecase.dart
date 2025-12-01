import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetRelatedProductsParams extends Equatable {
  const GetRelatedProductsParams({required this.productId});

  final int productId;

  @override
  List<Object?> get props => <Object?>[productId];
}

class GetRelatedProductsUseCase
    extends UseCase<List<ProductEntity>, GetRelatedProductsParams> {
  GetRelatedProductsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
    GetRelatedProductsParams params,
  ) {
    return _repository.getRelatedProducts(productId: params.productId);
  }
}


