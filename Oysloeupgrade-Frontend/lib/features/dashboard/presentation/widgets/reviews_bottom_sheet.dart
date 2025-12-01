import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ReviewsBottomSheet extends StatefulWidget {
  final double rating;
  final int reviewCount;
  final List<RatingBreakdown> ratingBreakdown;
  final List<ReviewComment> reviews;
  final int initialFilter;
  final int productId;

  const ReviewsBottomSheet({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.ratingBreakdown,
    required this.reviews,
    this.initialFilter = 0,
    required this.productId,
  });

  @override
  State<ReviewsBottomSheet> createState() => _ReviewsBottomSheetState();
}

class _ReviewsBottomSheetState extends State<ReviewsBottomSheet> {
  late int selectedFilter;
  List<ReviewComment> filteredReviews = [];
  double _currentHeight = 60.0;
  final double _minHeight = 60.0;
  final double _maxHeight = 80.0;
  final double _closeThreshold = 40.0;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
    _filterReviews();
  }

  void _filterReviews() {
    if (selectedFilter == 0) {
      filteredReviews = widget.reviews;
    } else {
      filteredReviews = widget.reviews
          .where((review) => review.rating == selectedFilter)
          .toList();
    }
  }

  Future<void> _handleReviewAction({ReviewComment? editTarget}) async {
    final repository = sl<AuthRepository>();
    final session = await repository.cachedSession();
    final bool isLoggedIn = session != null;
    if (!mounted) return;
    if (!isLoggedIn) {
      showErrorSnackBar(context, 'Please log in to continue.');
      context.go(AppRoutePaths.login);
      return;
    }

    if (widget.productId <= 0) {
      showErrorSnackBar(context, 'Unable to identify this product.');
      return;
    }

    final Map<String, dynamic> extras = <String, dynamic>{
      'productId': widget.productId,
    };

    if (editTarget != null && editTarget.id > 0) {
      extras['reviewId'] = editTarget.id;
      extras['rating'] = editTarget.rating;
      if (editTarget.rawComment != null) {
        extras['comment'] = editTarget.rawComment;
      }
    }

    if (!mounted) return;
    final bool? submitted = await context.pushNamed<bool>(
      AppRouteNames.dashboardReviews,
      extra: extras,
    );
    if (!mounted) return;

    if (!mounted) return;

    if (submitted == true) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onFilterChanged(int filterIndex) {
    setState(() {
      selectedFilter = filterIndex;
      _filterReviews();
    });
  }

  Widget _ratingFilterChip(String text, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        final filterIndex = text == 'All' ? 0 : int.parse(text);
        _onFilterChanged(filterIndex);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: isSelected
              ? Border.all(color: AppColors.blueGray374957, width: 2)
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 14,
              color: AppColors.blueGray374957,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(ReviewComment review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(review),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.date,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.blueGray374957.withValues(alpha: 0.7),
                        fontSize: 13.sp,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.userName,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          review.rating,
                          (index) => const Icon(
                            Icons.star,
                            color: AppColors.blueGray374957,
                            size: 12,
                          ),
                        ),
                        ...List.generate(
                          5 - review.rating,
                          (index) => Icon(
                            Icons.star,
                            color: Colors.grey[300],
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (review.canEdit) ...[
                    GestureDetector(
                      onTap: () => _handleReviewAction(editTarget: review),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/editreview.svg',
                              width: 12,
                              height: 12,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Edit',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/like.svg',
                          width: 12,
                          height: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Like',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    review.likes.toString(),
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ReviewComment review) {
    final raw = review.userImage?.trim();

    if (raw == null || raw.isEmpty) {
      return ClipRRect(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.grayE4,
            borderRadius: BorderRadius.circular(8),
          ),
          width: 48,
          height: 48,
          child: SvgPicture.asset(
            'assets/icons/bk_logo.svg',
            width: 20,
            height: 20,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final isUrl = raw.startsWith('http://') || raw.startsWith('https://');
    final isSvg = raw.toLowerCase().endsWith('.svg');

    if (isUrl && isSvg) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SvgPicture.network(
          raw,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }

    if (isUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          raw,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }

    if (isSvg) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SvgPicture.asset(
          raw,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        raw,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildEmptyState() {
    final scaleFactor = (_currentHeight / _minHeight).clamp(0.5, 1.0);
    final iconSize = (60 * scaleFactor).clamp(40.0, 80.0);
    final spacing = (1.5 * scaleFactor).clamp(0.5, 2.0);
    final fontSize = (14 * scaleFactor).clamp(10.0, 16.0);

    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/no_data.svg',
              width: iconSize,
              height: iconSize,
            ),
            SizedBox(height: spacing.h),
            Text(
              'No reviews yet',
              style: AppTypography.body.copyWith(
                color: Colors.grey[600],
                fontSize: fontSize.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight * (_currentHeight / 100);

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          final deltaY = -details.delta.dy;
          final deltaPercentage = (deltaY / screenHeight) * 200;
          _currentHeight = (_currentHeight + deltaPercentage)
              .clamp(_closeThreshold, _maxHeight);
        });
      },
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond.dy;
        if (_currentHeight <= _closeThreshold || velocity > 800) {
          Navigator.of(context).pop();
          return;
        }
        setState(() {
          if (velocity < -500) {
            _currentHeight = _maxHeight;
          } else if (velocity > 500) {
            _currentHeight = _minHeight;
          } else {
            final midPoint = (_minHeight + _maxHeight) / 2;
            _currentHeight =
                _currentHeight > midPoint ? _maxHeight : _minHeight;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: modalHeight,
        decoration: const BoxDecoration(
          color: AppColors.grayF9,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(
                            widget.rating.toString(),
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blueGray374957,
                            ),
                          ),
                          Row(
                            children: [
                              ...List.generate(
                                widget.rating.floor(),
                                (index) => const Icon(
                                  Icons.star,
                                  color: AppColors.blueGray374957,
                                  size: 16,
                                ),
                              ),
                              if (widget.rating % 1 != 0)
                                const Icon(
                                  Icons.star_half,
                                  color: AppColors.blueGray374957,
                                  size: 16,
                                ),
                              ...List.generate(
                                5 - widget.rating.ceil(),
                                (index) => Icon(
                                  Icons.star,
                                  color: Colors.grey[300],
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.reviewCount} Reviews',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Column(
                          children: [
                            ...widget.ratingBreakdown.map((breakdown) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: AppColors.blueGray374957,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${breakdown.stars}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.blueGray374957,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor:
                                                breakdown.percentage / 100,
                                            child: Container(
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: AppColors.blueGray374957,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 30,
                                      child: Text(
                                        '${breakdown.percentage.round()}%',
                                        style: AppTypography.bodySmall,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: _ratingFilterChip('All',
                            isSelected: selectedFilter == 0),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _ratingFilterChip('1',
                            isSelected: selectedFilter == 1),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _ratingFilterChip('2',
                            isSelected: selectedFilter == 2),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _ratingFilterChip('3',
                            isSelected: selectedFilter == 3),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _ratingFilterChip('4',
                            isSelected: selectedFilter == 4),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _ratingFilterChip('5',
                            isSelected: selectedFilter == 5),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Comments',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _handleReviewAction(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/editreview.svg',
                                width: 14,
                                height: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Make review',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
            Expanded(
              child: filteredReviews.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredReviews.length,
                      itemBuilder: (context, index) {
                        return _buildReviewItem(filteredReviews[index]);
                      },
                    ),
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }
}

class RatingBreakdown {
  final int stars;
  final double percentage;

  const RatingBreakdown({
    required this.stars,
    required this.percentage,
  });
}

class ReviewComment {
  final int id;
  final String userName;
  final String? userImage;
  final int rating;
  final String comment;
  final String? rawComment;
  final String date;
  final int likes;
  final bool canEdit;

  const ReviewComment({
    required this.id,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    this.rawComment,
    required this.date,
    this.likes = 0,
    this.canEdit = false,
  });
}
