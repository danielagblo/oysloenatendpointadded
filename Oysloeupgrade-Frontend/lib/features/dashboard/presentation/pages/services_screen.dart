import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/ad_input.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/step_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/models/service_application.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDob;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: CustomAppBar(
        title: 'Apply',
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                const StepIndicator(
                  currentStep: 1,
                  labels: ['Personal', 'Additional', 'Review'],
                ),
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  color: AppColors.white,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal details',
                          style: AppTypography.body,
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          'Let\'s get to know you a bit by sharing some details about you.',
                          style: AppTypography.body.copyWith(
                            color: AppColors.blueGray374957
                                .withValues(alpha: 0.54),
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        AdInput(
                          controller: _nameController,
                          labelText: 'Name *',
                          hintText: 'Ex. John Agblo',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.4.h),
                        AdInput(
                          controller: _phoneController,
                          labelText: 'Number',
                          hintText: '0552892433',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 2.4.h),
                        AdInput(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 0.8.h),
                Container(
                  width: double.infinity,
                  color: AppColors.white,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdInput(
                          controller: _locationController,
                          labelText: 'Location *',
                          hintText: 'Location',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Location is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.8.h),
                        Row(
                          children: [
                            Expanded(
                              child: AdInput(
                                controller: _genderController,
                                labelText: 'Gender',
                                hintText: 'Gender',
                                readOnly: true,
                                onTap: _handleGenderSelection,
                                suffixIcon: const Icon(
                                  Icons.unfold_more,
                                  color: AppColors.gray8B959E,
                                  size: 17,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: AdInput(
                                controller: _dobController,
                                labelText: 'Date of birth',
                                hintText: 'Date of birth',
                                readOnly: true,
                                onTap: _handleDobSelection,
                                suffixIcon: const Icon(
                                  Icons.unfold_more,
                                  color: AppColors.gray8B959E,
                                  size: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: CustomButton.filled(
                    label: 'Next',
                    isPrimary: false,
                    backgroundColor: AppColors.white,
                    textColor: AppColors.blueGray374957,
                    onPressed: _handleNext,
                    padding: EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGenderSelection() async {
    FocusScope.of(context).unfocus();
    const genders = ['Male', 'Female'];

    String? selected;
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      final initialIndex =
          _selectedGender != null ? genders.indexOf(_selectedGender!) : 0;
      final pickedIndex = await showCupertinoModalPopup<int>(
        context: context,
        builder: (context) {
          int tempIndex = initialIndex;
          return Container(
            height: 300,
            color: AppColors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Cancel',
                          style: AppTypography.body.copyWith(
                            color: AppColors.gray8B959E,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Done',
                          style: AppTypography.body.copyWith(
                            color: AppColors.blueGray374957,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(tempIndex),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (index) => tempIndex = index,
                    children: [
                      for (final gender in genders)
                        Center(
                          child: Text(
                            gender,
                            style: AppTypography.body.copyWith(
                              color: AppColors.blueGray374957,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
      if (pickedIndex != null) {
        selected = genders[pickedIndex];
      }
    } else {
      selected = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select gender',
                    style: AppTypography.body.copyWith(
                      color: AppColors.blueGray374957,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final gender in genders)
                  ListTile(
                    title: Text(
                      gender,
                      style: AppTypography.body.copyWith(
                        color: AppColors.blueGray374957,
                      ),
                    ),
                    trailing: gender == _selectedGender
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () => Navigator.of(context).pop(gender),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    if (selected != null && selected != _selectedGender) {
      setState(() {
        _selectedGender = selected;
        _genderController.text = selected!;
      });
    }
  }

  Future<void> _handleDobSelection() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initialDate =
        _selectedDob ?? DateTime(now.year - 18, now.month, now.day);
    final firstDate = DateTime(now.year - 100, 1, 1);
    final lastDate = DateTime(now.year, now.month, now.day);
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      DateTime tempDate = initialDate;
      final picked = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (context) {
          return Container(
            height: 320,
            color: AppColors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Cancel',
                          style: AppTypography.body.copyWith(
                            color: AppColors.gray8B959E,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Done',
                          style: AppTypography.body.copyWith(
                            color: AppColors.blueGray374957,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(tempDate),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDate,
                    minimumDate: firstDate,
                    maximumDate: lastDate,
                    onDateTimeChanged: (date) => tempDate = date,
                  ),
                ),
              ],
            ),
          );
        },
      );
      if (picked != null) {
        setState(() {
          _selectedDob = picked;
          _dobController.text = DateFormat('d MMM yyyy').format(picked);
        });
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        // Override only the action button (Cancel/OK) color for Android.
        builder: (context, child) {
          final theme = Theme.of(context);
          return Theme(
            data: theme.copyWith(
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.blueGray374957,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          _selectedDob = picked;
          _dobController.text = DateFormat('d MMM yyyy').format(picked);
        });
      }
    }
  }

  void _handleNext() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    // a quick confirmation, then navigate
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Personal details captured. Continue to additional details.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.blueGray374957,
        duration: const Duration(milliseconds: 800),
      ),
    );
    final app = ServiceApplication(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      location: _locationController.text.trim(),
      gender: _selectedGender,
      dob: _selectedDob,
    );
    GoRouter.of(context)
        .pushNamed(AppRouteNames.dashboardServicesAdditional, extra: app);
  }
}
