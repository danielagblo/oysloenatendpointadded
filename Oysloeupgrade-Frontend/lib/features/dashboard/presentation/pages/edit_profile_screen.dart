import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/constants/api.dart';
import 'package:oysloe_mobile/core/common/widgets/input.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/auth/domain/entities/auth_entity.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/profile/profile_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/profile/profile_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/models/edit_profile_draft.dart';
import 'set_payment_account_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _firstNumberCtrl = TextEditingController();
  final _secondNumberCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  AuthUserEntity? _user;
  bool _didPrefill = false;
  File? _profileImageFile;
  File? _businessLogoFile;
  File? _idFrontFile;
  File? _idBackFile;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _businessNameCtrl.dispose();
    _firstNumberCtrl.dispose();
    _secondNumberCtrl.dispose();
    _nationalIdCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyUser(context.read<ProfileCubit>().state.user);
    });
  }

  void _applyUser(AuthUserEntity? user) {
    if (user == null) return;
    _user = user;
    if (_didPrefill) return;
    _nameCtrl.text = user.name;
    _businessNameCtrl.text = user.businessName ?? '';
    _firstNumberCtrl.text = user.phone;
    _secondNumberCtrl.text = user.secondNumber ?? '';
    _nationalIdCtrl.text = user.idNumber ?? '';
    _didPrefill = true;
    setState(() {});
  }

  Future<void> _pickImage(_UploadTarget target) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file == null) return;

      setState(() {
        switch (target) {
          case _UploadTarget.profile:
            _profileImageFile = File(file.path);
            break;
          case _UploadTarget.businessLogo:
            _businessLogoFile = File(file.path);
            break;
          case _UploadTarget.idFront:
            _idFrontFile = File(file.path);
            break;
          case _UploadTarget.idBack:
            _idBackFile = File(file.path);
            break;
        }
      });
    } on PlatformException catch (e) {
      debugPrint('Image picker error: $e');
      if (mounted) {
        showErrorSnackBar(
          context,
          'Something went wrong while opening your photos.',
        );
      }
    }
  }

  void _goToPayment(BuildContext context) {
    final EditProfileDraft draft = _buildDraft();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileCubit>(),
          child: SetPaymentAccountScreen(initialDraft: draft),
        ),
      ),
    );
  }

  EditProfileDraft _buildDraft() {
    return EditProfileDraft(
      name: _nameCtrl.text.trim(),
      businessName: _businessNameCtrl.text.trim(),
      firstNumber: _firstNumberCtrl.text.trim(),
      secondNumber: _secondNumberCtrl.text.trim(),
      nationalId: _nationalIdCtrl.text.trim(),
      email: _user?.email,
      address: _user?.address,
      accountName: _user?.accountName,
      accountNumber: _user?.accountNumber,
      mobileNetwork: _user?.mobileNetwork,
      profileImageUrl: _user?.avatar,
      businessLogoUrl: _user?.businessLogo,
      idFrontUrl: _user?.idFrontPage,
      idBackUrl: _user?.idBackPage,
      profileImagePath: _profileImageFile?.path,
      businessLogoPath: _businessLogoFile?.path,
      idFrontPath: _idFrontFile?.path,
      idBackPath: _idBackFile?.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        backgroundColor: AppColors.white,
        title: 'Set up',
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) => previous.user != current.user,
          listener: (_, state) => _applyUser(state.user),
          builder: (context, state) {
            if (state.status == ProfileStatus.loading && !_didPrefill) {
              return const Center(child: CircularProgressIndicator());
            }

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
                      _ProgressCard(percentage: 0.6),
                      SizedBox(height: 2.2.h),
                      _AvatarAndLogoRow(
                        profileFile: _profileImageFile,
                        profileUrl: _user?.avatar,
                        businessFile: _businessLogoFile,
                        businessUrl: _user?.businessLogo,
                        onSelect: _pickImage,
                      ),
                      SizedBox(height: 2.2.h),
                      _FieldLabel('Name *'),
                      AppTextField(
                        controller: _nameCtrl,
                        hint: 'Ex. John Agblo',
                        leadingSvgAsset: 'assets/icons/name.svg',
                        textInputAction: TextInputAction.next,
                        compact: true,
                      ),
                      SizedBox(height: 1.6.h),
                      _FieldLabel('Business name'),
                      AppTextField(
                        controller: _businessNameCtrl,
                        hint: 'Add your business name?',
                        leadingSvgAsset: 'assets/icons/bag.svg',
                        textInputAction: TextInputAction.next,
                        compact: true,
                      ),
                      SizedBox(height: 1.6.h),
                      _FieldLabel('First number'),
                      AppTextField(
                        controller: _firstNumberCtrl,
                        hint: 'Number',
                        leadingSvgAsset: 'assets/icons/outgoing_call.svg',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        compact: true,
                      ),
                      SizedBox(height: 1.6.h),
                      _FieldLabel('Second number'),
                      AppTextField(
                        controller: _secondNumberCtrl,
                        hint: 'Number',
                        leadingSvgAsset: 'assets/icons/outgoing_call.svg',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        compact: true,
                      ),
                      SizedBox(height: 1.6.h),
                      _FieldLabel('Add national ID *'),
                      AppTextField(
                        controller: _nationalIdCtrl,
                        hint: 'ID number',
                        leadingSvgAsset: 'assets/icons/id.svg',
                        textInputAction: TextInputAction.next,
                        compact: true,
                      ),
                      SizedBox(height: 1.2.h),
                      _IDUploadPair(
                        frontFile: _idFrontFile,
                        frontUrl: _user?.idFrontPage,
                        backFile: _idBackFile,
                        backUrl: _user?.idBackPage,
                        onSelect: _pickImage,
                      ),
                      SizedBox(height: 2.2.h),
                      _VerifyEmailCard(
                        email: _user?.email ?? '—',
                      ),
                      SizedBox(height: 2.2.h),
                      CustomButton.filled(
                        label: 'Next',
                        onPressed: () => _goToPayment(context),
                        isPrimary: false,
                        backgroundColor: AppColors.white,
                        textStyle: AppTypography.body.copyWith(
                          color: AppColors.blueGray374957,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.percentage});
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: AppColors.grayD9.withValues(alpha: 0.35),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(height: 1.2.h),
          Text(
            'You are only ${(percentage * 100).round()}%',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.blueGray374957,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            'Complete your account to upload your first ad',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.blueGray374957,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarAndLogoRow extends StatelessWidget {
  const _AvatarAndLogoRow({
    required this.profileFile,
    required this.profileUrl,
    required this.businessFile,
    required this.businessUrl,
    required this.onSelect,
  });

  final File? profileFile;
  final String? profileUrl;
  final File? businessFile;
  final String? businessUrl;
  final void Function(_UploadTarget target) onSelect;

  @override
  Widget build(BuildContext context) {
    final bool hasProfileImage =
        profileFile != null || (profileUrl != null && profileUrl!.isNotEmpty);
    final bool hasBusinessLogo =
        businessFile != null || (businessUrl != null && businessUrl!.isNotEmpty);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _UploadCircle(
          label: hasProfileImage ? 'Replace' : 'Profile image',
          file: profileFile,
          imageUrl: profileUrl,
          onTap: () => onSelect(_UploadTarget.profile),
        ),
        _UploadCircle(
          label: hasBusinessLogo ? 'Replace' : 'Business logo',
          file: businessFile,
          imageUrl: businessUrl,
          onTap: () => onSelect(_UploadTarget.businessLogo),
        ),
      ],
    );
  }
}

class _UploadCircle extends StatelessWidget {
  const _UploadCircle({
    required this.label,
    required this.onTap,
    this.file,
    this.imageUrl,
  });
  final String label;
  final VoidCallback onTap;
  final File? file;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (file != null) {
      content = ClipOval(
        child: Image.file(
          file!,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
        ),
      );
    } else if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      String url = imageUrl!.trim();
      if (url.startsWith('/')) {
        final Uri baseUri = Uri.parse(AppStrings.baseUrl);
        final String origin = '${baseUri.scheme}://${baseUri.host}';
        url = '$origin$url';
      }
      content = ClipOval(
        child: Image.network(
          url,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => SvgPicture.asset(
            'assets/icons/upload.svg',
            width: 28,
            height: 28,
          ),
        ),
      );
    } else {
      content = SvgPicture.asset(
        'assets/icons/upload.svg',
        width: 28,
        height: 28,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
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
            child: content,
          ),
          SizedBox(height: 0.8.h),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
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

class _IDUploadPair extends StatelessWidget {
  const _IDUploadPair({
    required this.frontFile,
    required this.frontUrl,
    required this.backFile,
    required this.backUrl,
    required this.onSelect,
  });

  final File? frontFile;
  final String? frontUrl;
  final File? backFile;
  final String? backUrl;
  final void Function(_UploadTarget target) onSelect;

  @override
  Widget build(BuildContext context) {
    final bool hasFrontImage =
        frontFile != null || (frontUrl != null && frontUrl!.isNotEmpty);
    final bool hasBackImage =
        backFile != null || (backUrl != null && backUrl!.isNotEmpty);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SquareUpload(
          title: hasFrontImage ? 'Replace' : 'Front',
          size: 20.w,
          file: frontFile,
          imageUrl: frontUrl,
          onTap: () => onSelect(_UploadTarget.idFront),
        ),
        SizedBox(width: 3.w),
        _SquareUpload(
          title: hasBackImage ? 'Replace' : 'Back',
          size: 20.w,
          file: backFile,
          imageUrl: backUrl,
          onTap: () => onSelect(_UploadTarget.idBack),
        ),
      ],
    );
  }
}

