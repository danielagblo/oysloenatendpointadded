import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomBottomNavigation extends StatelessWidget {
  static const double barHeight = 78;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadAlertsCount;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadAlertsCount = 0,
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
                  badgeCount: unreadAlertsCount > 0 ? unreadAlertsCount : null,
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
    int? badgeCount,
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(iconPath, width: 20, height: 20),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: badgeCount > 9
                        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                        : const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B30), // Red color for badge
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
