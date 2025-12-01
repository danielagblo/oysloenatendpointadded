import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetProductDetailUseCase
    extends UseCase<ProductEntity, GetProductDetailParams> {
  GetProductDetailUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ProductEntity>> call(
    GetProductDetailParams params,
  ) {
    return _repository.getProductDetail(id: params.id);
  }
}

class GetProductDetailParams extends Equatable {
  const GetProductDetailParams({required this.id});

  final int id;

  @override
  List<Object> get props => <Object>[id];
}
