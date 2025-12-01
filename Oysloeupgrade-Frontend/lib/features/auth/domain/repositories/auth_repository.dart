import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/login_params.dart';
import '../../../../core/usecase/otp_params.dart';
import '../../../../core/usecase/reset_password_params.dart';
import '../../../../core/usecase/register_params.dart';
import '../../../../core/usecase/update_profile_params.dart';
import '../entities/auth_entity.dart';
import '../entities/otp_entity.dart';
import '../entities/reset_password_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSessionEntity>> register(RegisterParams params);
  Future<Either<Failure, AuthSessionEntity>> login(LoginParams params);
  Future<Either<Failure, void>> logout();
  Future<AuthSessionEntity?> cachedSession();
  AuthSessionEntity? get currentSession;
  Future<Either<Failure, OtpResponseEntity>> sendOtp(SendOtpParams params);
  Future<Either<Failure, AuthSessionEntity>> verifyOtp(VerifyOtpParams params);
  Future<Either<Failure, OtpResponseEntity>> verifyResetOtp(
      VerifyOtpParams params);
  Future<Either<Failure, ResetPasswordResponseEntity>> resetPassword(
      ResetPasswordParams params);
  Future<Either<Failure, AuthUserEntity>> getProfile();
  Future<Either<Failure, AuthUserEntity>> updateProfile(
      UpdateProfileParams params);
}
