import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/common/widgets/input.dart';
import 'package:oysloe_mobile/core/constants/body_paddings.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ReferralCodeScreen extends StatelessWidget {
  const ReferralCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.grayF9,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: BodyPaddings.horizontalPage,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 2.h,
            children: [
              AppTextField(
                hint: "Referral Code (Optional)",
                leadingSvgAsset: 'assets/icons/referral.svg',
                keyboardType: TextInputType.text,
              ),
              CustomButton.filled(
                label: 'Submit',
                isPrimary: true,
                onPressed: () {
                  context.go(AppRoutePaths.dashboardHome);
                },
              ),
              CustomButton.capsule(
                label: 'Skip',
                filled: true,
                height: 5.5.h,
                fillColor: AppColors.white,
                textStyle: AppTypography.body,
                trailingSvgAsset: 'assets/icons/arrow_right.svg',
                onPressed: () {
                  context.go(AppRoutePaths.dashboardHome);
                },
              ),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }
}
