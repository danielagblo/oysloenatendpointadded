import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

class RatingOverview extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final List<RatingBreakdown> ratingBreakdown;
  final int selectedFilter;
  final Function(int)? onFilterChanged;
  final VoidCallback? onViewReviewsPressed;

  const RatingOverview({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.ratingBreakdown,
    this.selectedFilter = 0,
    this.onFilterChanged,
    this.onViewReviewsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Rating display
              Column(
                children: [
                  Text(
                    rating.toString(),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blueGray374957,
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(
                          rating.floor(),
                          (index) => Icon(
                                Icons.star,
                                color: AppColors.blueGray374957,
                                size: 16,
                              )),
                      if (rating % 1 != 0)
                        Icon(
                          Icons.star_half,
                          color: AppColors.blueGray374957,
                          size: 16,
                        ),
                      ...List.generate(
                          5 - rating.ceil(),
                          (index) => Icon(
                                Icons.star,
                                color: Colors.grey[300],
                                size: 16,
                              )),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$reviewCount Reviews',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 6.w),
              // Right side - Rating breakdown
              Expanded(
                child: Column(
                  children: [
                    ...ratingBreakdown.map((breakdown) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.blueGray374957,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${breakdown.stars}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.blueGray374957,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: breakdown.percentage / 100,
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.blueGray374957,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
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
          // Filter buttons
          Row(
            children: [
              Expanded(
                child: _ratingFilterChip('All'),
              ),
              SizedBox(width: 4),
              Expanded(
                child: _ratingFilterChip('1'),
              ),
              SizedBox(width: 4),
              Expanded(
                child: _ratingFilterChip('2'),
              ),
              SizedBox(width: 4),
              Expanded(
                child: _ratingFilterChip('3'),
              ),
              SizedBox(width: 4),
              Expanded(
                child: _ratingFilterChip('4'),
              ),
              SizedBox(width: 4),
              Expanded(
                child: _ratingFilterChip('5'),
              ),
            ],
          ),
          if (onViewReviewsPressed != null) ...[
            SizedBox(height: 3.h),
            Center(
              child: ElevatedButton(
                onPressed: onViewReviewsPressed,
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(40.w, 5.h),
                  backgroundColor: Color(0xFFF9F9F9),
                  foregroundColor: AppColors.grayD9,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Seller reviews',
                  style: AppTypography.body.copyWith(
                    color: AppColors.blueGray374957,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ratingFilterChip(String text) {
    return GestureDetector(
      onTap: () {
        if (onFilterChanged != null) {
          int filterIndex = text == 'All' ? 0 : int.parse(text);
          onFilterChanged!(filterIndex);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.grayF9,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 14,
              color: AppColors.blueGray374957,
            ),
            SizedBox(width: 4),
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
}

class RatingBreakdown {
  final int stars;
  final double percentage;

  const RatingBreakdown({
    required this.stars,
    required this.percentage,
  });
}

class RatingOverviewShimmer extends StatelessWidget {
  const RatingOverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grayE4,
      highlightColor: AppColors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left placeholder
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48.sp,
                      height: 28.sp,
                      decoration: BoxDecoration(
                        color: AppColors.grayE4,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.grayE4,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.grayE4,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 6.w),
                // Right placeholder - 5 rows of bars
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.grayE4,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 14,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.grayE4,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grayE4,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 28,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.grayE4,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            // Filter chips placeholders
            Row(
              children: List.generate(6, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.grayF9,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 3.h),
            // Button placeholder
            Center(
              child: Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.grayF9,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
