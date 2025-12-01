import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        title: 'Privacy Policy',
        backgroundColor: AppColors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.blueGray374957,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Dated: 23-3-2025',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.blueGray374957.withValues(alpha: 0.6),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}