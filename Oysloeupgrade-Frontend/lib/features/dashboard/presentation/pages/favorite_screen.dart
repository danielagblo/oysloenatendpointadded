import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final List<FavoriteItem> _favoriteItems = [
    FavoriteItem(
      id: '1',
      title: 'Mercedes Benz S CLASS 2023',
      price: '₵ 023,000',
      imageUrl: 'assets/images/ad1.jpg',
      isFavorite: true,
    ),
    FavoriteItem(
      id: '2',
      title: 'Mercedes Benz S CLASS 2023',
      price: '₵ 023,000',
      imageUrl: 'assets/images/ad2.jpg',
      isFavorite: true,
    ),
    FavoriteItem(
      id: '3',
      title: 'Mercedes Benz S CLASS 2023',
      price: '₵ 023,000',
      imageUrl: 'assets/images/ad3.jpg',
      isFavorite: true,
    ),
  ];

  void _toggleFavorite(String itemId) {
    setState(() {
      final index = _favoriteItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _favoriteItems[index] = FavoriteItem(
          id: _favoriteItems[index].id,
          title: _favoriteItems[index].title,
          price: _favoriteItems[index].price,
          imageUrl: _favoriteItems[index].imageUrl,
          isFavorite: !_favoriteItems[index].isFavorite,
        );

        if (!_favoriteItems[index].isFavorite) {
          _favoriteItems.removeAt(index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        backgroundColor: AppColors.white,
        title: 'Favorite',
      ),
      body: _favoriteItems.isEmpty ? _buildEmptyState() : _buildFavoriteList(),
    );
  }

  Widget _buildFavoriteList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      itemCount: _favoriteItems.length,
      itemBuilder: (context, index) {
        final item = _favoriteItems[index];

        return _FavoriteCard(
          item: item,
          onFavoriteTap: () => _toggleFavorite(item.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/no_data.svg', height: 10.h),
          SizedBox(height: 2.h),
          Text(
            'No data to show',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.blueGray374957,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback onFavoriteTap;

  const _FavoriteCard({
    required this.item,
    required this.onFavoriteTap,
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
                item.imageUrl,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueGray374957,
                    fontSize: 14.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Text(
                  item.price,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueGray374957,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            decoration: BoxDecoration(
                color: Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(5)),
            child: IconButton(
              onPressed: onFavoriteTap,
              icon: SvgPicture.asset(
                item.isFavorite
                    ? 'assets/icons/favorite.svg'
                    : 'assets/icons/unfavorite.svg',
                width: 19,
                height: 19,
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
}

class FavoriteItem {
  final String id;
  final String title;
  final String price;
  final String imageUrl;
  final bool isFavorite;

  FavoriteItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
  });
}
