import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/account_delete/account_delete_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/account_delete/account_delete_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/deletion_reasons/deletion_reasons_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/deletion_reasons/deletion_reasons_state.dart';
import 'package:oysloe_mobile/core/usecase/usecase.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedReason = -1;
  final TextEditingController _customReasonController = TextEditingController();
  bool _handledLogout = false;
  List<String> _deleteReasons = ['Other']; // Default with "Other" option

  @override
  void initState() {
    super.initState();
    // Load existing delete requests and fetch deletion reasons
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountDeleteCubit>().loadRequests();
      context.read<DeletionReasonsCubit>().fetch();
    });
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_selectedReason == -1) return false;
    if (_selectedReason == _deleteReasons.length - 1) {
      // "Other" is selected, require custom reason
      return _customReasonController.text.trim().isNotEmpty;
    }
    return true;
  }

  String? _getReasonText() {
    if (_selectedReason == -1) return null;
    if (_selectedReason == _deleteReasons.length - 1) {
      return _customReasonController.text.trim();
    }
    return _deleteReasons[_selectedReason];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AccountDeleteCubit>()..loadRequests(),
        ),
        BlocProvider(
          create: (_) => sl<DeletionReasonsCubit>()..fetch(),
        ),
      ],
      child: BlocConsumer<AccountDeleteCubit, AccountDeleteState>(
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            if (state.message!.contains('success')) {
              showSuccessSnackBar(context, state.message!);
              // Reset form after successful submission
              setState(() {
                _selectedReason = -1;
                _customReasonController.clear();
              });
            } else {
              showErrorSnackBar(context, state.message!);
            }
          }

          // If any delete request has been approved, automatically log the user out.
          if (!_handledLogout && state.hasApprovedRequest) {
            _handledLogout = true;
            final logoutUseCase = sl<LogoutUseCase>();
            final router = GoRouter.of(context);

            logoutUseCase(const NoParams()).then((result) {
              if (!context.mounted) return;
              result.fold(
                (failure) {
                  showErrorSnackBar(context, failure.message);
                },
                (_) {
                  router.go(AppRoutePaths.login);
                },
              );
            });
          }
        },
        builder: (context, state) {
          final cubit = context.read<AccountDeleteCubit>();
          final bool hasPendingRequest = state.hasPendingRequest;
          final bool isSubmitting = state.isSubmitting;

          return BlocBuilder<DeletionReasonsCubit, DeletionReasonsState>(
            builder: (context, reasonsState) {
              // Update reasons from DeletionReasonsCubit
              if (reasonsState.hasData && _deleteReasons.length == 1 && reasonsState.reasons.isNotEmpty) {
                // Only update if we haven't loaded yet (still has default "Other")
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _deleteReasons = [...reasonsState.reasons, 'Other'];
                    });
                  }
                });
              }

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
                                  onTap: hasPendingRequest
                                      ? null
                                      : () {
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
                                        Expanded(
                                          child: Text(
                                            _deleteReasons[index],
                                            style: AppTypography.body.copyWith(
                                              fontSize: 13.sp,
                                              color: hasPendingRequest
                                                  ? AppColors.blueGray374957
                                                      .withValues(alpha: 0.5)
                                                  : AppColors.blueGray374957,
                                            ),
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
                                    color: AppColors.blueGray374957
                                        .withValues(alpha: 0.2),
                                  ),
                              ],
                            );
                          }),
                          if (_selectedReason == _deleteReasons.length - 1) ...[
                            SizedBox(height: 2.h),
                            TextField(
                              controller: _customReasonController,
                              enabled: !hasPendingRequest,
                              maxLines: 2,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Write a reason',
                                hintStyle: AppTypography.body.copyWith(
                                  fontSize: 14.sp,
                                  color: AppColors.blueGray374957
                                      .withValues(alpha: 0.5),
                                ),
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
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: AppColors.blueGray374957
                                        .withValues(alpha: 0.3),
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
                        label: isSubmitting
                            ? 'Submitting...'
                            : hasPendingRequest
                                ? 'Account deletion pending'
                                : 'Delete',
                        backgroundColor: (_canSubmit && !hasPendingRequest && !isSubmitting)
                            ? AppColors.blueGray374957
                            : AppColors.grayD9,
                        textColor: (_canSubmit && !hasPendingRequest && !isSubmitting)
                            ? AppColors.white
                            : AppColors.blueGray374957.withValues(alpha: 0.5),
                        onPressed: (_canSubmit && !hasPendingRequest && !isSubmitting)
                            ? () async {
                                final reason = _getReasonText();
                                if (reason != null && reason.isNotEmpty) {
                                  await cubit.submitDeleteRequest(reason: reason);
                                }
                              }
                            : null,
                      ),
                    ),
                    if (hasPendingRequest) ...[
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber.shade800,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                'Your account deletion request is currently pending review. You cannot submit another request until this one is processed.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.amber.shade800,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (state.requests.isNotEmpty && !hasPendingRequest) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Previous requests',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueGray374957,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ...state.requests.map((req) {
                        final String status = (req.status.isEmpty
                                ? 'unknown'
                                : req.status)
                            .toLowerCase();
                        Color chipColor = AppColors.grayD9;
                        Color textColor = AppColors.blueGray374957;
                        String label;
                        if (status.contains('pending')) {
                          chipColor = Colors.amber.shade100;
                          textColor = Colors.amber.shade800;
                          label = 'Pending';
                        } else if (status.contains('approved') ||
                            status.contains('completed')) {
                          chipColor = Colors.green.shade100;
                          textColor = Colors.green.shade800;
                          label = 'Approved';
                        } else if (status.contains('rejected') ||
                            status.contains('denied')) {
                          chipColor = Colors.red.shade100;
                          textColor = Colors.red.shade800;
                          label = 'Rejected';
                        } else {
                          label = req.status;
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: 1.h),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      req.reason?.trim().isNotEmpty == true
                                          ? req.reason!.trim()
                                          : 'Account delete request',
                                      style: AppTypography.bodySmall.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.blueGray374957,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: chipColor,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      label,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: textColor,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          );
            },
          );
        },
      ),
    );
  }
}
