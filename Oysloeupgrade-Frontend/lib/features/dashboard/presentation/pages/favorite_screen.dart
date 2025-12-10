import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/usecase/usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/product_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/favourites_usecases.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final GetFavouritesUseCase _getFavouritesUseCase = sl<GetFavouritesUseCase>();
  final ToggleFavouriteUseCase _toggleFavouriteUseCase =
      sl<ToggleFavouriteUseCase>();

  List<ProductEntity> _items = <ProductEntity>[];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _getFavouritesUseCase(const NoParams());
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message.isEmpty
              ? 'Unable to load favourites right now.'
              : failure.message;
          _isLoading = false;
        });
      },
      (favourites) {
        setState(() {
          _items = favourites;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _onToggleFavourite(ProductEntity product) async {
    final int productId = product.id;
    final result = await _toggleFavouriteUseCase(
      ToggleFavouriteParams(productId: productId),
    );
    if (!mounted) return;

    result.fold(
      (failure) => showErrorSnackBar(
        context,
        failure.message.isEmpty
            ? 'Unable to update favourite.'
            : failure.message,
      ),
      (updated) {
        setState(() {
          if (!updated.isFavourite) {
            _items.removeWhere((p) => p.id == updated.id);
            showSuccessSnackBar(context, 'Removed from favorites');
          } else {
            final idx = _items.indexWhere((p) => p.id == updated.id);
            if (idx >= 0) {
              _items[idx] = updated;
            } else {
              _items.insert(0, updated);
            }
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        backgroundColor: AppColors.white,
        title: 'Favorite',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.blueGray374957,
                  onRefresh: _loadFavourites,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 0.6.h),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _FavoriteCard(
                        item: item,
                        onFavoriteTap: () => _onToggleFavourite(item),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: AppTypography.body.copyWith(
                color: AppColors.blueGray374957,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _loadFavourites,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/no_data.svg', height: 10.h),
          SizedBox(height: 2.h),
          Text(
            'No favorites yet',
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
  final ProductEntity item;
  final VoidCallback onFavoriteTap;

  const _FavoriteCard({
    required this.item,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.image.isNotEmpty
        ? item.image
        : (item.images.isNotEmpty ? item.images.first : '');
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 3.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 12.h,
            width: 22.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: AppColors.grayF9,
            ),
            child: imageUrl.isEmpty
                ? const Icon(Icons.image_not_supported_outlined,
                    color: AppColors.gray8B959E)
                : null,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
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
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              onPressed: onFavoriteTap,
              icon: SvgPicture.asset(
                'assets/icons/favorite.svg',
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
