import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/navigation/navigation_shell.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:oysloe_mobile/features/auth/presentation/pages/otp_login_screen.dart';
import 'package:oysloe_mobile/features/auth/presentation/pages/otp_verification_screen.dart';
import 'package:oysloe_mobile/features/auth/presentation/pages/email_password_reset.dart';
import 'package:oysloe_mobile/features/auth/presentation/pages/password_reset_new_password_screen.dart';
import 'package:oysloe_mobile/features/auth/presentation/pages/password_reset_otp_screen.dart';
import 'package:oysloe_mobile/features/auth/presentation/pages/referral_code_screen.dart';
import 'package:oysloe_mobile/features/auth/presentation/pages/signup_screen.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/register/register_cubit.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/login/login_cubit.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/otp/otp_cubit.dart';
import 'package:oysloe_mobile/features/auth/presentation/bloc/password_reset/password_reset_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/product_entity.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/home_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/alerts_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/ad_detail_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/inbox_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/chat_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/edit_profile_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/profile/profile_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/ad_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/category_ads.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/favorite_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/feedback_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/report_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/reviews_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/privacy_policy_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/refer_earn_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/subscription_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/terms_conditions_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/account_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/services_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/services_additional_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/services_review_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/post_ad_upload_images_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/post_ad_form_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/ad_card.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/subcategories/subcategories_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/features/features_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/locations/locations_cubit.dart';
import 'package:oysloe_mobile/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:oysloe_mobile/features/onboarding/presentation/pages/onboarding_flow.dart';

part "routers.dart";

class AppRouteNames {
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const signup = 'signup';
  static const login = 'login';
  static const emailPasswordReset = 'email-password-reset';
  static const passwordResetOtp = 'password-reset-otp';
  static const passwordResetNewPassword = 'password-reset-new-password';
  static const otpLogin = 'otp-login';
  static const referralCode = 'referral-code';
  static const otpVerification = 'otp-verification';

  static const dashboardShell = 'dashboard-shell';
  static const dashboardHome = 'dashboard-home';
  static const dashboardHomeAdDetail = 'dashboard-home-ad-detail';
  static const dashboardAlerts = 'dashboard-alerts';
  static const dashboardAlertsAdDetail = 'dashboard-alerts-ad-detail';
  static const dashboardPostAd = 'dashboard-post-ad';
  static const dashboardPostAdForm = 'dashboard-post-ad-form';
  static const dashboardInbox = 'dashboard-inbox';
  static const dashboardChat = 'dashboard-chat';
  static const dashboardEditProfile = 'dashboard-edit-profile';
  static const dashboardAds = 'dashboard-ads';
  static const dashboardFavorites = 'dashboard-favorites';
  static const dashboardSubscription = 'dashboard-subscription';
  static const dashboardReferEarn = 'dashboard-refer-earn';
  static const dashboardFeedback = 'dashboard-feedback';
  static const dashboardReviews = 'dashboard-reviews';
  static const dashboardServices = 'dashboard-services';
  static const dashboardServicesAdditional = 'dashboard-services-additional';
  static const dashboardServicesReview = 'dashboard-services-review';
  static const dashboardReport = 'dashboard-report';
  static const dashboardPrivacyPolicy = 'dashboard-privacy-policy';
  static const dashboardTermsConditions = 'dashboard-terms-conditions';
  static const dashboardAccount = 'dashboard-account';
  static const dashboardCategoryAds = 'dashboard-category-ads';

  static const legacyHomeRedirect = 'legacy-home';
}

class AppRoutePaths {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signup = '/signup';
  static const login = '/login';
  static const emailPasswordReset = '/email-password-reset';
  static const passwordResetOtp = '/password-reset-otp';
  static const passwordResetNewPassword = '/password-reset-new-password';
  static const otpLogin = '/otp-login';
  static const referralCode = '/referral-code';
  static const otpVerification = '/otp-verification';

  static const dashboardHome = '/dashboard/home';
  static const dashboardHomeAdDetail = 'ad-detail/:adId';
  static const dashboardAlerts = '/dashboard/alerts';
  static const dashboardAlertsAdDetail = 'ad-detail/:adId';
  static const dashboardPostAd = '/dashboard/post-ad';
  static const dashboardPostAdForm = 'form';
  static const dashboardInbox = '/dashboard/inbox';
  static const dashboardChat = 'chat/:chatId';
  static const dashboardEditProfile = '/dashboard/profile/edit';
  static const dashboardAds = '/dashboard/ads';
  static const dashboardFavorites = '/dashboard/favorites';
  static const dashboardSubscription = '/dashboard/subscription';
  static const dashboardReferEarn = '/dashboard/refer-earn';
  static const dashboardFeedback = '/dashboard/feedback';
  static const dashboardReviews = '/dashboard/reviews';
  static const dashboardServices = '/dashboard/services';
  static const dashboardServicesAdditional = '/dashboard/services/additional';
  static const dashboardServicesReview = '/dashboard/services/review';
  static const dashboardReport = '/dashboard/report';
  static const dashboardPrivacyPolicy = '/dashboard/privacy-policy';
  static const dashboardTermsConditions = '/dashboard/terms-conditions';
  static const dashboardAccount = '/dashboard/account';
  static const dashboardCategoryAds = '/dashboard/category-ads';

  static const legacyHomeRedirect = '/home-screen';
}

CustomTransitionPage<T> buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

Page<dynamic> Function(BuildContext, GoRouterState) defaultPageBuilder<T>(
        Widget child) =>
    (BuildContext context, GoRouterState state) {
      return buildPageWithDefaultTransition<T>(
        context: context,
        state: state,
        child: child,
      );
    };
