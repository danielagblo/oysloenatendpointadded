import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/otp_params.dart';
import '../../../../../core/usecase/reset_password_params.dart';
import '../../../domain/usecases/reset_password_usecase.dart';
import '../../../domain/usecases/send_otp_usecase.dart';
import '../../../domain/usecases/verify_reset_otp_usecase.dart';
import 'password_reset_state.dart';

class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit(
    this._sendOtpUseCase,
    this._verifyResetOtpUseCase,
    this._resetPasswordUseCase,
  ) : super(const PasswordResetInitial());

  final SendOtpUseCase _sendOtpUseCase;
  final VerifyResetOtpUseCase _verifyResetOtpUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  Future<void> sendOtp(String phone) async {
    if (state is PasswordResetSendingOtp) return;
    emit(const PasswordResetSendingOtp());
    final result = await _sendOtpUseCase(SendOtpParams(phone: phone));
    result.fold(
      (failure) => emit(PasswordResetError(failure.message)),
      (response) => emit(PasswordResetOtpSent(response)),
    );
  }

  Future<void> verifyOtp(String phone, String otp) async {
    if (state is PasswordResetVerifyingOtp) return;
    emit(const PasswordResetVerifyingOtp());
    final result =
        await _verifyResetOtpUseCase(VerifyOtpParams(phone: phone, otp: otp));
    result.fold(
      (failure) => emit(PasswordResetError(failure.message)),
      (response) => emit(PasswordResetOtpVerified(response)),
    );
  }

  Future<void> resetPassword(ResetPasswordParams params) async {
    if (state is PasswordResetSubmitting) return;
    emit(const PasswordResetSubmitting());
    final result = await _resetPasswordUseCase(params);
    result.fold(
      (failure) => emit(PasswordResetError(failure.message)),
      (response) => emit(PasswordResetSuccess(response)),
    );
  }

  void resetState() => emit(const PasswordResetInitial());
}
