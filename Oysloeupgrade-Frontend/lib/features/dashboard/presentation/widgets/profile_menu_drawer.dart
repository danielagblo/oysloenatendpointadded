import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/common/widgets/modal.dart';
import 'package:oysloe_mobile/core/constants/api.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/usecase/usecase.dart';
import 'package:oysloe_mobile/features/auth/domain/entities/auth_entity.dart';
import 'package:oysloe_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:oysloe_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/account_delete/account_delete_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/account_delete/account_delete_state.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/product_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/get_user_products_usecase.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// A right-side drawer shown when tapping the Profile tab.
/// Width is set by the parent via a SizedBox; this widget focuses on content.
class ProfileMenuDrawer extends StatefulWidget {
  const ProfileMenuDrawer({super.key});

  @override
  State<ProfileMenuDrawer> createState() => _ProfileMenuDrawerState();
}

class _ProfileMenuDrawerState extends State<ProfileMenuDrawer> {
  bool _hasSession = false;
  AuthUserEntity? _user;
  int _activeAdsCount = 0;
  int _takenAdsCount = 0;

  @override
  void initState() {
    super.initState();
    _hydrateSession();
  }

  Future<void> _hydrateSession() async {
    final AuthRepository repository = sl<AuthRepository>();

    // First, get current/cached session
    final session =
        repository.currentSession ?? await repository.cachedSession();
    if (session != null) {
      if (mounted) {
        setState(() {
          _hasSession = true;
          _user = session.user;
          // Use backend counts if available
          _activeAdsCount = session.user.activeAds ?? 0;
          _takenAdsCount = session.user.takenAds ?? 0;
        });
      }
    }

    // Then fetch fresh profile from server
    final profileResult = await repository.getProfile();
    if (!mounted) return;

    profileResult.fold(
      (failure) {
        // If fetch fails, keep cached data
        debugPrint('Profile fetch failed: ${failure.message}');
      },
      (freshUser) {
        setState(() {
          _user = freshUser;
          _hasSession = true;
          // Use backend counts if available
          _activeAdsCount = freshUser.activeAds ?? 0;
          _takenAdsCount = freshUser.takenAds ?? 0;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double radius = 24.0;
    return Drawer(
      backgroundColor: AppColors.grayF9,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: ListView(
            children: [
              if (_hasSession) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    final router = GoRouter.of(context);
                    final navigator = Navigator.of(context);
                    final logoutUseCase = sl<LogoutUseCase>();

                    final bool? shouldLogout = await showAppModal<bool>(
                      context: context,
                      visual: SvgPicture.asset(
                        'assets/icons/green_shield.svg',
                        width: 90,
                        height: 90,
                      ),
                      text: 'Are you sure?',
                      actions: [
                        AppModalAction(
                          label: 'Yes logout',
                          filled: true,
                          fillColor: AppColors.white,
                          borderColor: AppColors.grayD9.withValues(alpha: 0.35),
                          textColor: AppColors.blueGray374957,
                          onPressed: () => Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pop(true),
                        ),
                        AppModalAction(
                          label: 'Close',
                          textColor: AppColors.blueGray374957,
                          onPressed: () => Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pop(false),
                        ),
                      ],
                    );

                    if (shouldLogout != true) return;
                    if (!context.mounted) return;

                    final result = await logoutUseCase(const NoParams());
                    if (!context.mounted) return;

                    result.fold(
                      (failure) => showErrorSnackBar(
                        context,
                        failure.message,
                      ),
                      (_) {
                        navigator.pop();
                        router.go(AppRoutePaths.login);
                        setState(() => _hasSession = false);
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.w),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.grayD9.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/icons/logout.svg'),
                        SizedBox(width: 1.w),
                        Text('Logout', style: AppTypography.body),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
              ],

              // Profile card
              _ProfileHeaderCard(user: _user),

              SizedBox(height: 2.5.h),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Active Ads',
                      value: _activeAdsCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Taken Ads',
                      value: _takenAdsCount.toString(),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              _SectionHeader('Account'),
              _MenuTile(
                iconPath: 'assets/icons/name.svg',
                title: 'Edit profile',
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    router.pushNamed(AppRouteNames.dashboardEditProfile);
                  });
                },
              ),

              SizedBox(height: 2.h),
              _SectionHeader('Business'),
              _MenuTile(
                iconPath: 'assets/icons/ads.svg',
                title: 'Ads',
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    router.pushNamed(AppRouteNames.dashboardAds);
                  });
                },
              ),
              _MenuTile(
                iconPath: 'assets/icons/bookmark.svg',
                title: 'Favorite',
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    router.pushNamed(AppRouteNames.dashboardFavorites);
                  });
                },
              ),
              _MenuTile(
                iconPath: 'assets/icons/subscription.svg',
                title: 'Subscription',
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    router.pushNamed(AppRouteNames.dashboardSubscription);
                  });
                },
              ),
              _MenuTile(
                iconPath: 'assets/icons/refer_earn.svg',
                title: 'Refer & Earn',
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    router.pushNamed(AppRouteNames.dashboardReferEarn);
                  });
                },
              ),

              SizedBox(height: 2.h),
              _SectionHeader('Settings'),
              _MenuTile(
                iconPath: 'assets/icons/feedback.svg',
                title: 'Feedback',
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    router.pushNamed(AppRouteNames.dashboardFeedback);
                  });
                },
              ),
              _MenuTile(
                iconPath: 'assets/icons/account.svg',
                title: 'Account',
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    router.pushNamed(AppRouteNames.dashboardAccount);
                  });
                },
              ),
              _MenuTile(
                iconPath: 'assets/icons/tnc.svg',
                title: 'T&C',
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    router.pushNamed(AppRouteNames.dashboardTermsConditions);
                  });
                },
              ),
              _MenuTile(
                iconPath: 'assets/icons/privacy_policy.svg',
                title: 'Privacy policy',
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    router.pushNamed(AppRouteNames.dashboardPrivacyPolicy);
                  });
                },
              ),
              _MenuTile(
                iconPath: 'assets/icons/delete_icon.png',
                title: 'Delete my account',
                onTap: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (sheetContext) {
                      return const _AccountDeleteRequestSheet();
                    },
                  );
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({this.user});

  final AuthUserEntity? user;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.sp, horizontal: 14.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: AppColors.primary, width: 5),
            ),
            alignment: Alignment.center,
            child: _AvatarImage(avatarUrl: user?.avatar),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name.isNotEmpty == true ? user!.name : 'Guest',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueGray374957)),
                SizedBox(height: 0.5.h),
                Text(_formatLevel(user?.level) ?? '—',
                    style: AppTypography.bodySmall),
                SizedBox(height: 0.8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: 0.7,
                    backgroundColor: AppColors.grayD9.withValues(alpha: 0.5),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style:
                AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 0.5.h),
          Text(title,
              style: AppTypography.bodySmall.copyWith(
                  color: AppColors.blueGray263238.withValues(alpha: 0.42))),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({this.avatarUrl});
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final String trimmed = (avatarUrl ?? '').trim();
    debugPrint('🔍 Avatar URL received: "$avatarUrl"');
    debugPrint('🔍 Avatar URL trimmed: "$trimmed"');

    if (trimmed.isEmpty) {
      debugPrint('⚠️ Avatar URL is empty, showing default icon');
      return SvgPicture.asset(
        'assets/images/default_user.svg',
        width: 39,
        height: 39,
      );
    }

    // Resolve API-relative paths (e.g. "/assets/avatars/xyz.png") to full URLs.
    String url = trimmed;
    if (url.startsWith('/')) {
      final Uri baseUri = Uri.parse(AppStrings.baseUrl);
      final String origin = '${baseUri.scheme}://${baseUri.host}';
      url = '$origin$url';
      debugPrint('🔗 Resolved relative URL to: $url');
    } else {
      debugPrint('🔗 Using absolute URL: $url');
    }

    return ClipOval(
      child: Image.network(
        url,
        width: 39,
        height: 39,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            debugPrint('✅ Avatar loaded successfully');
            return child;
          }
          debugPrint('⏳ Loading avatar...');
          return Container(
            width: 39,
            height: 39,
            color: AppColors.grayE4,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, error, stackTrace) {
          debugPrint('❌ Avatar failed to load: $error');
          return SvgPicture.asset(
            'assets/images/default_user.svg',
            width: 39,
            height: 39,
          );
        },
      ),
    );
  }
}

