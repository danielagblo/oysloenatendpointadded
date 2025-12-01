import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/common/widgets/app_empty_state.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FilteredEmptyState extends StatelessWidget {
  final VoidCallback onClearFilters;

  const FilteredEmptyState({
    super.key,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          const AppEmptyState(
            message: 'No Ads to show',
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

