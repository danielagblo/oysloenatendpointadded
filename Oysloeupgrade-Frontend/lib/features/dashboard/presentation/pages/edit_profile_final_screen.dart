import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:oysloe_mobile/core/common/widgets/adaptive_progress_indicator.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/common/widgets/input.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/usecase/update_profile_params.dart';
import 'package:oysloe_mobile/core/constants/api.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/features/auth/domain/entities/auth_entity.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/profile/profile_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/profile/profile_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/models/edit_profile_draft.dart';

class EditProfileFinalScreen extends StatefulWidget {
  const EditProfileFinalScreen({super.key, required this.draft});

  final EditProfileDraft draft;

  @override
  State<EditProfileFinalScreen> createState() => _EditProfileFinalScreenState();
}

class _EditProfileFinalScreenState extends State<EditProfileFinalScreen> {
  // General details
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _firstNumberCtrl = TextEditingController();
  final _secondNumberCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Payment account
  final _accountNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _networkCtrl = TextEditingController();

  bool _showSuccessCard = false;
  bool _dismissedCard = false;
  late EditProfileDraft _draft;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _firstNumberCtrl.dispose();
    _secondNumberCtrl.dispose();
    _nationalIdCtrl.dispose();
    _businessNameCtrl.dispose();
    _addressCtrl.dispose();
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _prefillFromDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ProfileCubit>();
      _updateVerificationState(cubit.state.user);
    });
  }

  void _prefillFromDraft() {
    _nameCtrl.text = _draft.name ?? '';
    _emailCtrl.text = _draft.email ?? '';
    _firstNumberCtrl.text = _draft.firstNumber ?? '';
    _secondNumberCtrl.text = _draft.secondNumber ?? '';
    _nationalIdCtrl.text = _draft.nationalId ?? '';
    _businessNameCtrl.text = _draft.businessName ?? '';
    _addressCtrl.text = _draft.address ?? '';
    _accountNameCtrl.text = _draft.accountName ?? '';
    _accountNumberCtrl.text = _draft.accountNumber ?? '';
    _networkCtrl.text = _draft.mobileNetwork ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        backgroundColor: AppColors.white,
        title: 'Edit profile',
      ),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<ProfileCubit, ProfileState>(
              listenWhen: (previous, current) => previous.user != current.user,
              listener: (_, state) => _updateVerificationState(state.user),
            ),
            BlocListener<ProfileCubit, ProfileState>(
              listenWhen: (previous, current) =>
                  previous.message != current.message &&
                  current.message != null,
              listener: (context, state) {
                final String? message = state.message;
                if (message == null) return;
                if (state.isMessageError) {
                  showErrorSnackBar(context, message);
                } else {
                  showSuccessSnackBar(context, message);
                  GoRouter.of(context).go(AppRoutePaths.dashboardHome);
                }
              },
            ),
          ],
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state.status == ProfileStatus.loading && state.user == null) {
                return const Center(child: AdaptiveProgressIndicator());
              }

              if (state.status == ProfileStatus.failure && state.user == null) {
                return _ProfileErrorView(
                  onRetry: () => context.read<ProfileCubit>().fetchProfile(),
                );
              }

              return _buildProfileForm(context, state);
            },
          ),
        ),
      ),
    );
  }

  void _updateVerificationState(AuthUserEntity? user) {
    final bool shouldShowCard = !(user?.adminVerified ?? false);
    if (!shouldShowCard) {
      if (_showSuccessCard) {
        setState(() => _showSuccessCard = false);
      }
      _dismissedCard = false;
    } else if (!_dismissedCard && !_showSuccessCard) {
      setState(() => _showSuccessCard = true);
    }
  }

  void _submit(BuildContext context) {
    final String name = _nameCtrl.text.trim();
    final String email = _emailCtrl.text.trim();
    final String phone = _firstNumberCtrl.text.trim();
    final String mobileNetwork = _networkCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      showErrorSnackBar(
        context,
        'Name, email, and first number are required.',
      );
      return;
    }

    final cubit = context.read<ProfileCubit>();
    _draft = _draft.copyWith(
      name: name,
      email: email,
      firstNumber: phone,
      secondNumber: _secondNumberCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      businessName: _businessNameCtrl.text.trim(),
      nationalId: _nationalIdCtrl.text.trim(),
      accountName: _accountNameCtrl.text.trim(),
      accountNumber: _accountNumberCtrl.text.trim(),
      mobileNetwork: mobileNetwork.isEmpty ? null : mobileNetwork,
    );

    cubit.updateProfile(
      UpdateProfileParams(
        name: name,
        email: email,
        phone: phone,
        address: _addressCtrl.text,
        secondNumber: _secondNumberCtrl.text,
        businessName: _businessNameCtrl.text,
        idNumber: _nationalIdCtrl.text,
        accountName: _accountNameCtrl.text,
        accountNumber: _accountNumberCtrl.text,
        mobileNetwork: mobileNetwork.isEmpty ? null : mobileNetwork,
        preferredNotificationEmail: email,
        preferredNotificationPhone: phone,
        avatarFilePath: _draft.profileImagePath,
        businessLogoFilePath: _draft.businessLogoPath,
        idFrontFilePath: _draft.idFrontPath,
        idBackFilePath: _draft.idBackPath,
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, ProfileState state) {
    final AuthUserEntity? user = state.user;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double horizontalPadding =
            maxWidth > 600 ? (maxWidth - 560) / 2 : 5.w;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 2.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.status == ProfileStatus.loading && user != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 1.5.h),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    backgroundColor: AppColors.grayD9,
                  ),
                ),
              if (_showSuccessCard)
                _SuccessProgressCard(
                  onClose: () => setState(() {
                    _showSuccessCard = false;
                    _dismissedCard = true;
                  }),
                  onPostAd: () {},
                ),
              if (_showSuccessCard) SizedBox(height: 2.2.h),
              _AvatarAndLogoRow(draft: _draft),
              SizedBox(height: 2.2.h),
              Text(
                'General Details',
                style: AppTypography.body.copyWith(
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 1.2.h),
              const _FieldLabel('Name'),
              AppTextField(
                controller: _nameCtrl,
                hint: 'Enter full name',
                leadingSvgAsset: 'assets/icons/name.svg',
                textInputAction: TextInputAction.next,
                compact: true,
              ),
              SizedBox(height: 1.6.h),
              Row(
                children: [
                  const _FieldLabel('Email'),
                  SizedBox(width: 8),
                  if (user?.emailVerified == true) const _VerifiedChip(),
                ],
              ),
              AppTextField(
                controller: _emailCtrl,
                hint: 'Enter email address',
                leadingSvgAsset: 'assets/icons/email.svg',
                textInputAction: TextInputAction.next,
                compact: true,
              ),
              SizedBox(height: 1.6.h),
              const _FieldLabel('First number'),
              AppTextField(
                controller: _firstNumberCtrl,
                hint: 'Primary phone number',
                leadingSvgAsset: 'assets/icons/outgoing_call.svg',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                compact: true,
              ),
              SizedBox(height: 1.6.h),
              const _FieldLabel('Second number'),
              AppTextField(
                controller: _secondNumberCtrl,
                hint: 'Alternate phone number',
                leadingSvgAsset: 'assets/icons/outgoing_call.svg',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                compact: true,
              ),
              SizedBox(height: 1.6.h),
              const _FieldLabel('Address'),
              AppTextField(
                controller: _addressCtrl,
                hint: 'Enter residential address',
                leadingSvgAsset: 'assets/icons/loc.svg',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.streetAddress,
                compact: true,
              ),
              SizedBox(height: 1.6.h),
              Row(
                children: [
                  const _FieldLabel('National ID'),
                  SizedBox(width: 8),
                  if (user?.adminVerified == true) const _VerifiedChip(),
                ],
              ),
              AppTextField(
                controller: _nationalIdCtrl,
                hint: 'National ID number',
                leadingSvgAsset: 'assets/icons/id.svg',
                textInputAction: TextInputAction.next,
                compact: true,
              ),
              SizedBox(height: 1.6.h),
              const _FieldLabel('Business name'),
              AppTextField(
                controller: _businessNameCtrl,
                hint: 'Business name (optional)',
                leadingSvgAsset: 'assets/icons/bag.svg',
                textInputAction: TextInputAction.next,
                compact: true,
              ),
              SizedBox(height: 2.2.h),
              Text(
                'Payment Account',
                style: AppTypography.body.copyWith(
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 1.2.h),
              const _FieldLabel('Account name'),
              AppTextField(
                controller: _accountNameCtrl,
                hint: 'Enter account name',
                leadingSvgAsset: 'assets/icons/account_name.svg',
                textInputAction: TextInputAction.next,
                compact: true,
              ),
              SizedBox(height: 1.6.h),
              const _FieldLabel('Account number'),
              AppTextField(
                controller: _accountNumberCtrl,
                hint: 'Enter account number',
                leadingSvgAsset: 'assets/icons/referral.svg',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                compact: true,
              ),
              SizedBox(height: 1.6.h),
              const _FieldLabel('Mobile network'),
              AppTextField(
                controller: _networkCtrl,
                hint: 'Mobile network',
                leadingSvgAsset: 'assets/icons/mobile_network.svg',
                textInputAction: TextInputAction.next,
                compact: true,
              ),
              SizedBox(height: 3.h),
              CustomButton.filled(
                label: 'Save changes',
                onPressed: () => _submit(context),
                isPrimary: false,
                backgroundColor: AppColors.white,
                textStyle: AppTypography.body.copyWith(
                  color: AppColors.blueGray374957,
                  fontWeight: FontWeight.w500,
                ),
                isLoading: state.isUpdating,
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load your profile right now.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.blueGray374957,
              ),
            ),
            SizedBox(height: 2.h),
            CustomButton.filled(
              label: 'Retry',
              onPressed: onRetry,
              isPrimary: false,
              backgroundColor: AppColors.white,
              textStyle: AppTypography.body.copyWith(
                color: AppColors.blueGray374957,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessProgressCard extends StatelessWidget {
  const _SuccessProgressCard({required this.onClose, required this.onPostAd});
  final VoidCallback onClose;
  final VoidCallback onPostAd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(3.w, 1.0.h, 3.w, 1.6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -18,
            right: -15,
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: AppColors.blueGray374957),
              tooltip: 'Close',
              padding: const EdgeInsets.all(0),
              constraints: const BoxConstraints(),
              iconSize: 17,
            ),
          ),
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: const LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 8,
                  backgroundColor: AppColors.grayF9,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              SizedBox(height: 1.2.h),
              Text(
                "You're set now 100%",
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.blueGray374957,
                ),
              ),
              SizedBox(height: 0.3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Congrats! Submit your first ad',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.blueGray374957,
                    ),
                  ),
                  CustomButton.capsule(
                    label: '+ Post Ad',
                    onPressed: onPostAd,
                    filled: true,
                    fillColor: AppColors.grayD9.withValues(alpha: 0.19),
                    textStyle: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w500),
                    height: 36,
                    width: 130,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarAndLogoRow extends StatelessWidget {
  const _AvatarAndLogoRow({required this.draft});
  final EditProfileDraft draft;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CircleImageTile(
          label: 'Profile image',
          svgPlaceholder: 'assets/images/default_user.svg',
          imageUrl: draft.profileImageUrl,
          imagePath: draft.profileImagePath,
        ),
        _CircleImageTile(
          label: 'Business logo',
          svgPlaceholder: 'assets/icons/image.svg',
          imageUrl: draft.businessLogoUrl,
          imagePath: draft.businessLogoPath,
        ),
      ],
    );
  }
}

