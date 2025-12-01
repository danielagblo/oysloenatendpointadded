import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetProductReviewsUseCase
    extends UseCase<List<ReviewEntity>, GetProductReviewsParams> {
  GetProductReviewsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<ReviewEntity>>> call(
    GetProductReviewsParams params,
  ) {
    return _repository.getProductReviews(productId: params.productId);
  }
}

class GetProductReviewsParams extends Equatable {
  const GetProductReviewsParams({required this.productId});

  final int productId;

  @override
  List<Object> get props => <Object>[productId];
}
