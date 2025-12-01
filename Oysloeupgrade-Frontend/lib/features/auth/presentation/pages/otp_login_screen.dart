import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/common/widgets/input.dart';
import 'package:oysloe_mobile/core/constants/body_paddings.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/utils/validator.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/otp/otp_cubit.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/otp/otp_state.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.grayF9,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
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
                        "OTP Login",
                        style: AppTypography.medium.copyWith(fontSize: 20.sp),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppTextField(
                      controller: _phoneController,
                      hint: "+233",
                      leadingSvgAsset: 'assets/icons/phone.svg',
                      keyboardType: TextInputType.phone,
                      validator: CustomValidator.validatePhoneNumber,
                    ),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BodyPaddings.large,
                      ),
                      child: Text(
                        "We’ll send a verification code to the number if it’s being in our system.",
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
                        if (state is OtpSent) {
                          final cleanedPhone =
                              CustomValidator.getCleanPhoneNumber(
                                  _phoneController.text);
                          context.pushNamed(AppRouteNames.otpVerification,
                              extra: cleanedPhone);
                        } else if (state is OtpError) {
                          showErrorSnackBar(context, state.message);
                        }
                      },
                      builder: (context, state) {
                        return CustomButton.filled(
                          label: 'Verify',
                          isPrimary: true,
                          isLoading: state is OtpSending,
                          onPressed: state is OtpSending
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    final cleanedPhone =
                                        CustomValidator.getCleanPhoneNumber(
                                            _phoneController.text);
                                    context
                                        .read<OtpCubit>()
                                        .sendOtp(cleanedPhone);
                                  }
                                },
                        );
                      },
                    ),
                    SizedBox(height: 2.5.h),
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
      ),
    );
  }
}
