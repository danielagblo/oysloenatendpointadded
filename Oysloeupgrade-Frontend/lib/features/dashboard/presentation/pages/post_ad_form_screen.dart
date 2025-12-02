import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/create_product_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/category_entity.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/ad_input.dart';
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
  String _selectedPurpose = 'Sale';
  String? _selectedAreaLocation;
  String? _selectedMapLocation;

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
            const SnackBar(content: Text('Ad posted successfully!')),
          );
          Navigator.of(context).pop();
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
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: 3.h),
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
                AdLocationDropdown(
                  labelText: 'Ad Area Location',
                  value: _selectedAreaLocation,
                  onChanged: (value) {
                    setState(() {
                      _selectedAreaLocation = value;
                    });
                  },
                ),
                SizedBox(height: 2.w),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.w,
                  children: [
                    'Home Spintex',
                    'Shop Accra',
                    'Shop East Legon',
                    'Shop Kumasi'
                  ].map((location) => _buildLocationChip(location)).toList(),
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
                AdLocationDropdown(
                  labelText: 'Ad Actual Map Location',
                  value: _selectedMapLocation,
                  onChanged: (value) {
                    setState(() {
                      _selectedMapLocation = value;
                    });
                  },
                ),
                SizedBox(height: 2.w),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.w,
                  children: [
                    'Home Spintex',
                    'Shop Accra',
                    'Shop East Legon',
                    'Shop Kumasi'
                  ].map((location) => _buildLocationChip(location)).toList(),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Key Features',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.w),
                AdDropdown<String>(
                  value: _brandController.text.isEmpty
                      ? null
                      : _brandController.text,
                  labelText: 'Brand',
                  hintText: 'Select brand',
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Apple',
                      child: Text('Apple'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Samsung',
                      child: Text('Samsung'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Nike',
                      child: Text('Nike'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Sony',
                      child: Text('Sony'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'LG',
                      child: Text('LG'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'HP',
                      child: Text('HP'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Dell',
                      child: Text('Dell'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Other',
                      child: Text('Other'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _brandController.text = value ?? '';
                    });
                  },
                ),
                SizedBox(height: 3.w),
                AdDropdown<String>(
                  value:
                      _key1Controller.text.isEmpty ? null : _key1Controller.text,
                  labelText: 'Key 1',
                  hintText: 'Select key 1',
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'New',
                      child: Text('New'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Used',
                      child: Text('Used'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Refurbished',
                      child: Text('Refurbished'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Like New',
                      child: Text('Like New'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _key1Controller.text = value ?? '';
                    });
                  },
                ),
                SizedBox(height: 3.w),
                AdDropdown<String>(
                  value:
                      _key2Controller.text.isEmpty ? null : _key2Controller.text,
                  labelText: 'Key 2',
                  hintText: 'Select key 2',
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Original',
                      child: Text('Original'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Copy',
                      child: Text('Copy'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Generic',
                      child: Text('Generic'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _key2Controller.text = value ?? '';
                    });
                  },
                ),
                SizedBox(height: 3.w),
                AdDropdown<String>(
                  value:
                      _key3Controller.text.isEmpty ? null : _key3Controller.text,
                  labelText: 'Key 3',
                  hintText: 'Select key 3',
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Warranty',
                      child: Text('Warranty'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'No Warranty',
                      child: Text('No Warranty'),
                    ),
                    DropdownMenuItem<String>(
                      value: '1 Year',
                      child: Text('1 Year'),
                    ),
                    DropdownMenuItem<String>(
                      value: '2 Years',
                      child: Text('2 Years'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _key3Controller.text = value ?? '';
                    });
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
                              onPressed: () =>
                                  Navigator.of(sheetContext).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose the most relevant category for your ad. '
                          'These options are loaded from the live admin categories.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.blueGray263238
                                .withValues(alpha: 0.7),
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
                              final category = categoriesState.categories[index];
                              return ListTile(
                                title: Text(category.name),
                                subtitle: category.description != null &&
                                        category.description!.trim().isNotEmpty
                                    ? Text(
                                        category.description!,
                                        style:
                                            AppTypography.bodySmall.copyWith(
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
