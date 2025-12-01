import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.backgroundColor,
    this.padding,
    this.arrowAssetPath,
  }) : assert(title != null || titleWidget != null,
            'Either title or titleWidget must be provided');

  final String? title;
  final Widget? titleWidget;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final String? arrowAssetPath;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _handleDefaultBack(BuildContext context) {
    final router = GoRouter.of(context);
    final currentLocation =
        router.routerDelegate.currentConfiguration.uri.toString();

    if (router.canPop()) {
      router.pop();
    } else {
      if (currentLocation.startsWith('/dashboard/')) {
        router.go(AppRoutePaths.dashboardHome);
      } else {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16.0);

    final displayedActions =
        (actions ?? const <Widget>[]).take(2).toList(growable: false);

    return Material(
      color: backgroundColor ?? AppColors.grayF9,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: effectivePadding,
          child: Stack(
            children: [
              if (showBack)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _BackWithLabel(
                      onTap: onBack ?? () => _handleDefaultBack(context),
                      labelStyle: textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w500),
                      arrowAssetPath: arrowAssetPath,
                    ),
                  ),
                ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: titleWidget ??
                      Text(
                        title!,
                        style: AppTypography.body.copyWith(
                            color: Color(0xFF646161),
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
              ),
              if (displayedActions.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < displayedActions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          displayedActions[i],
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackWithLabel extends StatelessWidget {
  const _BackWithLabel({
    required this.onTap,
    this.arrowAssetPath,
    this.labelStyle,
  });

  final VoidCallback onTap;
  final String? arrowAssetPath;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    const double size = 26;
    const double spacing = 8;
    const String label = 'Back';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: arrowAssetPath != null
                ? Image.asset(
                    arrowAssetPath!,
                    width: size * 0.5,
                    height: size * 0.5,
                  )
                : Icon(
                    Icons.arrow_back,
                    size: size * 0.55,
                  ),
          ),
          SizedBox(width: spacing),
          Text(label,
              style: AppTypography.body.copyWith(
                  color: Color(0xFF646161), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class AppBarAction extends StatelessWidget {
  AppBarAction.icon({
    super.key,
    required this.onTap,
    required IconData icon,
    this.label,
    this.color,
    this.iconSize = 20,
    this.spacing = 5,
  }) : iconBuilder = ((Color color, double size) => Icon(
              icon,
              color: color,
              size: size,
            ));

  AppBarAction.svg({
    super.key,
    required this.onTap,
    required String svgAsset,
    this.label,
    this.color,
    this.iconSize = 20,
    this.spacing = 5,
  }) : iconBuilder = ((Color color, double size) => SvgPicture.asset(
              svgAsset,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: size,
              height: size,
            ));

  const AppBarAction.widget({
    super.key,
    required this.onTap,
    required this.iconBuilder,
    this.label,
    this.color,
    this.iconSize = 20,
    this.spacing = 5,
  });

  final VoidCallback onTap;
  final Widget Function(Color color, double size) iconBuilder;
  final String? label;
  final Color? color;
  final double iconSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color effectiveColor = color ?? theme.colorScheme.onSurface;

    Widget icon = iconBuilder.call(effectiveColor, iconSize);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (label != null) ...[
              SizedBox(width: spacing),
              Text(
                label!,
                style:
                    theme.textTheme.labelLarge?.copyWith(color: effectiveColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
