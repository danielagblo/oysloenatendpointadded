import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/common/widgets/input.dart';
import 'package:oysloe_mobile/core/constants/body_paddings.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/utils/validator.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/password_reset/password_reset_cubit.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/password_reset/password_reset_state.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EmailPasswordResetScreen extends StatefulWidget {
  const EmailPasswordResetScreen({super.key});

  @override
  State<EmailPasswordResetScreen> createState() =>
      _EmailPasswordResetScreenState();
}

class _EmailPasswordResetScreenState extends State<EmailPasswordResetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit(PasswordResetCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar(context, 'Please enter a valid phone number.');
      return;
    }

    final String cleanedPhone =
        CustomValidator.getCleanPhoneNumber(_phoneController.text);

    FocusScope.of(context).unfocus();
    cubit.sendOtp(cleanedPhone);
  }

  @override
  Widget build(BuildContext context) {
    final PasswordResetCubit cubit = context.read<PasswordResetCubit>();

    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listener: (BuildContext context, PasswordResetState state) {
        if (state is PasswordResetError) {
          showErrorSnackBar(context, state.message);
        } else if (state is PasswordResetOtpSent) {
          final String cleanedPhone =
              CustomValidator.getCleanPhoneNumber(_phoneController.text);
          showSuccessSnackBar(context, state.response.message);
          context.pushNamed(
            AppRouteNames.passwordResetOtp,
            extra: cleanedPhone,
          );
        }
      },
      builder: (BuildContext context, PasswordResetState state) {
        final bool isSending = state is PasswordResetSendingOtp;
        final bool isResendDisabled =
            isSending || _phoneController.text.trim().isEmpty;

        return Scaffold(
          backgroundColor: AppColors.grayF9,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: AppColors.grayF9,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: BodyPaddings.horizontalPage,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Align(
                          child: Text(
                            'Reset password',
                            style:
                                AppTypography.medium.copyWith(fontSize: 20.sp),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        AppTextField(
                          controller: _phoneController,
                          hint: '+233',
                          leadingSvgAsset: 'assets/icons/phone.svg',
                          keyboardType: TextInputType.phone,
                          validator: CustomValidator.validatePhoneNumber,
                          onChanged: (_) => setState(() {}),
                          enabled: !isSending,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'We’ll send a verification code to the number if it’s in our system.',
                          style: AppTypography.body.copyWith(
                            fontSize: 15.sp,
                            color: const Color(0xFF646161),
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 3.h),
                        CustomButton.filled(
                          label: 'Submit',
                          isPrimary: true,
                          isLoading: isSending,
                          onPressed:
                              isSending ? null : () => _handleSubmit(cubit),
                        ),
                        SizedBox(height: 1.5.h),
                        TextButton(
                          onPressed: isResendDisabled
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    final String cleanedPhone =
                                        CustomValidator.getCleanPhoneNumber(
                                            _phoneController.text);
                                    cubit.sendOtp(cleanedPhone);
                                  }
                                },
                          child: Text(
                            'Resend OTP',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.blueGray374957,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.5.h),
                        const Text('Can\'t login?'),
                        SizedBox(height: 3.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CustomButton.capsule(
                              label: 'Login',
                              filled: true,
                              fillColor: AppColors.white,
                              onPressed: () {
                                context.goNamed(AppRouteNames.login);
                              },
                            ),
                            SizedBox(width: 5.w),
                            CustomButton.capsule(
                              label: 'OTP Login',
                              filled: true,
                              fillColor: AppColors.white,
                              onPressed: () {
                                context.goNamed(AppRouteNames.otpLogin);
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
          ),
        );
      },
    );
  }
}
