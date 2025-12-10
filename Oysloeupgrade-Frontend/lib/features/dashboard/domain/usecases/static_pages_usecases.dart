import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/static_page_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetPrivacyPolicyUseCase
    extends UseCase<StaticPageEntity, NoParams> {
  GetPrivacyPolicyUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, StaticPageEntity>> call(NoParams params) {
    return _repository.getPrivacyPolicy();
  }
}

class GetTermsConditionsUseCase
    extends UseCase<StaticPageEntity, NoParams> {
  GetTermsConditionsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, StaticPageEntity>> call(NoParams params) {
    return _repository.getTermsConditions();
  }
}

