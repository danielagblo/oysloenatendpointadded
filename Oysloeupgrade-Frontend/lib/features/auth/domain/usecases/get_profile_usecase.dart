import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class GetProfileUseCase implements UseCase<AuthUserEntity, NoParams> {
  const GetProfileUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUserEntity>> call(NoParams params) {
    return _repository.getProfile();
  }
}
