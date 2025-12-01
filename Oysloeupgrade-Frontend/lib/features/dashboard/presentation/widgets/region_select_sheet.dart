import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/area_select_sheet.dart';

class RegionSelectSheet extends StatefulWidget {
  final Function(String region, List<String> areas)? onAreasSelected;

  const RegionSelectSheet({
    super.key,
    this.onAreasSelected,
  });

  @override
  State<RegionSelectSheet> createState() => _RegionSelectSheetState();
}

class _RegionSelectSheetState extends State<RegionSelectSheet> {
  final List<_RegionItem> _popularRegions = const [
    _RegionItem(name: 'Greater Accra', count: '879'),
    _RegionItem(name: 'Eastern region', count: '8799'),
    _RegionItem(name: 'Ashanti region', count: '98k'),
  ];

  final List<_RegionItem> _otherRegions = const [
    _RegionItem(name: 'Savannah', count: '879'),
    _RegionItem(name: 'Afienya', count: '8799'),
    _RegionItem(name: 'Domenya', count: '98k'),
    _RegionItem(name: 'Fashion', count: '879'),
    _RegionItem(name: 'Accra', count: '8799'),
    _RegionItem(name: 'Kwame Nkrumah Circle', count: '98k'),
    _RegionItem(name: 'Spintex', count: '98k'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grayD9,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Region',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Popular regions
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppColors.grayF9,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.grayD9.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      'Popular regions',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray8B959E,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ..._popularRegions.map((region) => _buildRegionItem(region)),
                  
                  SizedBox(height: 2.h),
                  
                  // Other regions
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppColors.grayF9,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.grayD9.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      'Other regions',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray8B959E,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ..._otherRegions.map((region) => _buildRegionItem(region)),
                  
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.grayE4,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Clear all',
                      style: AppTypography.body.copyWith(
                        color: AppColors.blueGray374957,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF142032),
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View all (456k)',
                      style: AppTypography.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionItem(_RegionItem region) {
    return InkWell(
      onTap: () async {
        // Close region sheet first
        Navigator.pop(context);
        // Show area selection sheet for this region
        final areas = await showAreaSelectSheet(
          context,
          regionName: region.name,
        );
        if (areas != null && widget.onAreasSelected != null) {
          widget.onAreasSelected!(region.name, areas);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              region.name,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.blueGray374957,
              ),
            ),
            Row(
              children: [
                Text(
                  region.count,
                  style: AppTypography.body.copyWith(
                    color: AppColors.gray8B959E,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.gray8B959E,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionItem {
  final String name;
  final String count;

  const _RegionItem({
    required this.name,
    required this.count,
  });
}

Future<void> showRegionSelectSheet(
  BuildContext context, {
  required Function(String region, List<String> areas) onAreasSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => RegionSelectSheet(
        onAreasSelected: onAreasSelected,
      ),
    ),
  );
}