String? _formatLevel(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final lower = raw.toLowerCase();
  switch (lower) {
    case 'silver':
    case 'gold':
    case 'diamond':
      return lower[0].toUpperCase() + lower.substring(1);
    default:
      return raw;
  }
}

String _formatStatValue(int? value) {
  if (value == null) return '—';
  return NumberFormat.compact().format(value);
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        title,
        style: AppTypography.body
            .copyWith(color: Colors.black.withValues(alpha: 0.47)),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.iconPath,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 37,
        height: 37,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: iconPath.toLowerCase().endsWith('.svg')
            ? SvgPicture.asset(iconPath, width: 18, height: 18)
            : Image.asset(iconPath, width: 18, height: 18),
      ),
      title: Text(title, style: AppTypography.body),
      onTap: onTap,
    );
  }
}

class _AccountDeleteRequestSheet extends StatefulWidget {
  const _AccountDeleteRequestSheet();

  @override
  State<_AccountDeleteRequestSheet> createState() =>
      _AccountDeleteRequestSheetState();
}

class _AccountDeleteRequestSheetState
    extends State<_AccountDeleteRequestSheet> {
  final TextEditingController _reasonController = TextEditingController();
  bool _handledLogout = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountDeleteCubit>()..loadRequests(),
      child: BlocConsumer<AccountDeleteCubit, AccountDeleteState>(
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }

          // If any delete request has been approved, automatically log the user out.
          if (!_handledLogout && state.hasApprovedRequest) {
            _handledLogout = true;
            final logoutUseCase = sl<LogoutUseCase>();
            final router = GoRouter.of(context);
            final navigator = Navigator.of(context);

            logoutUseCase(const NoParams()).then((result) {
              if (!context.mounted) return;
              result.fold(
                (failure) {
                  // Show failure but do not attempt infinite retries.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(failure.message)),
                  );
                },
                (_) {
                  navigator.pop(); // Close the bottom sheet
                  router.go(AppRoutePaths.login);
                },
              );
            });
          }
        },
        builder: (context, state) {
          final cubit = context.read<AccountDeleteCubit>();
          final padding = MediaQuery.of(context).viewInsets;

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: padding.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delete account',
                      style: AppTypography.bodyLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This will send a request to permanently delete your account. '
                  'Our team will review and process it according to our policies.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.blueGray263238.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting || state.hasPendingRequest
                        ? null
                        : () async {
                            await cubit.submitDeleteRequest(
                              reason: _reasonController.text.trim().isEmpty
                                  ? null
                                  : _reasonController.text.trim(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            state.hasPendingRequest
                                ? 'Account deletion pending'
                                : 'Delete account',
                          ),
                  ),
                ),
                if (state.hasPendingRequest) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Your account deletion request is currently pending review. '
                    'You cannot submit another request until this one is processed.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.blueGray263238.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (state.requests.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Previous requests',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      itemCount: state.requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final req = state.requests[index];
                        final String status =
                            (req.status.isEmpty ? 'unknown' : req.status)
                                .toLowerCase();
                        Color chipColor = AppColors.grayD9;
                        Color textColor = AppColors.blueGray374957;
                        String label;
                        if (status.contains('pending')) {
                          chipColor = Colors.amber.shade100;
                          textColor = Colors.amber.shade800;
                          label = 'Pending';
                        } else if (status.contains('approved') ||
                            status.contains('completed')) {
                          chipColor = Colors.green.shade100;
                          textColor = Colors.green.shade800;
                          label = 'Approved';
                        } else if (status.contains('rejected') ||
                            status.contains('denied')) {
                          chipColor = Colors.red.shade100;
                          textColor = Colors.red.shade800;
                          label = 'Rejected';
                        } else {
                          label = req.status;
                        }

                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  req.reason?.trim().isNotEmpty == true
                                      ? req.reason!.trim()
                                      : 'Account delete request',
                                  style: AppTypography.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: chipColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  label,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: req.reason != null &&
                                  req.reason!.trim().isNotEmpty
                              ? Text(
                                  req.reason!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.blueGray263238
                                        .withValues(alpha: 0.7),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
