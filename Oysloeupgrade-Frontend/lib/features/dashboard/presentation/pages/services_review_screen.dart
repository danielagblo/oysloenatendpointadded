import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/models/service_application.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/step_indicator.dart';

class ServicesReviewScreen extends StatelessWidget {
  const ServicesReviewScreen({super.key, this.initial});
  final ServiceApplication? initial;

  @override
  Widget build(BuildContext context) {
    final app = initial;
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        title: 'Apply',
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              const StepIndicator(
                currentStep: 3,
                labels: ['Personal', 'Additional', 'Review'],
              ),
              SizedBox(height: 2.h),
              // Header
              Container(
                width: double.infinity,
                color: AppColors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Review your application',
                              style: AppTypography.body),
                          SizedBox(height: 4),
                          Text('Is your information correct?',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.gray8B959E)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.grayF9,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/editreview.svg',
                              width: 14,
                              height: 14,
                            ),
                            const SizedBox(width: 6),
                            Text('Edit',
                                style: AppTypography.bodySmall
                                    .copyWith(color: AppColors.blueGray374957)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 0.8.h),
              // Personal details
              Container(
                width: double.infinity,
                color: AppColors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal details', style: AppTypography.body),
                      SizedBox(height: 2.4.h),
                      _Field('Name', app?.name ?? ''),
                      SizedBox(height: 2.4.h),
                      _Field('Number', app?.phone ?? ''),
                      SizedBox(height: 2.4.h),
                      _Field('Email Address', app?.email ?? ''),
                      SizedBox(height: 2.4.h),
                      const Divider(),
                      SizedBox(height: 2.4.h),
                      _Field('Location', app?.location ?? ''),
                      SizedBox(height: 2.4.h),
                      _Field('Status', _statusText(app)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 0.8.h),
              // Additional information
              Container(
                width: double.infinity,
                color: AppColors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Additional information', style: AppTypography.body),
                      SizedBox(height: 2.4.h),
                      Text('Cover letter',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.blueGray374957)),
                      SizedBox(height: 8),
                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(minHeight: 80, maxHeight: 160),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            primary: false,
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              app?.coverLetter ?? '',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.gray8B959E),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.4.h),
                      Text('Resume',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.blueGray374957)),
                      SizedBox(height: 12),
                      if (app?.resume != null)
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.grayD9,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: SvgPicture.asset(
                                    'assets/icons/copy.svg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(app!.resume!.name,
                                    style: AppTypography.bodySmall.copyWith(
                                        color: const Color(0xFF646161))),
                                const SizedBox(height: 4),
                                Text(_sizeLabel(app.resume!.sizeBytes),
                                    style: AppTypography.bodySmall
                                        .copyWith(color: AppColors.gray8B959E)),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: CustomButton.filled(
                  label: 'Submit',
                  isPrimary: false,
                  backgroundColor: AppColors.white,
                  textColor: AppColors.blueGray374957,
                  onPressed: () {},
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusText(ServiceApplication? app) {
    if (app?.dob == null && app?.gender == null) return '';
    final age = app?.dob == null ? null : _age(app!.dob!);
    final g = app?.gender ?? '';
    if (age == null) return g;
    return '${age}yrs${g.isNotEmpty ? '-$g' : ''}';
  }

  static int _age(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  static String _sizeLabel(int sizeBytes) {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(0)}MB';
    }

    if (sizeBytes >= 1024) return '${(sizeBytes / 1024).toStringAsFixed(0)}KB';
    return '${sizeBytes}B';
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.body
                .copyWith(color: AppColors.blueGray374957, fontSize: 14.sp)),
        const SizedBox(height: 6),
        Text(value,
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.gray8B959E)),
      ],
    );
  }
}
