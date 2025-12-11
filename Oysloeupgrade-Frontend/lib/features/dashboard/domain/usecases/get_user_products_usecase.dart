import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetUserProductsUseCase extends UseCase<List<ProductEntity>, NoParams> {
  GetUserProductsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) {
    return _repository.getUserProducts();
  }
}

