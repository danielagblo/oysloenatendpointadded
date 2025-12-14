import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/area_select_sheet.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/locations/locations_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/locations/locations_state.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/location_entity.dart';

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
  @override
  void initState() {
    super.initState();
    // Fetch locations when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationsCubit>().fetch();
    });
  }

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
            child: BlocBuilder<LocationsCubit, LocationsState>(
              builder: (context, state) {
                if (state.isLoading && !state.hasData) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (state.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: Text(
                        state.message ?? 'Failed to load locations',
                        style: AppTypography.body.copyWith(
                          color: AppColors.gray8B959E,
                        ),
                      ),
                    ),
                  );
                }

                if (!state.hasData || state.locations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: Text(
                        'No locations available',
                        style: AppTypography.body.copyWith(
                          color: AppColors.gray8B959E,
                        ),
                      ),
                    ),
                  );
                }

                // Get unique regions
                final regions = <String>{};
                for (final location in state.locations) {
                  if (location.region != null && location.region!.isNotEmpty) {
                    regions.add(location.region!);
                  }
                }
                final sortedRegions = regions.toList()..sort();

                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: sortedRegions.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppColors.grayE4,
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final regionName = sortedRegions[index];
                    // Count locations in this region
                    final regionLocationsCount = state.locations
                        .where((loc) => loc.region == regionName)
                        .length;

                    return _buildRegionItem(regionName, regionLocationsCount);
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildRegionItem(String regionName, int locationsCount) {
    return InkWell(
      onTap: () async {
        // Close region sheet first
        Navigator.pop(context);
        // Show area selection sheet for this region
        final selectedAreas = await showAreaSelectSheet(
          context,
          regionName: regionName,
        );
        if (selectedAreas != null && selectedAreas.isNotEmpty) {
          // Notify parent about areas selection
          if (widget.onAreasSelected != null) {
            widget.onAreasSelected!(regionName, selectedAreas);
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    regionName,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.blueGray374957,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    '$locationsCount locations',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray8B959E,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.gray8B959E,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showRegionSelectSheet(
  BuildContext context, {
  required Function(String region, List<String> areas) onAreasSelected,
}) {
  // Capture BLoC instance before building the bottom sheet
  final locationsCubit = context.read<LocationsCubit>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) => BlocProvider.value(
      value: locationsCubit,
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => RegionSelectSheet(
          onAreasSelected: onAreasSelected,
        ),
      ),
    ),
  );
}
