import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../themes/typo.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.imagePath = 'assets/icons/no_data.svg',
    this.imageHeight = 70,
    this.textAlign = TextAlign.center,
  });

  final String imagePath;
  final String message;
  final double imageHeight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIllustration(),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.body.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: textAlign,
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        height: imageHeight,
      );
    }

    return Image.asset(
      imagePath,
      height: imageHeight,
      fit: BoxFit.contain,
    );
  }
}
