import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/dashboard_repository.dart';

class DeleteProductParams extends Equatable {
  const DeleteProductParams({required this.productId});

  final int productId;

  @override
  List<Object?> get props => <Object?>[productId];
}

class DeleteProductUseCase extends UseCase<void, DeleteProductParams> {
  DeleteProductUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteProductParams params) {
    return _repository.deleteProduct(productId: params.productId);
  }
}


