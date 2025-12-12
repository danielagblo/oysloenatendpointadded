import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class RepostProductUseCase extends UseCase<ProductEntity, RepostProductParams> {
  RepostProductUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ProductEntity>> call(RepostProductParams params) {
    return _repository.repostProduct(productId: params.productId);
  }
}

class RepostProductParams extends Equatable {
  const RepostProductParams({required this.productId});

  final int productId;

  @override
  List<Object> get props => <Object>[productId];
}

