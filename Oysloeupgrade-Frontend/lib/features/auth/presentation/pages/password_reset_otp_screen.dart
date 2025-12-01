import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/constants/body_paddings.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/password_reset/password_reset_cubit.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/password_reset/password_reset_state.dart';
import 'package:oysloe_mobile/features/auth/presentation/widgets/otp_code_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PasswordResetOtpScreen extends StatefulWidget {
  const PasswordResetOtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<PasswordResetOtpScreen> createState() => _PasswordResetOtpScreenState();
}

class _PasswordResetOtpScreenState extends State<PasswordResetOtpScreen> {
  String _enteredCode = '';

  void _onVerify(PasswordResetCubit cubit) {
    if (_enteredCode.length != 6) {
      showErrorSnackBar(
          context, 'Enter the six digit code sent to your phone.');
      return;
    }
    FocusScope.of(context).unfocus();
    cubit.verifyOtp(widget.phone, _enteredCode);
  }

  @override
  Widget build(BuildContext context) {
    final PasswordResetCubit cubit = context.read<PasswordResetCubit>();

    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listener: (BuildContext context, PasswordResetState state) {
        if (state is PasswordResetError) {
          showErrorSnackBar(context, state.message);
        } else if (state is PasswordResetOtpVerified) {
          final String token = state.response.token;
          showSuccessSnackBar(context, state.response.message);
          if (token.isEmpty) {
            showErrorSnackBar(
              context,
              'Unable to continue. Please request a new OTP.',
            );
            return;
          }
          context.pushNamed(
            AppRouteNames.passwordResetNewPassword,
            extra: <String, String>{
              'phone': widget.phone,
              'token': token,
            },
          );
        } else if (state is PasswordResetOtpSent) {
          showSuccessSnackBar(context, state.response.message);
        }
      },
      builder: (BuildContext context, PasswordResetState state) {
        final bool isVerifying = state is PasswordResetVerifyingOtp;
        final bool isBusy = state is PasswordResetSendingOtp ||
            state is PasswordResetVerifyingOtp;

        return Scaffold(
          backgroundColor: AppColors.grayF9,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: AppColors.grayF9,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: BodyPaddings.horizontalPage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        child: Text(
                          'OTP Verification',
                          style: AppTypography.medium.copyWith(fontSize: 20.sp),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      OtpCodeInput(
                        length: 6,
                        onChanged: (String code) {
                          _enteredCode = code;
                        },
                      ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BodyPaddings.large,
                        ),
                        child: Text(
                          'Enter the OTP sent to ${widget.phone}.',
                          style: AppTypography.body.copyWith(
                            fontSize: 15.sp,
                            color: const Color(0xFF646161),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      CustomButton.filled(
                        label: 'Verify',
                        isPrimary: true,
                        isLoading: isVerifying,
                        onPressed: isVerifying ? null : () => _onVerify(cubit),
                      ),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: isBusy
                            ? null
                            : () {
                                cubit.sendOtp(widget.phone);
                              },
                        child: Text(
                          'Resend OTP',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.blueGray374957,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      const Text('Can\'t login?'),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CustomButton.capsule(
                            label: 'Password Reset',
                            filled: true,
                            fillColor: AppColors.white,
                            onPressed: () {
                              context.goNamed(AppRouteNames.emailPasswordReset);
                            },
                          ),
                          SizedBox(width: 5.w),
                          CustomButton.capsule(
                            label: 'Login',
                            filled: true,
                            fillColor: AppColors.white,
                            onPressed: () {
                              context.goNamed(AppRouteNames.login);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          color: AppColors.blueGray374957,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: AppColors.blueGray374957,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.goNamed(AppRouteNames.signup);
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.5.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
