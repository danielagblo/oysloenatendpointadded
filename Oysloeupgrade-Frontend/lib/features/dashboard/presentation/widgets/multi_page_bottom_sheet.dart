import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Future<T?> showMultiPageBottomSheet<T>({
  required BuildContext context,
  required MultiPageSheetPage<T> rootPage,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MultiPageBottomSheet<T>(rootPage: rootPage),
  );
}

class MultiPageBottomSheet<T> extends StatefulWidget {
  const MultiPageBottomSheet({super.key, required this.rootPage});

  final MultiPageSheetPage<T> rootPage;

  @override
  State<MultiPageBottomSheet<T>> createState() =>
      _MultiPageBottomSheetState<T>();
}

class _MultiPageBottomSheetState<T> extends State<MultiPageBottomSheet<T>>
    with TickerProviderStateMixin {
  late final List<MultiPageSheetPage<T>> _pageStack;

  @override
  void initState() {
    super.initState();
    _pageStack = [widget.rootPage];
  }

  MultiPageSheetPage<T> get _currentPage => _pageStack.last;

  bool get _canGoBack => _pageStack.length > 1;

  void _pushPage(MultiPageSheetPage<T> page) {
    setState(() {
      _pageStack.add(page);
    });
  }

  void _popPage() {
    if (!_canGoBack) return;
    setState(() {
      _pageStack.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fixedHeight = MediaQuery.of(context).size.height * 0.7;

    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _canGoBack) {
          _popPage();
        }
      },
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.translucent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: SizedBox(
              height: fixedHeight,
              child: SafeArea(
                top: false,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.grayF9,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: 1.6.h,
                          left: 4.w,
                          right: 4.w,
                          bottom: 1.6.h,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 44,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.grayD9,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            SizedBox(height: 1.6.h),
                            Row(
                              children: [
                                if (_canGoBack) ...[
                                  GestureDetector(
                                    onTap: _popPage,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: AppColors.grayF9,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back,
                                        size: 18,
                                        color: AppColors.blueGray374957,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.4.w),
                                ],
                                Expanded(
                                  child: Text(
                                    _currentPage.title,
                                    style: AppTypography.body.copyWith(
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.blueGray374957,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _SheetPageContent<T>(
                          key: ObjectKey(_currentPage),
                          page: _currentPage,
                          onNavigate: _pushPage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetPageContent<T> extends StatelessWidget {
  const _SheetPageContent({
    super.key,
    required this.page,
    required this.onNavigate,
  });

  final MultiPageSheetPage<T> page;
  final ValueChanged<MultiPageSheetPage<T>> onNavigate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(0, 2.h, 0, 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var sectionIndex = 0;
              sectionIndex < page.sections.length;
              sectionIndex++) ...[
            if (sectionIndex > 0) SizedBox(height: 2.4.h),
            _SectionView<T>(
              section: page.sections[sectionIndex],
              onNavigate: onNavigate,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionView<T> extends StatelessWidget {
  const _SectionView({
    required this.section,
    required this.onNavigate,
  });

  final MultiPageSheetSection<T> section;
  final ValueChanged<MultiPageSheetPage<T>> onNavigate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.heading != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.blueGray374957.withValues(alpha: 0.2)
                  : AppColors.grayF9,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              section.heading!,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 14.sp,
                color: AppColors.blueGray374957.withValues(alpha: 0.6),
              ),
            ),
          ),
          SizedBox(height: 1.h),
        ],
        for (var itemIndex = 0;
            itemIndex < section.items.length;
            itemIndex++) ...[
          _SheetItem<T>(
            item: section.items[itemIndex],
            onNavigate: onNavigate,
          ),
          if (itemIndex != section.items.length - 1) SizedBox(height: 0.5.h),
        ],
      ],
    );
  }
}

class _SheetItem<T> extends StatelessWidget {
  const _SheetItem({
    required this.item,
    required this.onNavigate,
  });

  final MultiPageSheetItem<T> item;
  final ValueChanged<MultiPageSheetPage<T>> onNavigate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tileColor = isDark ? AppColors.blueGray374957 : AppColors.white;

    return Material(
      color: tileColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (item.childBuilder != null) {
            final nextPage = item.childBuilder!();
            onNavigate(nextPage);
          } else if (item.value != null) {
            Navigator.of(context).pop(item.value);
          } else {
            item.onTap?.call();
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 1.2.h,
            horizontal: 3.w,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: AppTypography.body.copyWith(
                    fontSize: 15.sp,
                    color: isDark ? AppColors.white : AppColors.blueGray374957,
                  ),
                ),
              ),
              if (item.childBuilder != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.blueGray374957.withValues(alpha: 0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MultiPageSheetPage<T> {
  const MultiPageSheetPage({
    required this.title,
    required this.sections,
  });

  final String title;
  final List<MultiPageSheetSection<T>> sections;
}

class MultiPageSheetSection<T> {
  const MultiPageSheetSection({
    this.heading,
    required this.items,
  });

  final String? heading;
  final List<MultiPageSheetItem<T>> items;
}

class MultiPageSheetItem<T> {
  const MultiPageSheetItem({
    required this.label,
    this.value,
    this.childBuilder,
    this.onTap,
  });

  final String label;
  final T? value;
  final MultiPageSheetPage<T> Function()? childBuilder;
  final VoidCallback? onTap;
}
