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

  @override
  void initState() {
    super.initState();
    _hydrateSession();
  }

  Future<void> _hydrateSession() async {
    final AuthRepository repository = sl<AuthRepository>();
    final session = repository.currentSession;
    if (session != null) {
      _hasSession = true;
      _user = session.user;
    }

    final refreshed = await repository.cachedSession();
    if (!mounted) return;
    setState(() {
      _hasSession = refreshed != null;
      _user = refreshed?.user ?? _user;
    });
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
                          borderColor:
                              AppColors.grayD9.withValues(alpha: 0.35),
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
                      value: _formatStatValue(_user?.activeAds),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Taken Ads',
                      value: _formatStatValue(_user?.takenAds),
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
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                Row(
                  children: [
                    if (user?.adminVerified == true) ...[
                      Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.blueGray374957,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(_formatLevel(user?.level) ?? '—',
                        style: AppTypography.bodySmall),
                  ],
                ),
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
    if (trimmed.isEmpty) {
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
    }

    return ClipOval(
      child: Image.network(
        url,
        width: 39,
        height: 39,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
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
        child: SvgPicture.asset(iconPath, width: 18, height: 18),
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
                    onPressed: state.isSubmitting
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
                        : const Text('Submit delete request'),
                  ),
                ),
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
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            req.status,
                            style: AppTypography.bodySmall,
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