class _SquareUpload extends StatelessWidget {
  const _SquareUpload({
    required this.title,
    required this.onTap,
    this.size,
    this.file,
    this.imageUrl,
  });
  final String title;
  final double? size;
  final VoidCallback onTap;
  final File? file;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final double boxSize = size ?? 26.w;
    Widget content;
    if (file != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          file!,
          fit: BoxFit.cover,
        ),
      );
    } else if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      String url = imageUrl!.trim();
      if (url.startsWith('/')) {
        final Uri baseUri = Uri.parse(AppStrings.baseUrl);
        final String origin = '${baseUri.scheme}://${baseUri.host}';
        url = '$origin$url';
      }
      content = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => SvgPicture.asset(
            'assets/icons/image.svg',
            width: 25,
            height: 25,
          ),
        ),
      );
    } else {
      content = Center(
        child: SvgPicture.asset(
          'assets/icons/image.svg',
          width: 25,
          height: 25,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0, bottom: 8),
          child: Text(title, style: AppTypography.bodySmall),
        ),
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: boxSize,
            height: boxSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.grayD9.withValues(alpha: 0.6)),
              ),
              child: content,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifyEmailCard extends StatelessWidget {
  const _VerifyEmailCard({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Please verify your email*',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.blueGray374957,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'We will send an email to $email\nClick the link in the email to verify your account',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.blueGray374957.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.6.h),
          CustomButton.capsule(
            label: 'Send link',
            onPressed: () {},
            filled: true,
            fillColor: AppColors.grayD9.withValues(alpha: 0.19),
            textStyle: AppTypography.body.copyWith(
              fontWeight: FontWeight.w500,
            ),
            width: 160,
            height: 44,
          ),
        ],
      ),
    );
  }
}

enum _UploadTarget { profile, businessLogo, idFront, idBack }
