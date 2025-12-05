import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

enum AdDealType { rent, sale, highPurchase }

class AdCard extends StatelessWidget {
  const AdCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.prices,
    this.type = AdDealType.sale,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final String location;
  final List<String> prices;
  final AdDealType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildContentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Expanded(
      flex: 7,
      child: Container(
        margin: EdgeInsets.all(8.sp),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.grayE4,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildImage(imageUrl),
      ),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.sp, 8.sp, 12.sp, 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationRow(),
            SizedBox(height: 4.sp),
            _buildTitle(),
            const Spacer(),
            _buildPriceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    final Widget locationContent = Row(
      children: [
        SvgPicture.asset(
          'assets/icons/location.svg',
          height: 10.sp,
          colorFilter: ColorFilter.mode(
            AppColors.blueGray374957,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 4.sp),
        Expanded(
          child: Text(
            location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.blueGray374957,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    if (!_hasTypeLabel) {
      return locationContent;
    }

    return Row(
      children: [
        Expanded(child: locationContent),
        SizedBox(width: 4.sp),
        // _buildTypeChip(),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.body.copyWith(
        color: AppColors.blueGray374957,
        fontWeight: FontWeight.w600,
        fontSize: 13.sp,
        height: 1.2,
      ),
    );
  }

  Widget _buildPriceSection() {
    if (prices.isEmpty) return const SizedBox.shrink();

    if (prices.length == 1) {
      return _buildSinglePrice();
    }

    return _buildMultiplePrices();
  }

  Widget _buildSinglePrice() {
    return Text(
      prices.first,
      style: AppTypography.body.copyWith(
        color: AppColors.blueGray374957,
        fontWeight: FontWeight.w700,
        fontSize: 15.sp,
      ),
    );
  }

  Widget _buildMultiplePrices() {
    return Wrap(
      spacing: 8.sp,
      runSpacing: 4.sp,
      children: prices.take(3).map((price) {
        return Text(
          price,
          style: AppTypography.body.copyWith(
            color: AppColors.blueGray374957,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImage(String url) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      return _buildErrorWidget();
    }

    final Map<String, String>? headers = _imageHeaders();

    if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
      // Validate URL before using it
      final uri = Uri.tryParse(trimmedUrl);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        // Invalid URL, show error widget
        return _buildErrorWidget();
      }
      
      return Image.network(
        uri.toString(),
        fit: BoxFit.cover,
        headers: headers,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(loadingProgress);
        },
      );
    }

    return Image.asset(
      trimmedUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Map<String, String>? _imageHeaders() {
    if (!sl.isRegistered<Dio>()) return null;
    final Map<String, dynamic> rawHeaders = sl<Dio>().options.headers;
    if (rawHeaders.isEmpty) return null;
    final Map<String, String> headers = <String, String>{};
    rawHeaders.forEach((key, value) {
      if (value != null) {
        headers[key.toString()] = value.toString();
      }
    });
    return headers.isEmpty ? null : headers;
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.grayE4,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.gray8B959E,
          size: 24.sp,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return Container(
      color: AppColors.grayE4,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.blueGray374957,
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  // Widget _buildTypeChip() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 3.sp),
  //     decoration: BoxDecoration(
  //       color: _typeColor().withValues(alpha: 0.15),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Text(
  //       _typeLabel(),
  //       style: AppTypography.labelSmall.copyWith(
  //         color: _typeColor(),
  //         fontSize: 11.sp,
  //         fontWeight: FontWeight.w600,
  //       ),
  //     ),
  //   );
  // }

  bool get _hasTypeLabel => _typeLabel().isNotEmpty;

  String _typeLabel() {
    switch (type) {
      case AdDealType.rent:
        return 'Rent';
      case AdDealType.highPurchase:
        return 'Hire purchase';
      case AdDealType.sale:
        return 'Sale';
    }
  }

  // Color _typeColor() {
  //   switch (type) {
  //     case AdDealType.rent:
  //       return const Color(0xFF00FFF2);
  //     case AdDealType.highPurchase:
  //       return const Color(0xFF74FFA7);
  //     case AdDealType.sale:
  //       return const Color(0xFFFF6B6B);
  //   }
  // }
}
