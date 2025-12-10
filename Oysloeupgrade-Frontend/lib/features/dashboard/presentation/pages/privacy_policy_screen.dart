import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/usecase/usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/static_page_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/static_pages_usecases.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  StaticPageEntity? _page;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final useCase = sl<GetPrivacyPolicyUseCase>();
    final result = await useCase(const NoParams());

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message.isEmpty
              ? 'Unable to load privacy policy right now.'
              : failure.message;
          _isLoading = false;
        });
      },
      (page) {
        setState(() {
          _page = page;
          if (_page?.content.trim().isEmpty ?? true) {
            _page = null;
          }
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fallbackContent = '''
We value your privacy. This policy explains what information we collect, how we use it, and how you can manage your data. Please check back for updates.
''';

    final displayContent = _page?.content ?? fallbackContent;
    final dateText = _page?.updatedAt != null
        ? 'Updated: ${_page!.updatedAt!.toLocal().toString().split(' ').first}'
        : null;

    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        title: 'Privacy Policy',
        backgroundColor: AppColors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange.shade700, size: 20),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              _error!,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadContent,
                            child: Text(
                              'Retry',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                  Text(
                    'Privacy Policy',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueGray374957,
                      fontSize: 18.sp,
                    ),
                  ),
                  if (dateText != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      dateText,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.blueGray374957.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  SizedBox(height: 1.2.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        displayContent,
                        style: AppTypography.body.copyWith(
                          color: AppColors.blueGray374957.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}