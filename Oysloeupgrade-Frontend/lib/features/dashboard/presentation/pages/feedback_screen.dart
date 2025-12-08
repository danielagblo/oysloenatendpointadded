import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/get_product_detail_usecase.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _ratingLabels = [
    'Poor',
    'Average',
    'Good',
    'Very Good',
    'Excellent',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onStarTap(int rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  Future<void> _handleSubmit() async {
    if (_selectedRating == 0) {
      showErrorSnackBar(context, 'Please select a rating before submitting.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final SubmitFeedbackUseCase useCase = sl<SubmitFeedbackUseCase>();
    final result = await useCase(
      SubmitFeedbackParams(
        rating: _selectedRating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    result.fold(
      (failure) => showErrorSnackBar(
        context,
        failure.message.isEmpty
            ? 'Unable to submit feedback. Please try again.'
            : failure.message,
      ),
      (_) {
        showSuccessSnackBar(
          context,
          'Thank you for your feedback! We appreciate your input.',
        );
        // Clear the form
        setState(() {
          _selectedRating = 0;
          _commentController.clear();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        title: 'Feedback',
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Column(
                      children: [
                        SizedBox(height: 5.h),
                        Text(
                          'Feedback',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.blueGray374957,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Help us improve on our app',
                          style: AppTypography.body.copyWith(
                            color:
                                AppColors.blueGray374957.withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starIndex = index + 1;
                            final isSelected = starIndex <= _selectedRating;

                            return GestureDetector(
                              onTap: () => _onStarTap(starIndex),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                child: Icon(
                                  Icons.star,
                                  size: 35,
                                  color: isSelected
                                      ? AppColors.blueGray374957
                                      : AppColors.grayD9,
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                          height: 3.h,
                          child: _selectedRating > 0
                              ? Text(
                                  _ratingLabels[_selectedRating - 1],
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.blueGray374957
                                        .withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.grayF9,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.blueGray374957
                                  .withValues(alpha: 0.32),
                            ),
                          ),
                          child: TextField(
                            controller: _commentController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Comment',
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
                              label: 'Send Feedback',
                              backgroundColor: AppColors.white,
                              isLoading: _isSubmitting,
                              onPressed: _isSubmitting ? null : _handleSubmit),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
