import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/create_review_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/update_review_usecase.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({
    super.key,
    required this.productId,
    this.reviewId,
    this.initialRating,
    this.initialComment,
  });

  final int productId;
  final int? reviewId;
  final int? initialRating;
  final String? initialComment;

  bool get isEditing => reviewId != null;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late int _selectedRating;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  final List<String> _ratingLabels = [
    'Poor',
    'Average',
    'Good',
    'Very Good',
    'Excellent',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating ?? 0;
    _commentController.text = widget.initialComment ?? '';
  }

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

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.isEditing;
    final String headlineText = isEditing ? 'Edit Review' : 'Review';
    final String subtitleText =
        isEditing ? 'Update your review' : 'Make a review';
    final String buttonLabel = isEditing ? 'Update Review' : 'Send Review';

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
                          headlineText,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.blueGray374957,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          subtitleText,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/shield_info.svg',
                              width: 16,
                              height: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Reviews are verified before seen public',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
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
                            minLines: 2,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
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
                              fontSize: 15.sp,
                              color: AppColors.blueGray374957,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton.filled(
                            label: buttonLabel,
                            backgroundColor: AppColors.white,
                            isLoading: _submitting,
                            onPressed: _submitting
                                ? null
                                : () async {
                                    if (_selectedRating <= 0) {
                                      showErrorSnackBar(
                                        context,
                                        'Please select a rating to submit.',
                                      );
                                      return;
                                    }

                                    final String trimmedComment =
                                        _commentController.text.trim();
                                    final String? commentPayload =
                                        trimmedComment.isNotEmpty
                                            ? trimmedComment
                                            : null;
                                    final bool isEditing = widget.isEditing;

                                    setState(() => _submitting = true);
                                    final result = isEditing &&
                                            widget.reviewId != null
                                        ? await sl<UpdateReviewUseCase>()(
                                            UpdateReviewParams(
                                              reviewId: widget.reviewId!,
                                              rating: _selectedRating,
                                              comment: commentPayload,
                                            ),
                                          )
                                        : await sl<CreateReviewUseCase>()(
                                            CreateReviewParams(
                                              productId: widget.productId,
                                              rating: _selectedRating,
                                              comment: commentPayload,
                                            ),
                                          );

                                    if (!mounted) return;

                                    result.fold(
                                      (failure) {
                                        final String fallbackError = isEditing
                                            ? 'Unable to update review.'
                                            : 'Unable to submit review.';
                                        final message = failure.message.isEmpty
                                            ? fallbackError
                                            : failure.message;
                                        showErrorSnackBar(context, message);
                                        setState(() => _submitting = false);
                                      },
                                      (_) async {
                                        final successMessage = isEditing
                                            ? 'Review updated.'
                                            : 'Review submitted.';
                                        showSuccessSnackBar(
                                          context,
                                          successMessage,
                                        );
                                        Navigator.of(context).pop(true);
                                      },
                                    );
                                  },
                          ),
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
