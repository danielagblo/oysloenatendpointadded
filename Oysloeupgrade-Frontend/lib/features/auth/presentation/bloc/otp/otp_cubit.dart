import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/otp_params.dart';
import '../../../domain/usecases/send_otp_usecase.dart';
import '../../../domain/usecases/verify_otp_usecase.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit(this._sendOtpUseCase, this._verifyOtpUseCase)
      : super(const OtpInitial());

  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;

  Future<void> sendOtp(String phone) async {
    if (state is OtpSending) return;
    
    emit(const OtpSending());
    final result = await _sendOtpUseCase(SendOtpParams(phone: phone));
    result.fold(
      (failure) => emit(OtpError(failure.message)),
      (response) => emit(OtpSent(response)),
    );
  }

  Future<void> verifyOtp(String phone, String otp) async {
    if (state is OtpVerifying) return;
    
    emit(const OtpVerifying());
    final result = await _verifyOtpUseCase(VerifyOtpParams(phone: phone, otp: otp));
    result.fold(
      (failure) => emit(OtpError(failure.message)),
      (session) => emit(OtpVerified(session)),
    );
  }

  void reset() => emit(const OtpInitial());
}