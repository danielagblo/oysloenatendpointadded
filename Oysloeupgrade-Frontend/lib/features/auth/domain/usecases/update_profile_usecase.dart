import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/update_profile_params.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase
    implements UseCase<AuthUserEntity, UpdateProfileParams> {
  const UpdateProfileUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUserEntity>> call(
    UpdateProfileParams params,
  ) {
    return _repository.updateProfile(params);
  }
}
