import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/subcategory_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetSubcategoriesParams {
  const GetSubcategoriesParams({this.categoryId});

  final int? categoryId;
}

class GetSubcategoriesUseCase {
  const GetSubcategoriesUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, List<SubcategoryEntity>>> call(
    GetSubcategoriesParams params,
  ) {
    return _repository.getSubcategories(categoryId: params.categoryId);
  }
}
