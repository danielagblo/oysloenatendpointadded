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
import 'package:oysloe_mobile/core/usecase/login_params.dart';
import 'package:oysloe_mobile/core/utils/validator.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/login/login_cubit.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/login/login_state.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(LoginState state) {
    if (state.isSubmitting) return;
    final LoginCubit cubit = context.read<LoginCubit>();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (!CustomValidator.validateForm(_formKey)) {
      showErrorSnackBar(context, 'Please correct the highlighted fields.');
      return;
    }

    FocusScope.of(context).unfocus();
    cubit.submit(LoginParams(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (BuildContext context, LoginState state) {
        if (state.isFailure) {
          final String message =
              state.errorMessage ?? 'Unable to complete login.';
          showErrorSnackBar(context, message);
        }

        if (state.isSuccess) {
          context.go(AppRoutePaths.dashboardHome);
        }
      },
      builder: (BuildContext context, LoginState state) {
        final bool isSubmitting = state.isSubmitting;

        return Scaffold(
          backgroundColor: AppColors.grayF9,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: AppColors.grayF9,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  context.go(AppRoutePaths.dashboardHome);
                },
                child: Text(
                  'Skip',
                  style: AppTypography.body.copyWith(
                    color: AppColors.blueGray374957,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
            ],
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
                            'Welcome!',
                            style:
                                AppTypography.medium.copyWith(fontSize: 20.sp),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        AppTextField(
                          controller: _emailController,
                          hint: 'Email Address',
                          leadingSvgAsset: 'assets/icons/email.svg',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !isSubmitting,
                          validator: (value) {
                            final emptyCheck =
                                CustomValidator.isNotEmpty(value ?? '');
                            if (emptyCheck != null) return emptyCheck;
                            return CustomValidator.validateEmail(value ?? '');
                          },
                        ),
                        SizedBox(height: 2.h),
                        AppTextField(
                          controller: _passwordController,
                          hint: 'Password',
                          leadingSvgAsset: 'assets/icons/passwordkey.svg',
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          enabled: !isSubmitting,
                          validator: (value) {
                            final emptyCheck =
                                CustomValidator.isNotEmpty(value ?? '');
                            if (emptyCheck != null) return emptyCheck;
                            return CustomValidator.validatePassword(
                              value ?? '',
                            );
                          },
                        ),
                        SizedBox(height: 5.h),
                        CustomButton.filled(
                          label: 'Login',
                          isPrimary: true,
                          onPressed: isSubmitting ? null : () => _submit(state),
                          isLoading: isSubmitting,
                        ),
                        SizedBox(height: 2.5.h),
                        CustomButton.filled(
                          label: 'Login using google',
                          backgroundColor: AppColors.white,
                          leadingSvgAsset: 'assets/icons/google.svg',
                          isPrimary: false,
                          onPressed: isSubmitting ? null : () {},
                        ),
                        SizedBox(height: 3.h),
                        Text('Can\'t login?'),
                        SizedBox(height: 3.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CustomButton.capsule(
                              label: 'Password Reset',
                              filled: true,
                              fillColor: AppColors.white,
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                      context.pushNamed(
                                          AppRouteNames.emailPasswordReset);
                                    },
                            ),
                            SizedBox(width: 5.w),
                            CustomButton.capsule(
                              label: 'OTP Login',
                              filled: true,
                              fillColor: AppColors.white,
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                      context.pushNamed(AppRouteNames.otpLogin);
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
                              if (isSubmitting) return;
                              context.pushNamed(AppRouteNames.signup);
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
