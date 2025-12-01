import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/utils/category_utils.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_cubit.dart';
import 'package:shimmer/shimmer.dart';

class StatsSection extends StatefulWidget {
  const StatsSection({super.key});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  bool _wasShimmer = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final Map<int, String> categoryNames =
            context.select<CategoriesCubit, Map<int, String>>(
          (cubit) {
            final entries = cubit.state.categories;
            if (entries.isEmpty) return const <int, String>{};
            return <int, String>{
              for (final category in entries) category.id: category.name,
            };
          },
        );

        final items = _buildItems(state, categoryNames);
        final bool showShimmer = state.status == ProductsStatus.initial ||
            (state.isLoading && !state.hasData);

        if (_wasShimmer && !showShimmer) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _controller
              ..reset()
              ..forward();
          });
        }
        _wasShimmer = showShimmer;
        return AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                const count = 5;
                final spacing = 1.5.w;
                final avail = constraints.maxWidth;
                final size = math.min(
                  15.h,
                  (avail - spacing * (count - 1)) / count,
                );

                Widget row;
                if (showShimmer) {
                  final children = <Widget>[];
                  for (var i = 0; i < count; i++) {
                    children.add(_StatCircleShimmer(size: size));
                    if (i != count - 1) children.add(SizedBox(width: spacing));
                  }
                  row = Shimmer.fromColors(
                    baseColor: AppColors.grayE4,
                    highlightColor: AppColors.white,
                    child: Row(children: children),
                  );
                } else {
                  final children = <Widget>[];
                  for (var i = 0; i < items.length; i++) {
                    final it = items[i];
                    children.add(
                      _StatCircle(
                        label: it.label,
                        valueText: it.valueText,
                        progress: (it.progress).clamp(0.0, 1.0) * _anim.value,
                        size: size,
                      ),
                    );
                    if (i != items.length - 1) {
                      children.add(SizedBox(width: spacing));
                    }
                  }
                  row = Row(children: children);
                }

                return SizedBox(height: size, child: row);
              },
            );
          },
        );
      },
    );
  }

  List<_StatItem> _buildItems(
    ProductsState state,
    Map<int, String> categoryNames,
  ) {
    if (state.hasData) {
      final stats = computeTopCategories(
        state.products,
        topN: 5,
        resolveName: (id) => categoryNames[id],
      );

      if (stats.isNotEmpty) {
        return stats
            .map((s) => _StatItem(
                  label: s.label,
                  valueText: formatCountCompact(s.count),
                  progress: s.ratio,
                ))
            .toList(growable: false);
      }
    }
    return const <_StatItem>[];
  }
}

class _StatCircleShimmer extends StatelessWidget {
  const _StatCircleShimmer({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double stroke = math.max(5.0, size * 0.05);
    return SizedBox(
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.grayE4,
                width: stroke,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size * 0.6,
                height: 8.sp,
                decoration: BoxDecoration(
                  color: AppColors.grayE4,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              SizedBox(height: 0.3.h),
              Container(
                width: size * 0.4,
                height: 8.sp,
                decoration: BoxDecoration(
                  color: AppColors.grayE4,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String valueText;
  final double progress;
  const _StatItem({
    required this.label,
    required this.valueText,
    required this.progress,
  });
}

class _StatCircle extends StatelessWidget {
  const _StatCircle({
    required this.label,
    required this.valueText,
    required this.progress,
    required this.size,
  });

  final String label;
  final String valueText;
  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double stroke = math.max(5.0, size * 0.05);
    return SizedBox(
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingArcPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: stroke,
              trackColor: AppColors.grayD9.withValues(alpha: 0.55),
              progressColor: AppColors.blueGray374957,
              dotColor: AppColors.blueGray374957,
              startAngle: -math.pi * 0.5,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                valueText,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: AppColors.blueGray374957,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingArcPainter extends CustomPainter {
  _RingArcPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
    required this.dotColor,
    this.startAngle = -math.pi / 2,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final Color dotColor;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    if (progress > 0) {
      final sweep = (math.pi * 2) * progress;
      final prog = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, prog);

      final endAngle = startAngle + sweep;
      final endDx = center.dx + radius * math.cos(endAngle);
      final endDy = center.dy + radius * math.sin(endAngle);
      final dotPaint = Paint()..color = dotColor;
      canvas.drawCircle(Offset(endDx, endDy), strokeWidth * 0.22, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.startAngle != startAngle;
  }
}
