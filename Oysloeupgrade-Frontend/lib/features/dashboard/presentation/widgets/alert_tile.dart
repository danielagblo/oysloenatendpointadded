import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/alert_entity.dart';

class AlertTile extends StatelessWidget {
  const AlertTile({
    super.key,
    required this.alert,
    required this.timeLabel,
    required this.isExpanded,
    required this.onTap,
    required this.onDelete,
    required this.onMarkRead,
  });

  final AlertEntity alert;
  final String timeLabel;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = alert.isRead
        ? AppColors.blueGray374957.withValues(alpha: 0.5)
        : AppColors.blueGray374957;

    return Slidable(
      key: ValueKey<int>(alert.id),
      groupTag: 'alerts',
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: alert.isRead ? 0.26 : 0.5,
        children: [
          if (!alert.isRead)
            CustomSlidableAction(
              onPressed: (_) => onMarkRead(),
              backgroundColor: AppColors.gray8B959E,
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.white,
              ),
            ),
          CustomSlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.redFF6B6B,
            child: const Icon(
              Icons.delete,
              color: AppColors.white,
            ),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(
                color: AppColors.grayD9.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isExpanded) ...[
                      Text(
                        alert.title,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        alert.body,
                        style: AppTypography.body.copyWith(
                          color: AppColors.blueGray374957,
                          fontSize: 14.sp,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        timeLabel,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray8B959E,
                          fontSize: 12.sp,
                        ),
                      ),
                    ] else ...[
                      Text(
                        timeLabel,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray8B959E,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${alert.title} ',
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                                fontSize: 14.sp,
                              ),
                            ),
                            TextSpan(
                              text: alert.body,
                              style: AppTypography.body.copyWith(
                                color: AppColors.blueGray374957,
                                fontSize: 14.sp,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!alert.isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Opacity(
        opacity: alert.isRead ? 0.5 : 1.0,
        child: SvgPicture.asset(
          'assets/icons/bk_logo.svg',
          width: 32,
          height: 32,
        ),
      ),
    );
  }
}
