import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetProductsParams extends Equatable {
  const GetProductsParams({
    this.search,
    this.ordering,
  });

  final String? search;
  final String? ordering;

  @override
  List<Object?> get props => <Object?>[search, ordering];
}

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, List<ProductEntity>>> call(
    GetProductsParams params,
  ) {
    return _repository.getProducts(
      search: params.search,
      ordering: params.ordering,
    );
  }
}