class _CircleImageTile extends StatelessWidget {
  const _CircleImageTile({
    required this.label,
    required this.svgPlaceholder,
    this.imageUrl,
    this.imagePath,
  });

  final String label;
  final String svgPlaceholder;
  final String? imageUrl;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    String? normalizedUrl;
    final String raw = (imageUrl ?? '').trim();
    if (raw.isNotEmpty) {
      if (raw.startsWith('/')) {
        final Uri baseUri = Uri.parse(AppStrings.baseUrl);
        final String origin = '${baseUri.scheme}://${baseUri.host}';
        normalizedUrl = '$origin$raw';
      } else {
        normalizedUrl = raw;
      }
    }
    final bool hasLocal = imagePath != null && imagePath!.isNotEmpty;
    Widget child;
    if (hasLocal) {
      final File localFile = File(imagePath!);
      child = ClipOval(
        child: kIsWeb
            ? Image.network(
                localFile.path,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : Image.file(
                localFile,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
      );
    } else if (normalizedUrl != null) {
      child = ClipOval(
        child: Image.network(
          normalizedUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => SvgPicture.asset(
            svgPlaceholder,
            width: 28,
            height: 28,
          ),
        ),
      );
    } else {
      child = SvgPicture.asset(
        svgPlaceholder,
        width: 28,
        height: 28,
      );
    }

    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(color: AppColors.primary, width: 4),
          ),
          alignment: Alignment.center,
          child: child,
        ),
        SizedBox(height: 0.8.h),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.6.h, left: 0.2.w),
      child: Text(
        text,
        style: AppTypography.body.copyWith(
          color: AppColors.blueGray374957,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: Color(0xFF00ACFF),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        'Verified',
        style: AppTypography.bodySmall
            .copyWith(fontWeight: FontWeight.w500, color: AppColors.white),
      ),
    );
  }
}
