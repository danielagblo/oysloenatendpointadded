import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: CustomAppBar(
        backgroundColor: AppColors.white,
        title: 'Inbox',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTabBar(),
            selectedTab == 0 ? _buildChatTab() : _buildSupportTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Chat',
              isSelected: selectedTab == 0,
              unreadCount: 9,
              onTap: () => setState(() => selectedTab = 0),
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: _buildTabButton(
              title: 'Support',
              isSelected: selectedTab == 1,
              unreadCount: 0,
              isActive: true,
              onTap: () => setState(() => selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    int unreadCount = 0,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grayF9,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              title == 'Chat'
                  ? 'assets/icons/quick_chat.svg'
                  : 'assets/icons/support.svg',
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                AppColors.blueGray374957,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueGray374957,
                    fontSize: 14.sp,
                  ),
                ),
                if (unreadCount > 0) ...[
                  SizedBox(height: 2),
                  Text(
                    '$unreadCount unread',
                    style: AppTypography.bodySmall.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.blueGray374957.withValues(alpha: 0.7)),
                  ),
                ],
                if (isActive && unreadCount == 0) ...[
                  SizedBox(height: 2),
                  Text(
                    '14 active',
                    style: AppTypography.bodySmall.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.blueGray374957.withValues(alpha: 0.7)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    // bool hasChats = true;

    // if (!hasChats) {
    //   return _buildEmptyState();
    // }

    return Column(
      children: [
        _buildChatItem(
          chatId: 'chat_1',
          name: 'iphone 14 pro max',
          message: 'is the iphone 15 pro max  today...',
          time: 'today',
          avatar: 'assets/images/ad5.jpg',
          isUnread: true,
          isClosed: true,
        ),
        _buildChatItem(
          chatId: 'chat_2',
          name: 'iphone 14 pro max',
          message: 'is the iphone 15 pro max  today...',
          time: 'today',
          avatar: 'assets/images/ad5.jpg',
          isUnread: true,
          isClosed: false,
        ),
        _buildChatItem(
          chatId: 'chat_3',
          name: 'iphone 14 pro max',
          message: 'is the iphone 15 pro max  today...',
          time: 'today',
          avatar: 'assets/images/ad5.jpg',
          isUnread: true,
          isClosed: false,
        ),
        _buildChatItem(
          chatId: 'chat_4',
          name: 'iphone 14 pro max',
          message: 'is the iphone 15 pro max  today...',
          time: 'today',
          avatar: 'assets/images/ad5.jpg',
          isUnread: false,
          isClosed: false,
        ),
      ],
    );
  }

  Widget _buildSupportTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, top: 2.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get Help Anytime',
                style: AppTypography.body.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blueGray374957,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'If you are facing an issue,send us a report,we will respond to you immediately.Our support is active 24/7.',
                style: AppTypography.body.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.gray8B959E,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add case',
                  style: AppTypography.body.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueGray374957,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.blueGray374957,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 3.h),
          child: Text(
            'Open Case',
            style: AppTypography.body.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blueGray374957,
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildSupportCases(),
      ],
    );
  }

  Widget _buildSupportCases() {
    // bool hasCases = true;

    // if (!hasCases) {
    //   return _buildEmptyState();
    // }

    return Column(
      children: [
        _buildSupportCase(
          date: 'Aug 21, 2025',
          caseId: 'Support: S678432',
          status: 'Active',
          statusColor: AppColors.primary,
          isUnread: true,
        ),
        _buildSupportCase(
          date: 'Aug 21, 2025',
          caseId: 'Support: S678432',
          status: 'Active',
          statusColor: AppColors.primary,
          isUnread: false,
        ),
        _buildSupportCase(
          date: 'Aug 21, 2025',
          caseId: 'Support: S678432',
          status: 'Closed',
          statusColor: AppColors.redFF6B6B,
          isUnread: false,
        ),
      ],
    );
  }

  Widget _buildChatItem({
    required String chatId,
    required String name,
    required String message,
    required String time,
    required String avatar,
    bool isUnread = false,
    bool isClosed = false,
  }) {
    return GestureDetector(
      onTap: () {
        // Only navigate if the chat is not closed
        if (!isClosed) {
          context.pushNamed(
            AppRouteNames.dashboardChat,
            pathParameters: {'chatId': chatId},
            extra: {
              'otherUserName': name,
              'otherUserAvatar': avatar,
            },
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : AppColors.grayF9,
        ),
        child: Row(
          children: [
            Container(
              width: 6.8.h,
              height: 6.h,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: AssetImage(avatar),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10)),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueGray374957,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  if (isClosed)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: AppColors.redFF6B6B,
                      ),
                      child: Text(
                        'Closed',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    )
                  else
                    Text(
                      message,
                      style: AppTypography.bodySmall.copyWith(
                        color: isUnread
                            ? AppColors.blueGray374957
                            : AppColors.gray8B959E,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCase({
    required String date,
    required String caseId,
    required String status,
    required Color statusColor,
    bool isUnread = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : AppColors.grayF9,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grayD9.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray8B959E,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4),
          Text(
            caseId,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: AppColors.blueGray374957,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
            ),
            child: Text(
              status,
              style: AppTypography.bodySmall.copyWith(
                color: status == 'Active'
                    ? AppColors.blueGray374957
                    : AppColors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildEmptyState() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         SvgPicture.asset(
  //           'assets/icons/no_data.svg',
  //           width: 80,
  //           height: 80,
  //         ),
  //         SizedBox(height: 16),
  //         Text(
  //           'No data to show',
  //           style: AppTypography.body.copyWith(
  //             fontSize: 16.sp,
  //             fontWeight: FontWeight.w600,
  //             color: AppColors.blueGray374957,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
