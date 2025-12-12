part of "routes.dart";

final List<RouteBase> routes = <RouteBase>[
  GoRoute(
    name: AppRouteNames.splash,
    path: AppRoutePaths.splash,
    pageBuilder: defaultPageBuilder(const SplashScreen()),
  ),
  GoRoute(
    name: AppRouteNames.onboarding,
    path: AppRoutePaths.onboarding,
    pageBuilder: defaultPageBuilder(const OnboardingFlow()),
  ),
  GoRoute(
    name: AppRouteNames.signup,
    path: AppRoutePaths.signup,
    pageBuilder: (context, state) {
      return buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: BlocProvider(
          create: (_) => sl<RegisterCubit>(),
          child: const SignupScreen(),
        ),
      );
    },
  ),
  GoRoute(
    name: AppRouteNames.login,
    path: AppRoutePaths.login,
    pageBuilder: (context, state) {
      return buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: BlocProvider(
          create: (_) => sl<LoginCubit>(),
          child: const LoginScreen(),
        ),
      );
    },
  ),
  GoRoute(
    name: AppRouteNames.emailPasswordReset,
    path: AppRoutePaths.emailPasswordReset,
    pageBuilder: (context, state) {
      return buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: BlocProvider(
          create: (_) => sl<PasswordResetCubit>(),
          child: const EmailPasswordResetScreen(),
        ),
      );
    },
  ),
  GoRoute(
    name: AppRouteNames.passwordResetOtp,
    path: AppRoutePaths.passwordResetOtp,
    pageBuilder: (context, state) {
      final String phone = state.extra as String? ?? '';
      return buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: BlocProvider(
          create: (_) => sl<PasswordResetCubit>(),
          child: PasswordResetOtpScreen(phone: phone),
        ),
      );
    },
  ),
  GoRoute(
    name: AppRouteNames.passwordResetNewPassword,
    path: AppRoutePaths.passwordResetNewPassword,
    pageBuilder: (context, state) {
      final Map<String, String> data =
          (state.extra as Map<String, String>?) ?? const <String, String>{};
      final String phone = data['phone'] ?? '';
      final String token = data['token'] ?? '';
      return buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: BlocProvider(
          create: (_) => sl<PasswordResetCubit>(),
          child: PasswordResetNewPasswordScreen(
            phone: phone,
            token: token,
          ),
        ),
      );
    },
  ),
  GoRoute(
    name: AppRouteNames.otpLogin,
    path: AppRoutePaths.otpLogin,
    pageBuilder: (context, state) {
      return buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: BlocProvider(
          create: (_) => sl<OtpCubit>(),
          child: const OtpLoginScreen(),
        ),
      );
    },
  ),
  GoRoute(
    name: AppRouteNames.referralCode,
    path: AppRoutePaths.referralCode,
    pageBuilder: defaultPageBuilder(const ReferralCodeScreen()),
  ),
  GoRoute(
    name: AppRouteNames.otpVerification,
    path: AppRoutePaths.otpVerification,
    pageBuilder: (context, state) {
      final phone = state.extra as String? ?? '';
      return buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: BlocProvider(
          create: (_) => sl<OtpCubit>(),
          child: OtpVerificationScreen(phone: phone),
        ),
      );
    },
  ),
  ShellRoute(
    builder: (context, state, child) {
      int currentIndex = 0;
      final String location = state.uri.toString();

      if (location.startsWith(AppRoutePaths.dashboardAlerts)) {
        currentIndex = 1;
      } else if (location.startsWith(AppRoutePaths.dashboardPostAd)) {
        currentIndex = 2;
      } else if (location.startsWith(AppRoutePaths.dashboardInbox)) {
        currentIndex = 3;
      } else if (location.startsWith('/dashboard/profile')) {
        currentIndex = 4;
      }

      return NavigationShell(
        currentIndex: currentIndex,
        child: child,
      );
    },
    routes: [
      GoRoute(
        name: AppRouteNames.dashboardHome,
        path: AppRoutePaths.dashboardHome,
        pageBuilder: (context, state) {
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => sl<ProductsCubit>()..fetch(),
                ),
                BlocProvider(
                  create: (_) => sl<CategoriesCubit>()..fetch(),
                ),
                BlocProvider(
                  create: (_) => sl<SubcategoriesCubit>(),
                ),
                BlocProvider(
                  create: (_) => sl<LocationsCubit>()..fetch(),
                ),
              ],
              child: const AnimatedHomeScreen(),
            ),
          );
        },
        routes: [
          GoRoute(
            name: AppRouteNames.dashboardHomeAdDetail,
            path: AppRoutePaths.dashboardHomeAdDetail,
            pageBuilder: (context, state) {
              final adId = state.pathParameters['adId']!;
              final extra = state.extra as Map<String, dynamic>?;
              return buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: AdDetailScreen(
                  adId: adId,
                  adType: extra?['adType'] as AdDealType?,
                  imageUrl: extra?['imageUrl'] as String?,
                  title: extra?['title'] as String?,
                  location: extra?['location'] as String?,
                  prices: extra?['prices'] as List<String>?,
                  product: extra?['product'] as ProductEntity?,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        name: AppRouteNames.dashboardAlerts,
        path: AppRoutePaths.dashboardAlerts,
        pageBuilder: defaultPageBuilder(const AlertsScreen()),
        routes: [
          GoRoute(
            name: AppRouteNames.dashboardAlertsAdDetail,
            path: AppRoutePaths.dashboardAlertsAdDetail,
            pageBuilder: (context, state) {
              final adId = state.pathParameters['adId']!;
              final extra = state.extra as Map<String, dynamic>?;
              return buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: AdDetailScreen(
                  adId: adId,
                  adType: extra?['adType'] as AdDealType?,
                  imageUrl: extra?['imageUrl'] as String?,
                  title: extra?['title'] as String?,
                  location: extra?['location'] as String?,
                  prices: extra?['prices'] as List<String>?,
                  product: extra?['product'] as ProductEntity?,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        name: AppRouteNames.dashboardPostAd,
        path: AppRoutePaths.dashboardPostAd,
        pageBuilder: defaultPageBuilder(const PostAdUploadImagesScreen()),
        routes: [
          GoRoute(
            name: AppRouteNames.dashboardPostAdForm,
            path: AppRoutePaths.dashboardPostAdForm,
            pageBuilder: (context, state) {
              // Handle both List<String>? (images) and ProductEntity (edit mode)
              final extra = state.extra;
              List<String>? selectedImages;
              ProductEntity? productToEdit;
              
              if (extra is List<String>?) {
                selectedImages = extra;
              } else if (extra is ProductEntity) {
                productToEdit = extra;
              }
              
              return buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<ProductsCubit>(
                      create: (_) => sl<ProductsCubit>(),
                    ),
                    BlocProvider<CategoriesCubit>(
                      create: (_) => sl<CategoriesCubit>()..fetch(),
                    ),
                    BlocProvider<SubcategoriesCubit>(
                      create: (_) => sl<SubcategoriesCubit>(),
                    ),
                    BlocProvider<FeaturesCubit>(
                      create: (_) => sl<FeaturesCubit>(),
                    ),
                    BlocProvider<LocationsCubit>(
                      create: (_) => sl<LocationsCubit>()..fetch(),
                    ),
                  ],
                  child: PostAdFormScreen(
                    selectedImages: selectedImages,
                    productToEdit: productToEdit,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        name: AppRouteNames.dashboardInbox,
        path: AppRoutePaths.dashboardInbox,
        pageBuilder: defaultPageBuilder(const InboxScreen()),
        routes: [
          GoRoute(
            name: AppRouteNames.dashboardChat,
            path: AppRoutePaths.dashboardChat,
            pageBuilder: (context, state) {
              final chatId = state.pathParameters['chatId']!;
              final extra = state.extra as Map<String, dynamic>?;
              return buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: ChatScreen(
                  chatId: chatId,
                  otherUserName:
                      extra?['otherUserName'] as String? ?? 'Unknown',
                  otherUserAvatar: extra?['otherUserAvatar'] as String? ??
                      'assets/images/man.jpg',
                  isReadOnly: extra?['isClosed'] as bool? ?? false,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        name: AppRouteNames.dashboardEditProfile,
        path: AppRoutePaths.dashboardEditProfile,
        pageBuilder: (context, state) {
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<ProfileCubit>()..hydrate(),
              child: const EditProfileScreen(),
            ),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.dashboardAds,
        path: AppRoutePaths.dashboardAds,
        pageBuilder: defaultPageBuilder(const AdScreen()),
      ),
      GoRoute(
        name: AppRouteNames.dashboardCategoryAds,
        path: AppRoutePaths.dashboardCategoryAds,
        pageBuilder: (context, state) {
          String? initialCategory;
          int? initialCategoryId;
          final Object? extra = state.extra;

          if (extra is Map<String, dynamic>) {
            initialCategory = extra['label'] as String?;
            final Object? rawId = extra['categoryId'];
            if (rawId is int) {
              initialCategoryId = rawId;
            } else if (rawId is String) {
              initialCategoryId = int.tryParse(rawId);
            }
          } else if (extra is String) {
            initialCategory = extra;
          }

          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => sl<ProductsCubit>()..fetch(),
                ),
                BlocProvider(
                  create: (_) => sl<CategoriesCubit>()..fetch(),
                ),
              ],
              child: CategoryAdsScreen(
                initialCategoryLabel: initialCategory,
                initialCategoryId: initialCategoryId,
              ),
            ),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.dashboardFavorites,
        path: AppRoutePaths.dashboardFavorites,
        pageBuilder: defaultPageBuilder(const FavoriteScreen()),
      ),
      GoRoute(
        name: AppRouteNames.dashboardSubscription,
        path: AppRoutePaths.dashboardSubscription,
        pageBuilder: defaultPageBuilder(const SubscriptionScreen()),
      ),
      GoRoute(
        name: AppRouteNames.dashboardReferEarn,
        path: AppRoutePaths.dashboardReferEarn,
        pageBuilder: defaultPageBuilder(const ReferAndEarnScreen()),
      ),
      GoRoute(
        name: AppRouteNames.dashboardFeedback,
        path: AppRoutePaths.dashboardFeedback,
        pageBuilder: defaultPageBuilder(const FeedbackScreen()),
      ),
      GoRoute(
        name: AppRouteNames.dashboardReviews,
        path: AppRoutePaths.dashboardReviews,
        pageBuilder: (context, state) {
          int? tryParseInt(Object? value) {
            if (value == null) return null;
            if (value is int) return value;
            if (value is num) return value.toInt();
            return int.tryParse(value.toString());
          }

          int productId = 0;
          int? reviewId;
          int? initialRating;
          String? initialComment;

          final Object? extra = state.extra;
          if (extra is int) {
            productId = extra;
          } else if (extra is Map<String, dynamic>) {
            productId = tryParseInt(extra['productId']) ?? 0;
            reviewId = tryParseInt(extra['reviewId']);
            initialRating = tryParseInt(extra['rating']);
            final Object? rawComment = extra['comment'];
            if (rawComment is String) {
              initialComment = rawComment;
            } else if (rawComment != null) {
              initialComment = rawComment.toString();
            }
          }

          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: ReviewsScreen(
              productId: productId,
              reviewId: reviewId,
              initialRating: initialRating,
              initialComment: initialComment,
            ),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.dashboardServices,
        path: AppRoutePaths.dashboardServices,
        pageBuilder: defaultPageBuilder(const ServicesScreen()),
      ),
      GoRoute(
        name: AppRouteNames.dashboardServicesAdditional,
        path: AppRoutePaths.dashboardServicesAdditional,
        pageBuilder: (context, state) {
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: ServicesAdditionalScreen(
              initial: state.extra as dynamic,
            ),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.dashboardServicesReview,
        path: AppRoutePaths.dashboardServicesReview,
        pageBuilder: (context, state) {
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: ServicesReviewScreen(
              initial: state.extra as dynamic,
            ),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.dashboardReport,
        path: AppRoutePaths.dashboardReport,
        pageBuilder: (context, state) {
          final Object? extra = state.extra;
          int? productId;
          if (extra is Map<String, dynamic>) {
            final Object? rawId = extra['productId'];
            if (rawId is int) {
              productId = rawId;
            } else if (rawId is String) {
              productId = int.tryParse(rawId);
            }
          }
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: ReportScreen(productId: productId),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.dashboardPrivacyPolicy,
        path: AppRoutePaths.dashboardPrivacyPolicy,
        pageBuilder: defaultPageBuilder(const PrivacyPolicyScreen()),
      ),
      GoRoute(
        name: AppRouteNames.dashboardTermsConditions,
        path: AppRoutePaths.dashboardTermsConditions,
        pageBuilder: defaultPageBuilder(const TermsConditionsScreen()),
      ),
      GoRoute(
        name: AppRouteNames.dashboardAccount,
        path: AppRoutePaths.dashboardAccount,
        pageBuilder: defaultPageBuilder(const AccountScreen()),
      ),
    ],
  ),
  GoRoute(
    name: AppRouteNames.legacyHomeRedirect,
    path: AppRoutePaths.legacyHomeRedirect,
    redirect: (_, __) => AppRoutePaths.dashboardHome,
  ),
];

final GoRouter appRouter = GoRouter(
  routes: routes,
  initialLocation: AppRoutePaths.splash,
);
