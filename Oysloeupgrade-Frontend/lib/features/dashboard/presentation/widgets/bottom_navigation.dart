import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomBottomNavigation extends StatelessWidget {
  static const double barHeight = 78;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: AppColors.blueGray374957.withValues(alpha: 0.08),
            width: 0.7,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: 1.8.h),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  iconPath: 'assets/icons/home.svg',
                  label: 'Home',
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  iconPath: 'assets/icons/alert.svg',
                  label: 'Alerts',
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  iconPath: 'assets/icons/Post.svg',
                  label: 'Post Ad',
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  iconPath: 'assets/icons/inbox.svg',
                  label: 'Inbox',
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  iconPath: 'assets/icons/profile.svg',
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String iconPath,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 5,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.blueGray374957 : Colors.transparent,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 3),
          SvgPicture.asset(iconPath, width: 20, height: 20),
          const SizedBox(height: 3),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
