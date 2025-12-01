import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/otp_params.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/otp_entity.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase implements UseCase<OtpResponseEntity, SendOtpParams> {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  @override
  Future<Either<Failure, OtpResponseEntity>> call(SendOtpParams params) {
    return repository.sendOtp(params);
  }
}