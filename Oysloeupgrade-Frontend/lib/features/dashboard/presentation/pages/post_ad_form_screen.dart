import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/create_product_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/category_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/feature_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/subcategory_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/location_entity.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/subcategories/subcategories_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/subcategories/subcategories_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/features/features_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/features/features_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/locations/locations_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/locations/locations_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/ad_input.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/ad_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_state.dart';

class PostAdFormScreen extends StatefulWidget {
  final List<String>? selectedImages;

  const PostAdFormScreen({super.key, this.selectedImages});

  @override
  State<PostAdFormScreen> createState() => _PostAdFormScreenState();
}

class _PostAdFormScreenState extends State<PostAdFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _dailyPriceController = TextEditingController();
  final _weeklyPriceController = TextEditingController();
  final _monthlyPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _key1Controller = TextEditingController();
  final _key2Controller = TextEditingController();
  final _key3Controller = TextEditingController();
  final _durationController = TextEditingController();
  final _dailyDurationController = TextEditingController();
  final _weeklyDurationController = TextEditingController();
  final _monthlyDurationController = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  String _selectedPurpose = 'Sale';
  String? _selectedRegion; // For Ad Area Location (region name)
  int? _selectedLocationId; // For Ad Actual Map Location (location ID)

  // Maps to store dynamic feature values
  Map<int, String> _selectedFeatureValues = {};
  Map<int, TextEditingController> _featureControllers = {};
  Map<int, String> _featureErrors = {};

  @override
  void initState() {
    super.initState();
    // Fetch locations when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationsCubit>().fetch();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _dailyPriceController.dispose();
    _weeklyPriceController.dispose();
    _monthlyPriceController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _key1Controller.dispose();
    _key2Controller.dispose();
    _key3Controller.dispose();
    _durationController.dispose();
    _dailyDurationController.dispose();
    _weeklyDurationController.dispose();
    _monthlyDurationController.dispose();
    // Dispose feature controllers
    for (var controller in _featureControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildPriceSection() {
    switch (_selectedPurpose) {
      case 'Sale':
        return AdInput(
          controller: _priceController,
          labelText: 'Price',
          hintText: '₵',
          keyboardType: TextInputType.number,
        );

      case 'PayLater':
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AdInput(
                    controller: _dailyPriceController,
                    labelText: 'Daily',
                    hintText: '₵',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: AdEditableDropdown(
                    controller: _dailyDurationController,
                    hintText: 'Duration',
                    items: [
                      '1 Week',
                      '2 Weeks',
                      '1 Month',
                      '3 Months',
                      '6 Months'
                    ],
                    onChanged: (value) {
                      // Value is already set in the controller
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AdInput(
                    controller: _weeklyPriceController,
                    labelText: 'Weekly',
                    hintText: '₵',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: AdEditableDropdown(
                    controller: _weeklyDurationController,
                    hintText: 'Duration',
                    items: [
                      '1 Week',
                      '2 Weeks',
                      '1 Month',
                      '3 Months',
                      '6 Months'
                    ],
                    onChanged: (value) {
                      // Value is already set in the controller
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AdInput(
                    controller: _monthlyPriceController,
                    labelText: 'Monthly',
                    hintText: '₵',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: AdEditableDropdown(
                    controller: _monthlyDurationController,
                    hintText: 'Duration',
                    items: [
                      '1 Week',
                      '2 Weeks',
                      '1 Month',
                      '3 Months',
                      '6 Months'
                    ],
                    onChanged: (value) {
                      // Value is already set in the controller
                    },
                  ),
                ),
              ],
            ),
          ],
        );

      case 'Rent':
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: AdInput(
                controller: _priceController,
                labelText: 'Price',
                hintText: '₵',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              flex: 2,
              child: AdEditableDropdown(
                controller: _durationController,
                hintText: 'Duration',
                items: ['1 Week', '2 Weeks', '1 Month', '3 Months', '6 Months'],
                onChanged: (value) {
                  // Value is already set in the controller
                },
              ),
            ),
          ],
        );

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state.status == ProductsStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Ad submitted for review! You can view it in the Pending tab.'),
            ),
          );
          // Navigate to Ad Screen with Pending tab selected (index 1)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const AdScreen(initialTab: 1),
            ),
          );
        } else if (state.status == ProductsStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'Failed to post ad.')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.grayF9,
        appBar: CustomAppBar(
          title: 'Post Ad',
          backgroundColor: AppColors.white,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<CategoriesCubit, CategoriesState>(
                  builder: (context, state) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;

                    if (state.isLoading && !state.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Category',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.blueGray374957,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.blueGray374957
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.blueGray374957
                                    : AppColors.grayD9,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ],
                      );
                    }

                    return _CategoryBottomSheetField(
                      categoriesState: state,
                      selectedId: _selectedCategoryId,
                      onSelected: (id) {
                        setState(() {
                          _selectedCategoryId = id;
                          _selectedSubcategoryId =
                              null; // Clear subcategory when category changes
                          _selectedFeatureValues
                              .clear(); // Clear previous feature selections
                          _featureErrors.clear(); // Clear previous errors
                          // Dispose and clear feature controllers
                          for (var controller in _featureControllers.values) {
                            controller.dispose();
                          }
                          _featureControllers.clear();
                        });
                        // Fetch subcategories for the selected category
                        context.read<SubcategoriesCubit>().fetch();
                      },
                    );
                  },
                ),
                SizedBox(height: 3.h),
                // Subcategory dropdown - shown after category is selected
                if (_selectedCategoryId != null)
                  BlocBuilder<SubcategoriesCubit, SubcategoriesState>(
                    builder: (context, subcategoriesState) {
                      if (subcategoriesState.isLoading) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subcategory',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.blueGray374957,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.grayD9),
                              ),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            SizedBox(height: 3.h),
                          ],
                        );
                      }

                      if (subcategoriesState.hasData) {
                        // Filter subcategories for selected category
                        final categorySubcategories = subcategoriesState
                            .subcategories
                            .where((s) => s.categoryId == _selectedCategoryId)
                            .toList();

                        if (categorySubcategories.isNotEmpty) {
                          return Column(
                            children: [
                              _SubcategoryDropdownField(
                                subcategories: categorySubcategories,
                                selectedId: _selectedSubcategoryId,
                                onSelected: (id) {
                                  setState(() {
                                    _selectedSubcategoryId = id;
                                    _selectedFeatureValues
                                        .clear(); // Clear previous feature selections
                                    _featureErrors
                                        .clear(); // Clear previous errors
                                    // Dispose and clear feature controllers
                                    for (var controller
                                        in _featureControllers.values) {
                                      controller.dispose();
                                    }
                                    _featureControllers.clear();
                                  });
                                  // Fetch features for the selected subcategory
                                  context
                                      .read<FeaturesCubit>()
                                      .fetch(subcategoryId: id);
                                },
                              ),
                              SizedBox(height: 3.h),
                            ],
                          );
                        }
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                AdInput(
                  controller: _titleController,
                  labelText: 'Title',
                  hintText: 'Add a title',
                ),
                SizedBox(height: 3.h),
                Text(
                  'Declare ad purpose?',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.blueGray374957,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.w),
                Row(
                  children: [
                    _buildPurposeOption('Sale'),
                    SizedBox(width: 4.w),
                    _buildPurposeOption('PayLater'),
                    SizedBox(width: 4.w),
                    _buildPurposeOption('Rent'),
                  ],
                ),
                SizedBox(height: 3.h),
                _buildPriceSection(),
                SizedBox(height: 3.h),
                // Ad Area Location (Regions)
                BlocBuilder<LocationsCubit, LocationsState>(
                  builder: (context, locationsState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdDropdown(
                          labelText: 'Ad Area Location',
                          hintText: 'Select region',
                          value: _selectedRegion,
                          items: locationsState.regions
                              .map((region) => DropdownMenuItem<String>(
                                    value: region,
                                    child: Text(region),
                                  ))
                              .toList(),
                          enabled: locationsState.hasRegions,
                          onChanged: (String? value) {
                            if (!locationsState.hasRegions) return;
                            setState(() {
                              _selectedRegion = value;
                              _selectedLocationId = null;
                            });
                            if (value != null) {
                              context
                                  .read<LocationsCubit>()
                                  .filterByRegion(value);
                            }
                          },
                        ),
                        if (locationsState.isLoading)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (locationsState.hasError)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Unable to load regions',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 3.w),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/shield_info.svg',
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        ' This is required only for verification and safety purposes.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray8B959E,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                // Ad Actual Map Location (Locations within selected region)
                BlocBuilder<LocationsCubit, LocationsState>(
                  builder: (context, locationsState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdDropdown<int>(
                          labelText: 'Ad Actual Map Location',
                          hintText: _selectedRegion == null
                              ? 'Select region first'
                              : 'Select specific location',
                          value: _selectedLocationId,
                          items: locationsState.subLocations
                              .map((loc) => DropdownMenuItem<int>(
                                    value: loc.id,
                                    child: Text(loc.name),
                                  ))
                              .toList(),
                          enabled: _selectedRegion != null &&
                              locationsState.hasSubLocations,
                          onChanged: (int? value) {
                            if (_selectedRegion == null ||
                                !locationsState.hasSubLocations) return;
                            setState(() {
                              _selectedLocationId = value;
                            });
                          },
                        ),
                        if (_selectedRegion != null &&
                            !locationsState.hasSubLocations)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No locations available for selected region',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.gray8B959E,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 3.h),
                Text(
                  'Key Features',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.w),
                // Dynamic features from API based on selected subcategory
                BlocBuilder<FeaturesCubit, FeaturesState>(
                  builder: (context, featuresState) {
                    if (featuresState.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (featuresState.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Unable to load features: ${featuresState.message ?? "Unknown error"}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      );
                    }

                    if (!featuresState.hasData ||
                        _selectedSubcategoryId == null) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Select a subcategory to view available features',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gray8B959E,
                          ),
                        ),
                      );
                    }

                    // All features are already filtered by subcategory from API
                    if (featuresState.features.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No features available for this subcategory',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gray8B959E,
                          ),
                        ),
                      );
                    }

                    // Debug: Check what features have
                    for (var feature in featuresState.features) {
                      print(
                          'Feature: ${feature.name}, Options: ${feature.options}');
                    }

                    return Column(
                      children: featuresState.features.map((feature) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 3.w),
                          child: _buildDynamicFeatureDropdown(feature),
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: 3.h),
                AdInput(
                  controller: _descriptionController,
                  labelText: 'Description',
                  hintText: 'Type more',
                  maxLines: 4,
                  maxLength: 500,
                ),
                SizedBox(height: 6.w),
                CustomButton.filled(
                    label: 'Finish',
                    backgroundColor: AppColors.white,
                    onPressed: _handleFinish),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurposeOption(String purpose) {
    final isSelected = _selectedPurpose == purpose;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPurpose = purpose;
            // Clear all duration controllers when changing purpose
            _durationController.clear();
            _dailyDurationController.clear();
            _weeklyDurationController.clear();
            _monthlyDurationController.clear();
          });
        },
        child: Container(
          height: 12.w,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.blueGray374957
                          : AppColors.gray8B959E,
                      width: 1,
                    ),
                    color: Colors.transparent,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.blueGray374957,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                left: 2,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    purpose,
                    style: AppTypography.body.copyWith(
                      color:
                          isDark ? AppColors.white : AppColors.blueGray374957,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationChip(String location) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.blueGray374957 : AppColors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        location,
        style: AppTypography.bodySmall.copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : Color(0xFF222222),
        ),
      ),
    );
  }

  void _handleFinish() {
    // Validate the form first
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product category')),
        );
        return;
      }

      final params = CreateProductParams(
        name: _titleController.text,
        description: _descriptionController.text,
        price: _priceController.text,
        type: _mapPurposeToBackendType(_selectedPurpose),
        category: _selectedCategoryId!,
        duration: _durationController.text,
        images: widget.selectedImages ?? [],
      );

      final productsCubit = context.read<ProductsCubit>();
      productsCubit.createProduct(params);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
    }
  }

  String _mapPurposeToBackendType(String purpose) {
    switch (purpose) {
      case 'Rent':
        return 'RENT';
      case 'PayLater':
        return 'HIGH_PURCHASE';
      case 'Sale':
      default:
        return 'SALE';
    }
  }

  Widget _buildDynamicFeatureDropdown(FeatureEntity feature) {
    // Create a controller for this feature if it doesn't exist
    final controller = _featureControllers.putIfAbsent(
      feature.id,
      () =>
          TextEditingController(text: _selectedFeatureValues[feature.id] ?? ''),
    );

    final hasOptions = feature.options != null && feature.options!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdInput(
          controller: controller,
          labelText: feature.name,
          hintText: hasOptions
              ? 'Enter or select ${feature.name.toLowerCase()}'
              : 'Enter ${feature.name.toLowerCase()}',
          suffixIcon: GestureDetector(
            onTap: () {
              if (hasOptions) {
                _showFeatureOptionsBottomSheet(feature, controller);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No options available for ${feature.name}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Icon(
              Icons.arrow_drop_down,
              color: hasOptions
                  ? AppColors.gray8B959E
                  : AppColors.gray8B959E.withOpacity(0.5),
              size: 24,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _selectedFeatureValues[feature.id] = value;
              // Validate input against options only if options exist
              if (hasOptions &&
                  value.isNotEmpty &&
                  !feature.options!.contains(value)) {
                _featureErrors[feature.id] =
                    'Invalid ${feature.name.toLowerCase()}. Please select from dropdown.';
              } else {
                _featureErrors.remove(feature.id);
              }
            });
          },
        ),
        if (_featureErrors.containsKey(feature.id))
          Padding(
            padding: EdgeInsets.only(top: 1.w, left: 3.w),
            child: Text(
              _featureErrors[feature.id]!,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.red,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }

  void _showFeatureOptionsBottomSheet(
      FeatureEntity feature, TextEditingController controller) {
    final searchController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Filter options based on search
            final filteredOptions = feature.options!.where((option) {
              return option
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase());
            }).toList();

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.blueGray374957
                    : AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: 1.h,
                left: 4.w,
                right: 4.w,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.gray8B959E.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title
                  Text(
                    'Select ${feature.name}',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                      color: AppColors.blueGray374957,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Search field
                  if (feature.options!.length > 5)
                    Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.grayF9,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) => setModalState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: AppTypography.body.copyWith(
                            color: AppColors.gray8B959E,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.gray8B959E,
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    setModalState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.5.h,
                          ),
                        ),
                      ),
                    ),
                  // Options list
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 50.h,
                    ),
                    child: filteredOptions.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 3.h),
                            child: Center(
                              child: Text(
                                'No options found',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.gray8B959E,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredOptions.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: AppColors.grayD9.withOpacity(0.3),
                            ),
                            itemBuilder: (context, index) {
                              final option = filteredOptions[index];
                              final isSelected = controller.text == option;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    controller.text = option;
                                    _selectedFeatureValues[feature.id] = option;
                                    _featureErrors.remove(feature.id);
                                  });
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.08)
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: AppTypography.body.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.blueGray374957,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoryBottomSheetField extends StatelessWidget {
  const _CategoryBottomSheetField({
    required this.categoriesState,
    required this.selectedId,
    required this.onSelected,
  });

  final CategoriesState categoriesState;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String? selectedLabel;
    if (selectedId != null) {
      final match = categoriesState.categories.firstWhere(
        (c) => c.id == selectedId,
        orElse: () => const CategoryEntity(id: -1, name: ''),
      );
      if (match.id != -1) {
        selectedLabel = match.name;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Category',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.white : AppColors.blueGray374957,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final int? picked = await showModalBottomSheet<int>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (sheetContext) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select category',
                              style: AppTypography.bodyLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(sheetContext).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose the most relevant category for your ad. '
                          'These options are loaded from the live admin categories.',
                          style: AppTypography.bodySmall.copyWith(
                            color:
                                AppColors.blueGray263238.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: categoriesState.categories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final category =
                                  categoriesState.categories[index];
                              return ListTile(
                                title: Text(category.name),
                                subtitle: category.description != null &&
                                        category.description!.trim().isNotEmpty
                                    ? Text(
                                        category.description!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.blueGray263238
                                              .withValues(alpha: 0.7),
                                        ),
                                      )
                                    : null,
                                onTap: () => Navigator.of(sheetContext)
                                    .pop<int>(category.id),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            if (picked != null) {
              onSelected(picked);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.blueGray374957 : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.blueGray374957 : AppColors.grayD9,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedLabel ?? 'Select product category',
                    style: AppTypography.body.copyWith(
                      color: selectedLabel == null
                          ? AppColors.gray8B959E
                          : (isDark
                              ? AppColors.white
                              : AppColors.blueGray374957),
                    ),
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.grayD9.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.blueGray374957,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SubcategoryDropdownField extends StatelessWidget {
  const _SubcategoryDropdownField({
    required this.subcategories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<SubcategoryEntity> subcategories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String? selectedLabel;
    if (selectedId != null) {
      final match = subcategories.firstWhere(
        (s) => s.id == selectedId,
        orElse: () => const SubcategoryEntity(id: -1, name: '', categoryId: -1),
      );
      if (match.id != -1) {
        selectedLabel = match.name;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subcategory',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.white : AppColors.blueGray374957,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final int? picked = await showModalBottomSheet<int>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (sheetContext) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select subcategory',
                              style: AppTypography.bodyLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(sheetContext).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose a subcategory to narrow down your product listing.',
                          style: AppTypography.bodySmall.copyWith(
                            color:
                                AppColors.blueGray263238.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: subcategories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final subcategory = subcategories[index];
                              return ListTile(
                                title: Text(subcategory.name),
                                subtitle: subcategory.description != null &&
                                        subcategory.description!
                                            .trim()
                                            .isNotEmpty
                                    ? Text(
                                        subcategory.description!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.blueGray263238
                                              .withValues(alpha: 0.7),
                                        ),
                                      )
                                    : null,
                                onTap: () => Navigator.of(sheetContext)
                                    .pop<int>(subcategory.id),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            if (picked != null) {
              onSelected(picked);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.blueGray374957 : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.blueGray374957 : AppColors.grayD9,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedLabel ?? 'Select subcategory',
                    style: AppTypography.body.copyWith(
                      color: selectedLabel == null
                          ? AppColors.gray8B959E
                          : (isDark
                              ? AppColors.white
                              : AppColors.blueGray374957),
                    ),
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.grayD9.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.blueGray374957,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
