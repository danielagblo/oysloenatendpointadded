import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final BorderRadius borderRadius;

  const DottedBorder({
    super.key,
    required this.child,
    this.color = Colors.grey,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final BorderRadius borderRadius;

  DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    path.addRRect(borderRadius.toRRect(rect));

    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PostAdUploadImagesScreen extends StatefulWidget {
  const PostAdUploadImagesScreen({super.key});

  @override
  State<PostAdUploadImagesScreen> createState() =>
      _PostAdUploadImagesScreenState();
}

class _PostAdUploadImagesScreenState extends State<PostAdUploadImagesScreen> {
  final List<String> _selectedImages = [];
  static const int maxImages = 6;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    try {
      final int remaining = maxImages - _selectedImages.length;
      if (remaining <= 0) return;

      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      if (files.isEmpty) return;

      setState(() {
        for (final XFile file in files.take(remaining)) {
          _selectedImages.add(file.path);
        }
      });
    } on PlatformException catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _proceedToNext() {
    context.pushNamed(AppRouteNames.dashboardPostAdForm,
        extra: _selectedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: CustomAppBar(
        title: 'Post Ad',
        backgroundColor: AppColors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUploadSection(),
                    SizedBox(height: 2.h),
                    _buildUploadDetails(),
                    SizedBox(height: 4.h),
                    _buildImageGrid(),
                  ],
                ),
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return GestureDetector(
      onTap: _pickImages,
      child: DottedBorder(
        color: Colors.grey.withValues(alpha: 0.5),
        strokeWidth: 2,
        dashWidth: 5,
        dashSpace: 3,
        borderRadius: BorderRadius.circular(30),
        child: SizedBox(
          width: double.infinity,
          height: 12.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Upload Images',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF222222).withValues(alpha: 0.72),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              SvgPicture.asset(
                'assets/icons/upload.svg',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '${_selectedImages.length} images added',
            style: AppTypography.bodySmall.copyWith(
              fontSize: 11.sp,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.blueGray374957,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Drag images to arrange',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.blueGray374957,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Tap image twice to delete',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    if (_selectedImages.isEmpty) {
      return SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return _buildFluidDraggableImageTile(index);
      },
    );
  }

  Widget _buildFluidDraggableImageTile(int index) {
    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImageFromPath(_selectedImages[index]),
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
      ),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          if (details.data != index) {
            // Immediately rearrange items for fluid feedback
            setState(() {
              final draggedIndex = details.data;
              final String draggedItem = _selectedImages[draggedIndex];
              _selectedImages.removeAt(draggedIndex);
              int targetIndex = index;
              if (draggedIndex < index) {
                targetIndex = index - 1;
              }
              _selectedImages.insert(targetIndex, draggedItem);
            });
            return true;
          }
          return false;
        },
        onAcceptWithDetails: (data) {
          // Final positioning is already handled in onWillAccept
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _buildImageTile(index),
          );
        },
      ),
    );
  }

  Widget _buildImageTile(int index) {
    return GestureDetector(
      onDoubleTap: () => _removeImage(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.gray8B959E.withValues(alpha: 0.2),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            _buildImageFromPath(_selectedImages[index]),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFromPath(String path) {
    if (kIsWeb) {
      // On web, image_picker returns a network-accessible blob URL.
      return Image.network(
        path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.file(
      File(path),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        SizedBox(height: 2.h),
        CustomButton.filled(
          backgroundColor: AppColors.white,
          label: 'Next',
          isPrimary: true,
          onPressed: _proceedToNext,
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
