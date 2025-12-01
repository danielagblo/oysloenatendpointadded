import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/constants/body_paddings.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _reportController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        title: 'Report',
        backgroundColor: AppColors.white,
      ),
      body: Padding(
        padding: BodyPaddings.horizontalPage,
        child: Column(
          children: [
            SizedBox(height: 3.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.grayF9,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.blueGray374957.withValues(alpha: 0.32),
                ),
              ),
              child: TextField(
                controller: _reportController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write report here',
                  hintStyle: AppTypography.body,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(4.w),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                style: AppTypography.body.copyWith(
                  color: AppColors.blueGray374957,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: CustomButton.filled(
                  label: 'Send Report',
                  backgroundColor: AppColors.white,
                  onPressed: () {}),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
