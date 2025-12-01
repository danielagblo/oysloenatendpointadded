import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class LevelInfoBottomSheet extends StatelessWidget {
  const LevelInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final tiers = [
      const _LevelTierCard(
        title: 'Silver',
        subtitle: '10 points to gold',
        progress: 0.12,
      ),
      const _LevelTierCard(
        title: 'Gold',
        subtitle: '100,000 points to gold',
        progress: 0.6,
      ),
      const _LevelTierCard(
        title: 'Diamond',
        subtitle: '1,000,000 points to diamond',
        progress: 1.0,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grayF9,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
              padding: EdgeInsets.fromLTRB(4.5.w, 3.2.h, 4.5.w, 2.4.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < tiers.length; i++) ...[
                    tiers[i],
                    if (i != tiers.length - 1) SizedBox(height: 1.h),
                  ],
                  SizedBox(height: 3.h),
                  Text(
                    'Your earning levels also helps us to rank you.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.blueGray374957.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTierCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;

  const _LevelTierCard({
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.blueGray374957.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.6.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final progressWidth = barWidth * clampedProgress;
              const barHeight = 8.0;

              return Stack(
                children: [
                  Container(
                    width: barWidth,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: (barHeight - 6) / 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Container(
                    width: progressWidth,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.75),
                          AppColors.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
