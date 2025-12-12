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

                // Group locations by region
                final locationsByRegion = <String, List<LocationEntity>>{};
                for (final location in state.locations) {
                  final region = location.region ?? 'Other';
                  locationsByRegion.putIfAbsent(region, () => []).add(location);
                }

                // Calculate total locations count
                final totalLocationsCount = state.locations.length;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display each region group
                      ...locationsByRegion.entries.map((entry) {
                        final regionName = entry.key;
                        final locations = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: AppColors.grayF9,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.grayD9.withValues(alpha: 0.3),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                regionName,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.gray8B959E,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            ...locations
                                .map((location) => _buildRegionItem(location)),
                            SizedBox(height: 2.h),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom buttons
          BlocBuilder<LocationsCubit, LocationsState>(
            builder: (context, state) {
              final totalLocationsCount = state.locations.length;
              return Container(
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
                          'View all ($totalLocationsCount)',
                          style: AppTypography.body.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegionItem(LocationEntity location) {
    return InkWell(
      onTap: () {
        // Directly select this location and close
        if (widget.onAreasSelected != null) {
          widget.onAreasSelected!(
              location.region ?? location.name, [location.name]);
        }
        Navigator.pop(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                location.name,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.blueGray374957,
                ),
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
