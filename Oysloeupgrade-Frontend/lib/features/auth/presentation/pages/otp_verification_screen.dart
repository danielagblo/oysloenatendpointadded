import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/constants/body_paddings.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/otp/otp_cubit.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/otp/otp_state.dart';
import 'package:oysloe_mobile/features/auth/presentation/widgets/otp_code_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;

  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otpCode = '';

  @override
  Widget build(BuildContext context) {
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    child: Text(
                      "OTP Verification",
                      style: AppTypography.medium.copyWith(fontSize: 20.sp),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  OtpCodeInput(
                    length: 6,
                    onChanged: (code) => _otpCode = code,
                  ),
                  SizedBox(height: 2.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BodyPaddings.large,
                    ),
                    child: Text(
                      "Enter the OTP sent to ${widget.phone}.",
                      style: AppTypography.body.copyWith(
                        fontSize: 15.sp,
                        color: Color(0xFF646161),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  BlocConsumer<OtpCubit, OtpState>(
                    listener: (context, state) {
                      if (state is OtpVerified) {
                        context.go(AppRoutePaths.dashboardHome);
                      } else if (state is OtpError) {
                        showErrorSnackBar(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      return CustomButton.filled(
                        label: 'Verify',
                        isPrimary: true,
                        isLoading: state is OtpVerifying,
                        onPressed: state is OtpVerifying
                            ? null
                            : () {
                                if (_otpCode.length == 6) {
                                  context
                                      .read<OtpCubit>()
                                      .verifyOtp(widget.phone, _otpCode);
                                }
                              },
                      );
                    },
                  ),
                  SizedBox(height: 2.h),
                  BlocBuilder<OtpCubit, OtpState>(
                    builder: (context, state) {
                      return TextButton(
                        onPressed: state is OtpSending
                            ? null
                            : () {
                                context.read<OtpCubit>().sendOtp(widget.phone);
                                showSuccessSnackBar(
                                    context, 'OTP resent to ${widget.phone}');
                              },
                        child: Text(
                          'Resend OTP',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.blueGray374957,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 1.h),
                  Text('Can\'t login?'),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton.capsule(
                        label: 'Password Reset',
                        filled: true,
                        fillColor: AppColors.white,
                        onPressed: () {
                          context.pushNamed(AppRouteNames.emailPasswordReset);
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
                children: [
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      color: AppColors.blueGray374957,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: "Sign Up",
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
  }
}
