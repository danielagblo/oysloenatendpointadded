import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedReason = -1;
  final TextEditingController _customReasonController = TextEditingController();

  final List<String> _deleteReasons = [
    'Your friend sign up using your link and adding dummy',
    'Your friend sign up using your link and adding dummy',
    'Your friend sign up using your link and adding dummy',
    'Your friend sign up using your link and adding dummy',
    'Your friend sign up using your link and adding dummy',
    'Other',
  ];

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        title: 'Delete account',
        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Account',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.blueGray374957,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'If you want to delete your account and you\'re prompted to provide a reason for deleting.',
                style: AppTypography.body.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.blueGray374957.withValues(alpha: 0.54),
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ...List.generate(_deleteReasons.length, (index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedReason = index;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedReason == index
                                              ? AppColors.blueGray374957
                                              : AppColors.blueGray374957
                                                  .withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                        color: _selectedReason == index
                                            ? AppColors.white
                                            : Colors.transparent,
                                      ),
                                      child: _selectedReason == index
                                          ? const Icon(
                                              Icons.circle,
                                              size: 14,
                                              color: AppColors.blueGray374957,
                                            )
                                          : null,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    _deleteReasons[index],
                                    style: AppTypography.body.copyWith(
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index < _deleteReasons.length - 1)
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              color: AppColors.blueGray374957.withValues(alpha: 0.2),
                            ),
                        ],
                      );
                    }),
                    if (_selectedReason == _deleteReasons.length - 1) ...[
                      SizedBox(height: 2.h),
                      TextField(
                        controller: _customReasonController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Write a reason',
                          hintStyle:
                              AppTypography.body.copyWith(fontSize: 14.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black45,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black45,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: AppColors.blueGray374957,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(4.w),
                        ),
                        style: AppTypography.body.copyWith(
                          color: AppColors.blueGray374957,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: CustomButton.filled(
                  label: 'Delete',
                  backgroundColor: AppColors.white,
                  onPressed: () {},
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
