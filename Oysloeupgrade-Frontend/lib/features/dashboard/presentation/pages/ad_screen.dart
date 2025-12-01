import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class AdScreen extends StatefulWidget {
  const AdScreen({super.key});

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _expandedAdId;

  final List<AdItem> _activeAds = [
    AdItem(
      id: '1',
      title: 'Mercedes Benz S CLASS 2023',
      price: '₵ 023,000',
      imageUrl: 'assets/images/ad1.jpg',
      clicks: 20,
      impressions: 2000,
    ),
    AdItem(
      id: '2',
      title: 'Mercedes Benz S CLASS 2023',
      price: '₵ 023,000',
      imageUrl: 'assets/images/ad2.jpg',
      clicks: 20,
      impressions: 2000,
    ),
  ];

  final List<AdItem> _pendingAds = [];
  final List<AdItem> _takenAds = [];
  final List<AdItem> _suspendedAds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _expandedAdId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleAdMenu(String adId) {
    setState(() {
      _expandedAdId = _expandedAdId == adId ? null : adId;
    });
  }

  void _handleMenuAction(String action, AdItem ad) {
    setState(() {
      _expandedAdId = null;
    });

    switch (action) {
      case 'taken':
        _markAsTaken(ad);
        break;
      case 'delete':
        _deleteAd(ad);
        break;
      case 'suspend':
        _suspendAd(ad);
        break;
    }
  }

  void _markAsTaken(AdItem ad) {
    debugPrint('Marking ad ${ad.id} as taken');
  }

  void _deleteAd(AdItem ad) {
    debugPrint('Deleting ad ${ad.id}');
  }

  void _suspendAd(AdItem ad) {
    debugPrint('Suspending ad ${ad.id}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedAdId = null;
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.grayF9,
        appBar: const CustomAppBar(
          backgroundColor: AppColors.white,
          title: 'Ads',
        ),
        body: Column(
          children: [
            SizedBox(height: 0.6.h),
            Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: _CustomTabBar(
                controller: _tabController,
                tabs: const ['Active', 'Pending', 'Taken', 'Suspended'],
                icons: const [
                  'assets/icons/active.svg',
                  'assets/icons/pending.svg',
                  'assets/icons/sold.svg',
                  'assets/icons/suspend.svg',
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAdList(_activeAds, 'Active'),
                  _buildAdList(_pendingAds, 'Pending'),
                  _buildAdList(_takenAds, 'Taken'),
                  _buildAdList(_suspendedAds, 'Suspended'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdList(List<AdItem> ads, String type) {
    if (ads.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 0.6.h),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        final isExpanded = _expandedAdId == ad.id;

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              _AdCard(
                ad: ad,
                isMenuExpanded: isExpanded,
                onMenuTap: () => _toggleAdMenu(ad.id),
                onCloseTap: () => setState(() => _expandedAdId = null),
              ),
              if (isExpanded)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isExpanded ? 1.0 : 0.0,
                  child: _HorizontalDropdownMenu(
                    onMarkAsTaken: () => _handleMenuAction('taken', ad),
                    onDelete: () => _handleMenuAction('delete', ad),
                    onSuspend: () => _handleMenuAction('suspend', ad),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/no_data.svg', height: 10.h),
          SizedBox(height: 2.h),
          Text(
            'No $type Ads',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.blueGray374957,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final List<String> icons;

  const _CustomTabBar({
    required this.controller,
    required this.tabs,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = controller.index == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.animateTo(index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 0.8.w),
                  padding:
                      EdgeInsets.symmetric(vertical: 2.5.w, horizontal: 1.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.grayF9,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        icons[index],
                        height: 15,
                        width: 15,
                      ),
                      SizedBox(width: 1.w),
                      Flexible(
                        child: Text(
                          tabs[index],
                          style: AppTypography.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _AdCard extends StatelessWidget {
  final AdItem ad;
  final bool isMenuExpanded;
  final VoidCallback onMenuTap;
  final VoidCallback onCloseTap;

  const _AdCard({
    required this.ad,
    required this.isMenuExpanded,
    required this.onMenuTap,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 0.6.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Ad Image
          Container(
            width: 80,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.grayD9.withValues(alpha: 0.3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                ad.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.grayD9.withValues(alpha: 0.3),
                    child: Icon(
                      Icons.image,
                      color: AppColors.blueGray374957.withValues(alpha: 0.5),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Ad Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row with tilde
                Row(
                  children: [
                    Text(
                      '~ ${ad.clicks} clicks',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.blueGray374957,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '~ ${_formatImpressions(ad.impressions)} impressions',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.blueGray374957,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 0.5.h),

                // Title
                Text(
                  ad.title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueGray374957,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 0.5.h),

                // Price
                Text(
                  ad.price,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueGray374957,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),

          // Menu Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.grayF9,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isMenuExpanded ? onCloseTap : onMenuTap,
              icon: Icon(
                isMenuExpanded ? Icons.close : Icons.more_vert,
                color: AppColors.blueGray374957,
                size: 19,
              ),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(25, 25),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatImpressions(int impressions) {
    if (impressions >= 1000) {
      return '${(impressions / 1000).toStringAsFixed(impressions % 1000 == 0 ? 0 : 1)}k';
    }
    return impressions.toString();
  }
}

class _HorizontalDropdownMenu extends StatelessWidget {
  final VoidCallback onMarkAsTaken;
  final VoidCallback onDelete;
  final VoidCallback onSuspend;

  const _HorizontalDropdownMenu({
    required this.onMarkAsTaken,
    required this.onDelete,
    required this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 0.6.h),
      padding: EdgeInsets.symmetric(vertical: 3.w, horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _MenuButton(
              text: 'Mark as taken',
              onTap: onMarkAsTaken,
            ),
          ),
          Expanded(
            child: _MenuButton(
              text: 'Delete ad',
              onTap: onDelete,
            ),
          ),
          Expanded(
            child: _MenuButton(
              text: 'Suspend',
              onTap: onSuspend,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _MenuButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.w),
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.blueGray374957.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
            fontSize: 12.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AdItem {
  final String id;
  final String title;
  final String price;
  final String imageUrl;
  final int clicks;
  final int impressions;

  AdItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.clicks,
    required this.impressions,
  });
}
