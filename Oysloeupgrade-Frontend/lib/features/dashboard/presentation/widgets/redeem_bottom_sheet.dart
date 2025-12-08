import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/referral_usecases.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RedeemBottomSheet extends StatefulWidget {
  const RedeemBottomSheet({super.key});

  @override
  State<RedeemBottomSheet> createState() => _RedeemBottomSheetState();
}

class _RedeemBottomSheetState extends State<RedeemBottomSheet> {
  final TextEditingController _codeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleRedeem() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      showErrorSnackBar(context, 'Please enter a coupon code');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    FocusScope.of(context).unfocus();

    final redeemCouponUseCase = sl<RedeemCouponUseCase>();
    final result = await redeemCouponUseCase(RedeemCouponParams(code: code));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    result.fold(
      (failure) => showErrorSnackBar(
        context,
        failure.message.isEmpty
            ? 'Unable to redeem coupon. Please try again.'
            : failure.message,
      ),
      (_) {
        showSuccessSnackBar(context, 'Coupon redeemed successfully!');
        _codeController.clear();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grayF9,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.6.h),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayD9,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(6.w, 3.2.h, 6.w, 2.4.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/redeem.svg',
                          width: 24, height: 24),
                      SizedBox(width: 2.4.w),
                      Text(
                        'Apply coupon',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.gray222222.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.4.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.blueGray374957.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Get Cash equivalent',
                              style: AppTypography.body.copyWith(
                                color: AppColors.blueGray374957
                                    .withValues(alpha: 0.54),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '¢0',
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.2.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grayF9,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _codeController,
                                  decoration: InputDecoration(
                                    hintText: 'Add code here',
                                    hintStyle: AppTypography.body.copyWith(
                                      color: AppColors.blueGray374957
                                          .withValues(alpha: 0.6),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: AppTypography.body,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              GestureDetector(
                                onTap: _isSubmitting ? null : _handleRedeem,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.w,
                                    vertical: 1.2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.grayD9
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppColors.blueGray374957,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Apply',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.6.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
