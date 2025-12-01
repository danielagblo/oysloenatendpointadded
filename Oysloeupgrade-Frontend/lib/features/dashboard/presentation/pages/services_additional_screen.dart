import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/models/service_application.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/ad_input.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/step_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ServicesAdditionalScreen extends StatefulWidget {
  const ServicesAdditionalScreen({super.key, this.initial});

  final ServiceApplication? initial;

  @override
  State<ServicesAdditionalScreen> createState() =>
      _ServicesAdditionalScreenState();
}

class _ServicesAdditionalScreenState extends State<ServicesAdditionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _coverLetterController = TextEditingController();

  // Simple in-memory picked file representation
  File? _resumeFile;
  String? _resumeName;
  int? _resumeSizeBytes;
  ServiceApplication? _incoming;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _incoming ??= widget.initial;
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: CustomAppBar(
        title: 'Apply',
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                const StepIndicator(
                  currentStep: 2,
                  labels: ['Personal', 'Additional', 'Review'],
                ),
                SizedBox(height: 2.h),
                // Section: Cover Letter
                Container(
                  width: double.infinity,
                  color: AppColors.white,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal details',
                          style: AppTypography.body,
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          'In order to match you for the right job opportunities we need some more details',
                          style: AppTypography.body.copyWith(
                            color: AppColors.blueGray374957
                                .withValues(alpha: 0.54),
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text('Cover Letter',
                            style: AppTypography.bodySmall
                                .copyWith(fontSize: 15.sp)),
                        SizedBox(height: 1.h),
                        AdInput(
                          controller: _coverLetterController,
                          maxLines: 8,
                          hintText: 'My name is azor.....',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 0.8.h),
                // Section: Resume upload
                Container(
                  width: double.infinity,
                  color: AppColors.white,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resume',
                          style:
                              AppTypography.bodySmall.copyWith(fontSize: 15.sp),
                        ),
                        SizedBox(height: 2.h),
                        if (_resumeFile != null) ...[
                          _ResumeTile(
                            fileName: _resumeName ?? 'resume',
                            sizeBytes: _resumeSizeBytes ?? 0,
                            onRemove: () => setState(() {
                              _resumeFile = null;
                              _resumeName = null;
                              _resumeSizeBytes = null;
                            }),
                          ),
                          const Divider(height: 32),
                        ],
                        _AddFileTile(onTap: _pickResume),
                        const Divider(height: 32),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: CustomButton.filled(
                    label: 'Next',
                    isPrimary: false,
                    backgroundColor: AppColors.white,
                    textColor: AppColors.blueGray374957,
                    onPressed: _onNext,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickResume() async {
    // Placeholder picker
    setState(() {
      _resumeFile = File('dummy');
      _resumeName = 'M-fill certificate.pdf';
      _resumeSizeBytes = 2 * 1024 * 1024; // 2MB
    });
  }

  void _onNext() {
    final updated = (_incoming ??
            const ServiceApplication(
                name: '', phone: '', email: '', location: ''))
        .copyWith(
      coverLetter: _coverLetterController.text.trim().isEmpty
          ? null
          : _coverLetterController.text.trim(),
      resume: _resumeName == null
          ? null
          : ResumeFileInfo(
              name: _resumeName!, sizeBytes: _resumeSizeBytes ?? 0),
    );
    GoRouter.of(context)
        .pushNamed(AppRouteNames.dashboardServicesReview, extra: updated);
  }
}

class _AddFileTile extends StatelessWidget {
  const _AddFileTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: Image.asset('assets/icons/add_item.png'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add File',
                  style: AppTypography.body.copyWith(
                    color: AppColors.blueGray374957,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Max file size 10MB(pdf,doc,docx)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray8B959E,
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

class _ResumeTile extends StatelessWidget {
  const _ResumeTile({
    required this.fileName,
    required this.sizeBytes,
    required this.onRemove,
  });

  final String fileName;
  final int sizeBytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    String fileSizeLabel;
    if (sizeBytes >= 1024 * 1024) {
      fileSizeLabel = '${(sizeBytes / (1024 * 1024)).toStringAsFixed(0)}MB';
    } else if (sizeBytes >= 1024) {
      fileSizeLabel = '${(sizeBytes / 1024).toStringAsFixed(0)}KB';
    } else {
      fileSizeLabel = '${sizeBytes}B';
    }

    return Column(
      children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: AppTypography.bodySmall.copyWith(
                      color: Color(0xFF646161),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileSizeLabel,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray8B959E,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 35,
              height: 35,
              child: IconButton(
                onPressed: onRemove,
                icon: Image.asset('assets/icons/delete_icon.png'),
                tooltip: 'Remove',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
