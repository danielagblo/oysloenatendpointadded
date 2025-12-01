import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/otp_params.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/otp_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyResetOtpUseCase
    implements UseCase<OtpResponseEntity, VerifyOtpParams> {
  VerifyResetOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, OtpResponseEntity>> call(VerifyOtpParams params) {
    return _repository.verifyResetOtp(params);
  }
}
