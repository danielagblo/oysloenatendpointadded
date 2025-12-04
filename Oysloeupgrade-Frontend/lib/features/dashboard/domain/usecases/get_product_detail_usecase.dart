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

class ReportProductParams extends Equatable {
  const ReportProductParams({
    required this.productId,
    required this.reason,
  });

  final int productId;
  final String reason;

  @override
  List<Object> get props => <Object>[productId, reason];
}

class ReportProductUseCase
    extends UseCase<void, ReportProductParams> {
  ReportProductUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, void>> call(ReportProductParams params) {
    return _repository.reportProduct(
      productId: params.productId,
      reason: params.reason,
    );
  }
}

class GetProductDetailParams extends Equatable {
  const GetProductDetailParams({required this.id});

  final int id;

  @override
  List<Object> get props => <Object>[id];
}
