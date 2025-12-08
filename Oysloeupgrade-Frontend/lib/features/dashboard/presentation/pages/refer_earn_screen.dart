import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/usecase/usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/referral_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/referral_usecases.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/earn_info_bottom_sheet.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/level_info_bottom_sheet.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/redeem_bottom_sheet.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  ReferralEntity? _referralInfo;
  List<PointsTransactionEntity> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Default fallback values to show UI even when API fails
  ReferralEntity get _displayReferralInfo {
    return _referralInfo ??
        const ReferralEntity(
          referralCode: 'DAN2785',
          points: 10000,
          cashEquivalent: 10,
          currentLevel: 'Gold',
          pointsToNextLevel: 9000,
          totalPointsForNextLevel: 100000,
          friendsReferred: 0,
        );
  }

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final getReferralInfoUseCase = sl<GetReferralInfoUseCase>();
    final getTransactionsUseCase = sl<GetReferralTransactionsUseCase>();

    final referralResult = await getReferralInfoUseCase(const NoParams());
    final transactionsResult = await getTransactionsUseCase(const NoParams());

    if (!mounted) return;

    referralResult.fold(
      (failure) {
        // Use default values instead of showing error screen
        if (mounted) {
          setState(() {
            _errorMessage = failure.message.isEmpty
                ? 'Unable to load referral information'
                : failure.message;
            _isLoading = false;
            // Keep _referralInfo as null to use default values
          });
        }
      },
      (referral) {
        if (mounted) {
          setState(() {
            _referralInfo = referral;
            _errorMessage = null; // Clear any previous errors
          });
        }
      },
    );

    transactionsResult.fold(
      (failure) {
        // Don't show error for transactions, just use empty list
        if (mounted) {
          setState(() {
            _transactions = [];
            _isLoading = false;
          });
        }
      },
      (transactions) {
        if (mounted) {
          setState(() {
            _transactions = transactions;
            _isLoading = false;
          });
        }
      },
    );
  }

  void _showEarnInfoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EarnInfoBottomSheet(referralCode: _displayReferralInfo.referralCode),
    );
  }

  void _showRedeemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RedeemBottomSheet(),
    );
  }

  void _showLevelInfoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LevelInfoBottomSheet(),
    );
  }

  void _showPointsSummarySheet() {
    final transactions = _transactions.map((t) {
      final dateFormat = DateFormat('MMM d, yyyy');
      return _PointsTransaction(
        date: dateFormat.format(t.date),
        points: t.points,
        amount: t.amount,
      );
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PointsSummaryBottomSheet(
        cashEquivalent: _displayReferralInfo.cashEquivalent,
        transactions: transactions,
      ),
    );
  }

  void _copyReferralCode() {
    Clipboard.setData(ClipboardData(text: _displayReferralInfo.referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Referral code copied!'),
        backgroundColor: AppColors.blueGray374957,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        title: 'Refer and Earn',
        backgroundColor: AppColors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null) ...[
                    SizedBox(height: 1.h),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadReferralData,
                            child: Text(
                              'Retry',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 1.2.h),
                  _PointsCard(
                    points: _displayReferralInfo.points,
                    cashEquivalent: _displayReferralInfo.cashEquivalent,
                    onPointsTap: _showPointsSummarySheet,
                    onEarnTap: _showEarnInfoSheet,
                    onRedeemTap: _showRedeemSheet,
                  ),
                  SizedBox(height: 1.2.h),
                  _LevelCard(
                    currentLevel: _displayReferralInfo.currentLevel,
                    progress: _displayReferralInfo.progress,
                    pointsToNext: _displayReferralInfo.pointsToNextLevel,
                    totalToNext: _displayReferralInfo.totalPointsForNextLevel,
                    onInfoTap: _showLevelInfoSheet,
                  ),
                  SizedBox(height: 1.2.h),
                  _ReferralSection(
                    referralCode: _displayReferralInfo.referralCode,
                    onCopyTap: _copyReferralCode,
                    friendsReferred: _displayReferralInfo.friendsReferred,
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  final int points;
  final int cashEquivalent;
  final VoidCallback onPointsTap;
  final VoidCallback onEarnTap;
  final VoidCallback onRedeemTap;

  const _PointsCard({
    required this.points,
    required this.cashEquivalent,
    required this.onPointsTap,
    required this.onEarnTap,
    required this.onRedeemTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPoints = NumberFormat.decimalPattern().format(points);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onPointsTap,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Points',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formattedPoints,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'equals ¢$cashEquivalent',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.blueGray374957.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 2.w),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.blueGray374957,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 1.2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: 'assets/icons/earn.svg',
                  label: 'Earn',
                  onTap: onEarnTap,
                ),
              ),
              SizedBox(width: 2.5.w),
              Expanded(
                child: _ActionTile(
                  icon: 'assets/icons/redeem.svg',
                  label: 'Redeem',
                  onTap: onRedeemTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                ),
                SizedBox(height: 1.h),
                Text(
                  label,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.blueGray374957,
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String currentLevel;
  final double progress;
  final int pointsToNext;
  final int totalToNext;
  final VoidCallback onInfoTap;

  const _LevelCard({
    required this.currentLevel,
    required this.progress,
    required this.pointsToNext,
    required this.totalToNext,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final pointsText = NumberFormat.decimalPattern().format(pointsToNext);

    return GestureDetector(
        onTap: onInfoTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$currentLevel (Level)',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.blueGray374957,
                  ),
                ],
              ),
              SizedBox(height: 0.8.h),
              Text(
                '$pointsText points to diamond',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.blueGray374957.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 2.h),
              LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  final progressWidth = (progress.clamp(0.0, 1.0)) * barWidth;
                  return Stack(
                    children: [
                      Container(
                        width: barWidth,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: progressWidth,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.6),
                              AppColors.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ));
  }
}

class _ReferralSection extends StatelessWidget {
  final String referralCode;
  final VoidCallback onCopyTap;
  final int friendsReferred;

  const _ReferralSection({
    required this.referralCode,
    required this.onCopyTap,
    required this.friendsReferred,
  });

  @override
  Widget build(BuildContext context) {
    final referredText = NumberFormat.decimalPattern().format(friendsReferred);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Refer Your friends and Earn',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          const _BenefitItem(
            icon: Icons.check_rounded,
            text: 'Pro Partnership status',
          ),
          const _BenefitItem(
            icon: Icons.check_rounded,
            text: 'All Ads stays promoted for a month',
          ),
          const _BenefitItem(
            icon: Icons.check_rounded,
            text: 'Share unlimited number of Ads',
          ),
          const _BenefitItem(
            icon: Icons.check_rounded,
            text: 'Boost your business',
          ),
          SizedBox(height: 2.4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppColors.grayF9,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralCode,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.2.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Copy',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.4.h),
          Text(
            "You've referred $referredText friends",
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.blueGray374957.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsSummaryBottomSheet extends StatelessWidget {
  final int cashEquivalent;
  final List<_PointsTransaction> transactions;

  const _PointsSummaryBottomSheet({
    required this.cashEquivalent,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final formattedBalance =
        NumberFormat.decimalPattern().format(cashEquivalent);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grayF9,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.6.h),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayD9,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(6.w, 3.2.h, 6.w, 2.4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Redraw',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Center(
                    child: Text(
                      'Balance: ¢$formattedBalance',
                      style: AppTypography.body.copyWith(
                        color: AppColors.blueGray374957.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.4.h),
                  Text(
                    'Payment',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.gray222222.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.6.h),
                  Text(
                    'Recent transactions',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.blueGray374957.withValues(alpha: 0.54),
                    ),
                  ),
                  SizedBox(height: 2.4.h),
                  if (transactions.isEmpty)
                    Text(
                      'No transactions yet.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.blueGray374957.withValues(alpha: 0.54),
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (var i = 0; i < transactions.length; i++) ...[
                          _PointsTransactionRow(transaction: transactions[i]),
                          if (i != transactions.length - 1) ...[
                            SizedBox(height: 1.2.h),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.grayD9.withValues(alpha: 0.54),
                            ),
                            SizedBox(height: 1.2.h),
                          ],
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsTransactionRow extends StatelessWidget {
  final _PointsTransaction transaction;

  const _PointsTransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final amountText = NumberFormat.decimalPattern().format(transaction.amount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '${transaction.date} • ${transaction.points} points',
            style: AppTypography.bodySmall.copyWith(),
          ),
        ),
        Text(
          '¢$amountText',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PointsTransaction {
  final String date;
  final int points;
  final int amount;

  const _PointsTransaction({
    required this.date,
    required this.points,
    required this.amount,
  });
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.blueGray374957,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.blueGray374957.withValues(alpha: 0.54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
