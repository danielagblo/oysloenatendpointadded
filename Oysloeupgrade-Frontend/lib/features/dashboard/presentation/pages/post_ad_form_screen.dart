import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/create_product_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_cubit.dart';
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

  String? _selectedCategory;
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
                AdCategoryDropdown(
                  labelText: 'Product Category',
                  value: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
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
                AdEditableDropdown(
                  controller: _brandController,
                  hintText: 'Brand',
                  items: [
                    'Apple',
                    'Samsung',
                    'Nike',
                    'Sony',
                    'LG',
                    'HP',
                    'Dell',
                    'Other'
                  ],
                  onChanged: (value) {
                    // Value is already set in the controller
                  },
                ),
                SizedBox(height: 3.w),
                AdEditableDropdown(
                  controller: _key1Controller,
                  hintText: 'Key 1',
                  items: ['New', 'Used', 'Refurbished', 'Like New'],
                  onChanged: (value) {
                    // Value is already set in the controller
                  },
                ),
                SizedBox(height: 3.w),
                AdEditableDropdown(
                  controller: _key2Controller,
                  hintText: 'Key 2',
                  items: ['Original', 'Copy', 'Generic'],
                  onChanged: (value) {
                    // Value is already set in the controller
                  },
                ),
                SizedBox(height: 3.w),
                AdEditableDropdown(
                  controller: _key3Controller,
                  hintText: 'Key 3',
                  items: ['Warranty', 'No Warranty', '1 Year', '2 Years'],
                  onChanged: (value) {
                    // Value is already set in the controller
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
      final params = CreateProductParams(
        name: _titleController.text,
        description: _descriptionController.text,
        price: _priceController.text,
        type: _selectedPurpose,
        category: int.tryParse(_selectedCategory ?? '') ?? 0,
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
}
