import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/constants/api.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/usecase/usecase.dart';
import 'package:oysloe_mobile/core/utils/formatters.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/product_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/get_user_products_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/delete_product_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/set_product_status_usecase.dart';

class AdScreen extends StatefulWidget {
  const AdScreen({super.key});

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _expandedAdId;
  List<ProductEntity> _allProducts = [];
  bool _isLoading = true;
  String? _error;
  
  final GetUserProductsUseCase _getUserProductsUseCase =
      sl<GetUserProductsUseCase>();
  final DeleteProductUseCase _deleteProductUseCase =
      sl<DeleteProductUseCase>();
  final SetProductStatusUseCase _setProductStatusUseCase =
      sl<SetProductStatusUseCase>();

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
    _loadUserProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _getUserProductsUseCase(const NoParams());

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message.isEmpty
              ? 'Unable to load your ads'
              : failure.message;
          _isLoading = false;
        });
      },
      (products) {
        setState(() {
          _allProducts = products;
          _isLoading = false;
        });
      },
    );
  }

  List<ProductEntity> _filterProductsByTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // Active
        return _allProducts
            .where((p) => 
                p.status.toLowerCase() == 'active' && !p.isTaken)
            .toList();
      case 1: // Pending
        return _allProducts
            .where((p) => p.status.toLowerCase() == 'pending')
            .toList();
      case 2: // Taken
        return _allProducts.where((p) => p.isTaken).toList();
      case 3: // Suspended
        return _allProducts
            .where((p) => p.status.toLowerCase() == 'suspended')
            .toList();
      default:
        return [];
    }
  }

  void _toggleAdMenu(String adId) {
    setState(() {
      _expandedAdId = _expandedAdId == adId ? null : adId;
    });
  }

  void _handleMenuAction(String action, ProductEntity product) {
    setState(() {
      _expandedAdId = null;
    });

    switch (action) {
      case 'taken':
        _navigateToAdDetail(product);
        break;
      case 'delete':
        _confirmAndDeleteAd(product);
        break;
      case 'suspend':
        _suspendAd(product);
        break;
    }
  }

  Future<void> _confirmAndDeleteAd(ProductEntity product) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ad'),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _deleteProductUseCase(
      DeleteProductParams(productId: product.id),
    );

    if (!mounted) return;

    result.fold(
      (failure) => showErrorSnackBar(
        context,
        failure.message.isEmpty ? 'Unable to delete ad' : failure.message,
      ),
      (_) {
        setState(() {
          _allProducts.removeWhere((p) => p.id == product.id);
        });
        showSuccessSnackBar(context, 'Ad deleted successfully');
      },
    );
  }

  Future<void> _suspendAd(ProductEntity product) async {
    final result = await _setProductStatusUseCase(
      SetProductStatusParams(productId: product.id, status: 'suspended'),
    );

    if (!mounted) return;

    result.fold(
      (failure) => showErrorSnackBar(
        context,
        failure.message.isEmpty ? 'Unable to suspend ad' : failure.message,
      ),
      (updatedProduct) {
        setState(() {
          final index = _allProducts.indexWhere((p) => p.id == product.id);
          if (index >= 0) {
            _allProducts[index] = updatedProduct;
          }
        });
        showSuccessSnackBar(context, 'Ad suspended successfully');
      },
    );
  }

  void _navigateToAdDetail(ProductEntity product) {
    context.pushNamed(
      AppRouteNames.dashboardHomeAdDetail,
      pathParameters: <String, String>{
        'adId': product.pid.isNotEmpty ? product.pid : product.id.toString(),
      },
      extra: <String, dynamic>{
        'product': product,
      },
    );
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState()
                : Column(
                    children: [
                      SizedBox(height: 0.6.h),
                      Container(
                        color: AppColors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAdList(0),
                            _buildAdList(1),
                            _buildAdList(2),
                            _buildAdList(3),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildErrorState() {
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
            onPressed: _loadUserProducts,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdList(int tabIndex) {
    final products = _filterProductsByTab(tabIndex);
    final tabNames = ['Active', 'Pending', 'Taken', 'Suspended'];

    if (products.isEmpty) {
      return _buildEmptyState(tabNames[tabIndex]);
    }

    return RefreshIndicator(
      color: AppColors.blueGray374957,
      onRefresh: _loadUserProducts,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 0.6.h),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isExpanded = _expandedAdId == product.id.toString();

          return AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                _AdCard(
                  product: product,
                  isMenuExpanded: isExpanded,
                  onMenuTap: () => _toggleAdMenu(product.id.toString()),
                  onCloseTap: () => setState(() => _expandedAdId = null),
                  onCardTap: () => _navigateToAdDetail(product),
                ),
                if (isExpanded)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isExpanded ? 1.0 : 0.0,
                    child: _HorizontalDropdownMenu(
                      onMarkAsTaken: () => _handleMenuAction('taken', product),
                      onDelete: () => _handleMenuAction('delete', product),
                      onSuspend: () => _handleMenuAction('suspend', product),
                      isTaken: product.isTaken,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
  final ProductEntity product;
  final bool isMenuExpanded;
  final VoidCallback onMenuTap;
  final VoidCallback onCloseTap;
  final VoidCallback onCardTap;

  const _AdCard({
    required this.product,
    required this.isMenuExpanded,
    required this.onMenuTap,
    required this.onCloseTap,
    required this.onCardTap,
  });

  String _normalizeImageUrl(String? raw) {
    if (raw == null) return '';
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    try {
      final Uri baseUri = Uri.parse(AppStrings.baseUrl);
      final String origin = '${baseUri.scheme}://${baseUri.host}';
      return trimmed.startsWith('/') ? '$origin$trimmed' : '$origin/$trimmed';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _normalizeImageUrl(
      product.image.isNotEmpty
          ? product.image
          : (product.images.isNotEmpty ? product.images.first : ''),
    );
    final price = CurrencyFormatter.ghana.formatRaw(product.price);

    return GestureDetector(
      onTap: onCardTap,
      child: Container(
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
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    )
                  : _buildImagePlaceholder(),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '~ ${product.totalReports} reports',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.blueGray374957,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '~ ${product.totalFavourites} favorites',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.blueGray374957,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    product.name,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueGray374957,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    price,
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
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.grayD9.withValues(alpha: 0.3),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.blueGray374957.withValues(alpha: 0.5),
      ),
    );
  }
}

class _HorizontalDropdownMenu extends StatelessWidget {
  final VoidCallback onMarkAsTaken;
  final VoidCallback onDelete;
  final VoidCallback onSuspend;
  final bool isTaken;

  const _HorizontalDropdownMenu({
    required this.onMarkAsTaken,
    required this.onDelete,
    required this.onSuspend,
    this.isTaken = false,
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
              text: isTaken ? 'View ad' : 'Mark as taken',
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
