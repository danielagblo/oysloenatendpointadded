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
import 'package:oysloe_mobile/core/usecase/register_params.dart';
import 'package:oysloe_mobile/core/utils/validator.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/register/register_cubit.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/register/register_state.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isChecked = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAgreement(bool isSubmitting) {
    if (isSubmitting) return;
    setState(() => _isChecked = !_isChecked);
  }



  void _submit(RegisterState state) {
    final cubit = context.read<RegisterCubit>();
    if (state.isSubmitting) return;

    if (!CustomValidator.validateForm(_formKey)) {
      showErrorSnackBar(context, 'Please correct the highlighted fields.');
      return;
    }

    if (!_isChecked) {
      showErrorSnackBar(context, 'Please accept the privacy policy and terms.');
      return;
    }

    FocusScope.of(context).unfocus();

    final params = RegisterParams(
      email: _emailController.text.trim(),
      phone: CustomValidator.getCleanPhoneNumber(_phoneController.text),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );

    cubit.submit(params);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state.isFailure) {
          final message =
              state.errorMessage ?? 'Unable to complete registration.';
          showErrorSnackBar(context, message);
        }

        if (state.isSuccess) {
          context.goNamed(AppRouteNames.referralCode);
        }
      },
      builder: (context, state) {
        final isSubmitting = state.isSubmitting;

        return Scaffold(
          backgroundColor: AppColors.grayF9,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: AppColors.grayF9,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
                  BodyPaddings.horizontalPage.add(EdgeInsets.only(bottom: 4.h)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      child: Text(
                        "Get Started",
                        style: AppTypography.medium.copyWith(fontSize: 20.sp),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppTextField(
                      controller: _nameController,
                      hint: "Name",
                      leadingSvgAsset: 'assets/icons/name.svg',
                      keyboardType: TextInputType.name,
                      validator: (value) =>
                          CustomValidator.validateName(value ?? ''),
                    ),
                    SizedBox(height: 1.5.h),
                    AppTextField(
                      controller: _emailController,
                      hint: "Email Address",
                      leadingSvgAsset: 'assets/icons/email.svg',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final emptyCheck =
                            CustomValidator.isNotEmpty(value ?? '');
                        if (emptyCheck != null) return emptyCheck;
                        return CustomValidator.validateEmail(value ?? '');
                      },
                    ),
                    SizedBox(height: 1.5.h),
                    AppTextField(
                      controller: _phoneController,
                      hint: "+233",
                      leadingSvgAsset: 'assets/icons/phone.svg',
                      keyboardType: TextInputType.phone,
                      validator: CustomValidator.validatePhoneNumber,
                    ),
                    SizedBox(height: 1.5.h),
                    AppTextField(
                      controller: _passwordController,
                      hint: "Password",
                      leadingSvgAsset: 'assets/icons/passwordkey.svg',
                      isPassword: true,
                      validator: (value) {
                        final emptyCheck =
                            CustomValidator.isNotEmpty(value ?? '');
                        if (emptyCheck != null) return emptyCheck;
                        return CustomValidator.validatePassword(
                          value ?? '',
                        );
                      },
                    ),
                    SizedBox(height: 1.5.h),
                    AppTextField(
                      controller: _confirmPasswordController,
                      hint: "Retype Password",
                      leadingSvgAsset: 'assets/icons/passwordkey.svg',
                      isPassword: true,
                      validator: (value) {
                        final emptyCheck =
                            CustomValidator.isNotEmpty(value ?? '');
                        if (emptyCheck != null) return emptyCheck;
                        return CustomValidator.validatePasswordFields(
                          _passwordController.text,
                          value,
                        );
                      },
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'I have agreed to the ',
                            style: TextStyle(
                              color: AppColors.blueGray374957,
                              fontSize: 13.sp,
                            ),
                            children: [
                              TextSpan(
                                text: 'Privacy policy ',
                                style: TextStyle(
                                  color: AppColors.blueGray374957,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                              TextSpan(
                                text: 'and ',
                                style:
                                    TextStyle(color: AppColors.blueGray374957),
                              ),
                              TextSpan(
                                text: 'terms & conditions',
                                style: TextStyle(
                                  color: AppColors.blueGray374957,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.w),
                        GestureDetector(
                          onTap: () => _toggleAgreement(isSubmitting),
                          child: Container(
                            width: 1.7.h,
                            height: 1.7.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.blueGray374957,
                                width: 1.5,
                              ),
                              color: _isChecked
                                  ? AppColors.blueGray374957
                                  : Colors.transparent,
                            ),
                            child: _isChecked
                                ? Icon(
                                    Icons.check,
                                    size: 12,
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    CustomButton.filled(
                      label: 'Sign up',
                      isPrimary: true,
                      onPressed: isSubmitting ? null : () => _submit(state),
                      isLoading: isSubmitting,
                    ),
                    SizedBox(height: 2.5.h),
                    CustomButton.filled(
                      label: 'Sign up using google',
                      backgroundColor: AppColors.white,
                      leadingSvgAsset: 'assets/icons/google.svg',
                      isPrimary: false,
                      onPressed: isSubmitting ? null : () {},
                    ),
                    SizedBox(height: 4.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: AppColors.blueGray374957,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: AppColors.blueGray374957,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                if (isSubmitting) return;
                                context.goNamed(AppRouteNames.login);
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
