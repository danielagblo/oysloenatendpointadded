import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetProductsParams extends Equatable {
  const GetProductsParams({
    this.search,
    this.ordering,
    this.sellerId,
    this.category,
    this.location,
    this.region,
    this.priceMin,
    this.priceMax,
  });

  final String? search;
  final String? ordering;
  final int? sellerId;
  final int? category;
  final int? location;
  final String? region;
  final double? priceMin;
  final double? priceMax;

  @override
  List<Object?> get props => <Object?>[
        search,
        ordering,
        sellerId,
        category,
        location,
        region,
        priceMin,
        priceMax,
      ];
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
      sellerId: params.sellerId,
      category: params.category,
      location: params.location,
      region: params.region,
      priceMin: params.priceMin,
      priceMax: params.priceMax,
    );
  }
}
