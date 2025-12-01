import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/input.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/multi_page_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/profile/profile_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/profile/profile_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/models/edit_profile_draft.dart';

import 'edit_profile_final_screen.dart';

class SetPaymentAccountScreen extends StatefulWidget {
  const SetPaymentAccountScreen({super.key, required this.initialDraft});

  final EditProfileDraft initialDraft;

  @override
  State<SetPaymentAccountScreen> createState() =>
      _SetPaymentAccountScreenState();
}

class _SetPaymentAccountScreenState extends State<SetPaymentAccountScreen> {
  final _accountNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _networkCtrl = TextEditingController();
  String? _selectedNetwork;
  late EditProfileDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialDraft;
    _accountNameCtrl.text = _draft.accountName ?? '';
    _accountNumberCtrl.text = _draft.accountNumber ?? '';
    _selectedNetwork = _draft.mobileNetwork;
    _networkCtrl.text = _selectedNetwork ?? '';
  }

  @override
  void dispose() {
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _networkCtrl.dispose();
    super.dispose();
  }

  Future<void> _showNetworkPicker() async {
    const options = ['MTN', 'Vodafone', 'AirtelTigo', 'Glo'];
    final String? selected = await showMultiPageBottomSheet<String>(
      context: context,
      rootPage: MultiPageSheetPage<String>(
        title: 'Mobile network',
        sections: [
          MultiPageSheetSection<String>(
            items: options
                .map(
                  (e) => MultiPageSheetItem<String>(label: e, value: e),
                )
                .toList(),
          ),
        ],
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedNetwork = selected;
        _networkCtrl.text = selected;
      });
    }
  }

  void _goToFinal(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final EditProfileDraft updated = _draft.copyWith(
      accountName: _accountNameCtrl.text.trim(),
      accountNumber: _accountNumberCtrl.text.trim(),
      mobileNetwork: _selectedNetwork,
    );
    _draft = updated;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: EditProfileFinalScreen(draft: updated),
        ),
      ),
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
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final horizontalPadding =
                    maxWidth > 600 ? (maxWidth - 560) / 2 : 5.w;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ProgressCard(percentage: 0.8),
                      SizedBox(height: 2.2.h),
                      Center(
                        child: Text(
                          'Set payment account',
                          style: AppTypography.body.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.2.h),
                      const _FieldLabel('Add account name'),
                      AppTextField(
                        controller: _accountNameCtrl,
                        hint: 'Account name',
                        leadingSvgAsset: 'assets/icons/account_name.svg',
                        textInputAction: TextInputAction.next,
                        compact: true,
                      ),
                      SizedBox(height: 1.6.h),
                      const _FieldLabel('Add account number'),
                      AppTextField(
                        controller: _accountNumberCtrl,
                        hint: 'Account number',
                        leadingSvgAsset: 'assets/icons/referral.svg',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        compact: true,
                      ),
                      SizedBox(height: 1.6.h),
                      const _FieldLabel('Mobile network'),
                      GestureDetector(
                        onTap: _showNetworkPicker,
                        child: AbsorbPointer(
                          child: AppTextField(
                            controller: _networkCtrl,
                            hint: 'Select mobile network',
                            leadingSvgAsset: 'assets/icons/mobile_network.svg',
                            textInputAction: TextInputAction.next,
                            compact: true,
                            trailingIcon: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.grayD9.withValues(alpha: 0.35),
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 15,
                                color: AppColors.blueGray374957,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Center(
                        child: TextButton(
                          onPressed: () => _goToFinal(context),
                          child: Text(
                            'Skip',
                            style: AppTypography.body.copyWith(
                              color: AppColors.blueGray374957,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.2.h),
                      CustomButton.filled(
                        label: 'Next',
                        onPressed: () => _goToFinal(context),
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
