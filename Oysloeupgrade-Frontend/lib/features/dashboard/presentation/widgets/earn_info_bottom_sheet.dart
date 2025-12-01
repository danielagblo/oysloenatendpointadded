import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class EarnInfoBottomSheet extends StatelessWidget {
  final String referralCode;

  const EarnInfoBottomSheet({super.key, required this.referralCode});

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
                  Text(
                    'We value friendship',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.gray222222.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Follow the steps below and get rewarded',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.blueGray374957.withValues(alpha: 0.54),
                    ),
                  ),
                  SizedBox(height: 3.2.h),
                  const _EarnStep(
                    step: 1,
                    title: 'Share your code',
                    icon: 'assets/icons/copy.svg',
                    isFirst: true,
                  ),
                  const _EarnStep(
                    step: 2,
                    title: 'Your friend adds the code',
                  ),
                  const _EarnStep(
                    step: 3,
                    title: 'Your friend places an order',
                    isLast: true,
                  ),
                  SizedBox(height: 2.6.h),
                  const _RewardItem(
                    icon: 'assets/icons/earn.svg',
                    title: 'You get',
                    subtitle: '50 Points',
                  ),
                  SizedBox(height: 1.8.h),
                  const _RewardItem(
                    icon: 'assets/icons/redeem.svg',
                    title: 'They get',
                    subtitle: 'Discount coupon 10% or 10 points',
                  ),
                  SizedBox(height: 3.4.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFBFBF).withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            referralCode,
                            style: AppTypography.bodyLarge.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 1.2.h),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Copy',
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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

class _EarnStep extends StatelessWidget {
  final int step;
  final String title;
  final String? icon;
  final bool isFirst;
  final bool isLast;

  const _EarnStep({
    required this.step,
    required this.title,
    this.icon,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const connectorColor = AppColors.blueGray374957;
    const circleSize = 38.0;
    final connectorSpacing = 2.6.h;
    final connectorTail = 1.6.h;
    final topConnector = isFirst ? connectorTail : connectorSpacing / 2;
    final bottomConnector = isLast ? connectorTail : connectorSpacing / 2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topConnector > 0)
              Container(
                width: 1,
                height: topConnector,
                color: connectorColor,
              ),
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: connectorColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: bottomConnector,
              color: connectorColor,
            ),
          ],
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 0.8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    color: AppColors.blueGray374957.withValues(alpha: 0.54),
                  ),
                ),
                if (icon != null) ...[
                  SizedBox(width: 2.w),
                  SvgPicture.asset(
                    icon!,
                    width: 15,
                    height: 15,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _RewardItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            color: AppColors.grayF9,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(icon, width: 20, height: 20),
        ),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.body.copyWith(
                fontSize: 14.sp,
                color: AppColors.blueGray374957.withValues(alpha: 0.54),
              ),
            ),
            SizedBox(height: 0.4.h),
            Text(
              subtitle,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
