import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/dashboard_repository.dart';

class UpdateReviewUseCase
    extends UseCase<ReviewEntity, UpdateReviewParams> {
  UpdateReviewUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ReviewEntity>> call(
    UpdateReviewParams params,
  ) {
    return _repository.updateReview(
      reviewId: params.reviewId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}

class UpdateReviewParams extends Equatable {
  const UpdateReviewParams({
    required this.reviewId,
    required this.rating,
    this.comment,
  });

  final int reviewId;
  final int rating;
  final String? comment;

  @override
  List<Object?> get props => <Object?>[reviewId, rating, comment];
}
