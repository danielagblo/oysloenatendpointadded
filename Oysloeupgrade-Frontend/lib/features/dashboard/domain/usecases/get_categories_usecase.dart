import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/category_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, List<CategoryEntity>>> call({
    bool forceRefresh = false,
  }) {
    return _repository.getCategories(forceRefresh: forceRefresh);
  }
}
