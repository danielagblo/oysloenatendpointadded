import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/dashboard_repository.dart';

class CreateReviewUseCase
    extends UseCase<ReviewEntity, CreateReviewParams> {
  CreateReviewUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ReviewEntity>> call(CreateReviewParams params) {
    return _repository.createReview(
      productId: params.productId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}

class CreateReviewParams extends Equatable {
  const CreateReviewParams({
    required this.productId,
    required this.rating,
    this.comment,
  });

  final int productId;
  final int rating;
  final String? comment;

  @override
  List<Object?> get props => <Object?>[productId, rating, comment];
}
