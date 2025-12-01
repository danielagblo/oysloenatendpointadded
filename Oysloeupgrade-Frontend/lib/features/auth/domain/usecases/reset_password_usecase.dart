import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/reset_password_params.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/reset_password_entity.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase
    implements UseCase<ResetPasswordResponseEntity, ResetPasswordParams> {
  ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, ResetPasswordResponseEntity>> call(
    ResetPasswordParams params,
  ) {
    return _repository.resetPassword(params);
  }
}
