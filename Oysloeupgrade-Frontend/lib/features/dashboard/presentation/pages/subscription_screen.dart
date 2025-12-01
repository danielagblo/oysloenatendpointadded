import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:oysloe_mobile/features/dashboard/data/datasources/subscription_remote_data_source.dart';
import 'package:oysloe_mobile/features/dashboard/data/repositories/subscription_repository.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/subscription_usecases.dart';

enum SubscriptionPlan { basic, business, platinum }

enum SubscriptionStatus { none, active, expired }

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.none;
  SubscriptionPlan? _currentPlan;
  int _daysRemaining = 0;
  SubscriptionPlan? _selectedPlan;
  bool _loading = true;

  Color get _planColor {
    switch (_currentPlan ?? _selectedPlan) {
      case SubscriptionPlan.basic:
        return const Color(0xFF74FFA7);
      case SubscriptionPlan.business:
        return const Color(0xFF00FFF2);
      case SubscriptionPlan.platinum:
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF74FFA7);
    }
  }

  String get _planLabel {
    switch (_currentPlan ?? _selectedPlan) {
      case SubscriptionPlan.basic:
        return 'Basic package';
      case SubscriptionPlan.business:
        return 'Business package';
      case SubscriptionPlan.platinum:
        return 'Platinum package';
      default:
        return 'Basic package';
    }
  }

  String get _expiryText {
    if (_daysRemaining > 0) {
      return 'Expires in $_daysRemaining days';
    }
    switch (_currentPlan ?? _selectedPlan) {
      case SubscriptionPlan.basic:
        return 'Expires in 7 days';
      case SubscriptionPlan.business:
        return 'Expires in 14 days';
      case SubscriptionPlan.platinum:
        return 'Expires in 30 days';
      default:
        return 'Expires in 7 days';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionStatus();
  }

  Future<void> _fetchSubscriptionStatus() async {
    setState(() => _loading = true);
    try {
      final dio = Dio();
      final remoteDataSource = SubscriptionRemoteDataSource(dio);
      final repository = SubscriptionRepository(remoteDataSource);
      final getUserSubscription = GetUserSubscriptionUseCase(repository);
      final data = await getUserSubscription();
      
      if (data['is_active'] == true) {
        _subscriptionStatus = SubscriptionStatus.active;
        _currentPlan = _mapPlan(data['plan']);
        _daysRemaining = data['days_remaining'] ?? 0;
      } else {
        _subscriptionStatus = SubscriptionStatus.none;
        _currentPlan = null;
        _daysRemaining = 0;
      }
    } catch (e) {
      _subscriptionStatus = SubscriptionStatus.none;
      _currentPlan = null;
      _daysRemaining = 0;
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  SubscriptionPlan? _mapPlan(String? plan) {
    switch (plan?.toLowerCase()) {
      case 'basic':
        return SubscriptionPlan.basic;
      case 'business':
        return SubscriptionPlan.business;
      case 'platinum':
        return SubscriptionPlan.platinum;
      default:
        return null;
    }
  }

  void _selectPlan(SubscriptionPlan plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  Future<void> _handlePayment() async {
    if (_selectedPlan == null &&
        _subscriptionStatus != SubscriptionStatus.active) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subscription plan'),
          backgroundColor: AppColors.redFF6B6B,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final dio = Dio();
      final remoteDataSource = SubscriptionRemoteDataSource(dio);
      final repository = SubscriptionRepository(remoteDataSource);
      final getAvailableSubscriptions =
          GetAvailableSubscriptionsUseCase(repository);
      final subs = await getAvailableSubscriptions();
      
      final selectedPlanStr = _selectedPlan.toString().split('.').last;
      final selectedSub = subs.cast<Map<String, dynamic>?>().firstWhere(
            (s) => s != null && s['plan'] == selectedPlanStr,
            orElse: () => null,
          );
      
      if (selectedSub == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription plan not found'),
            backgroundColor: AppColors.redFF6B6B,
          ),
        );
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
      }
      
      final subscriptionId = selectedSub['id'].toString();
      final callbackUrl = 'https://oysloe.com/payment/callback';
      
      final response = await dio.post(
        'https://api.oysloe.com/api-v1/paystack/initiate/',
        data: {
          'subscription_id': subscriptionId,
          'callback_url': callbackUrl,
        },
      );
      
      final authUrl = response.data['authorization_url'];
      if (authUrl == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get payment URL'),
            backgroundColor: AppColors.redFF6B6B,
          ),
        );
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
      }
      
      final uri = Uri.parse(authUrl);
      final launched = await url_launcher.launchUrl(
        uri,
        mode: url_launcher.LaunchMode.externalApplication,
      );
      
      if (launched) {
        await _fetchSubscriptionStatus();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch payment URL'),
            backgroundColor: AppColors.redFF6B6B,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: AppColors.redFF6B6B,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: const CustomAppBar(
        title: 'Subscription',
        backgroundColor: AppColors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _subscriptionStatus == SubscriptionStatus.active &&
                  _currentPlan != null
              ? _buildActiveSubscriptionView()
              : _buildNoSubscriptionView(),
    );
  }

  Widget _buildActiveSubscriptionView() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Active Subscription Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You're currently subscribed",
                          style: AppTypography.body.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.blueGray374957,
                          ),
                        ),
                        SizedBox(height: 1.2.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 1.w,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 0.6.h,
                              ),
                              decoration: BoxDecoration(
                                color: _planColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _planLabel,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.blueGray374957,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 0.6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grayF9,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _expiryText,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.blueGray374957,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  SizedBox(
                    height: 12.h,
                    width: 18.w,
                    child: SvgPicture.asset(
                      'assets/images/cheers.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Show all available plans
            _SubscriptionCard(
              plan: SubscriptionPlan.basic,
              title: 'Basic',
              multiplier: '1.5x',
              price: '₵ 567',
              originalPrice: '₵ 567',
              features: [
                'Share limited number of ads',
                'All ads stays promoted for a week',
              ],
              isSelected: _selectedPlan == SubscriptionPlan.basic,
              isCurrentPlan: _currentPlan == SubscriptionPlan.basic,
              onTap: () => _selectPlan(SubscriptionPlan.basic),
              hasDiscount: _selectedPlan == SubscriptionPlan.basic,
              discountText: _selectedPlan == SubscriptionPlan.basic
                  ? 'For you 50% off'
                  : null,
            ),

            SizedBox(height: 2.h),

            _SubscriptionCard(
              plan: SubscriptionPlan.business,
              title: 'Business',
              multiplier: '4x',
              price: '₵ 567',
              originalPrice: '₵ 567',
              features: [
                'Pro partnership status',
                'All ads stay promoted for 2 weeks',
              ],
              isSelected: _selectedPlan == SubscriptionPlan.business,
              isCurrentPlan: _currentPlan == SubscriptionPlan.business,
              onTap: () => _selectPlan(SubscriptionPlan.business),
              hasDiscount: _selectedPlan == SubscriptionPlan.business,
              discountText: _selectedPlan == SubscriptionPlan.business
                  ? 'For you 50% off'
                  : null,
            ),

            SizedBox(height: 2.h),

            _SubscriptionCard(
              plan: SubscriptionPlan.platinum,
              title: 'Platinum',
              multiplier: '10x',
              price: '₵ 567',
              originalPrice: '₵ 567',
              features: [
                'Unlimited number of ads',
                'Sell 10x faster in all categories',
              ],
              isSelected: _selectedPlan == SubscriptionPlan.platinum,
              isCurrentPlan: _currentPlan == SubscriptionPlan.platinum,
              onTap: () => _selectPlan(SubscriptionPlan.platinum),
              hasDiscount: _selectedPlan == SubscriptionPlan.platinum,
              discountText: _selectedPlan == SubscriptionPlan.platinum
                  ? 'For you 50% off'
                  : null,
            ),

            SizedBox(height: 4.h),

            CustomButton.filled(
              label: 'Upgrade Plan',
              onPressed: _loading ? null : _handlePayment,
              backgroundColor: AppColors.white,
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSubscriptionView() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Choose a monthly plan that works for you',
              style: AppTypography.body.copyWith(
                fontSize: 16.sp,
                color: AppColors.blueGray374957.withValues(alpha: 0.54),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            _SubscriptionCard(
              plan: SubscriptionPlan.basic,
              title: 'Basic',
              multiplier: '1.5x',
              price: '₵ 567',
              originalPrice: '₵ 567',
              features: [
                'Share limited number of ads',
                'All ads stays promoted for a week',
              ],
              isSelected: _selectedPlan == SubscriptionPlan.basic,
              isCurrentPlan: false,
              onTap: () => _selectPlan(SubscriptionPlan.basic),
              hasDiscount: _selectedPlan == SubscriptionPlan.basic,
              discountText: _selectedPlan == SubscriptionPlan.basic
                  ? 'For you 50% off'
                  : null,
            ),
            SizedBox(height: 2.h),
            _SubscriptionCard(
              plan: SubscriptionPlan.business,
              title: 'Business',
              multiplier: '4x',
              price: '₵ 567',
              originalPrice: '₵ 567',
              features: [
                'Pro partnership status',
                'All ads stay promoted for 2 weeks',
              ],
              isSelected: _selectedPlan == SubscriptionPlan.business,
              isCurrentPlan: false,
              onTap: () => _selectPlan(SubscriptionPlan.business),
              hasDiscount: _selectedPlan == SubscriptionPlan.business,
              discountText: _selectedPlan == SubscriptionPlan.business
                  ? 'For you 50% off'
                  : null,
            ),
            SizedBox(height: 2.h),
            _SubscriptionCard(
              plan: SubscriptionPlan.platinum,
              title: 'Platinum',
              multiplier: '10x',
              price: '₵ 567',
              originalPrice: '₵ 567',
              features: [
                'Unlimited number of ads',
                'Sell 10x faster in all categories',
              ],
              isSelected: _selectedPlan == SubscriptionPlan.platinum,
              isCurrentPlan: false,
              onTap: () => _selectPlan(SubscriptionPlan.platinum),
              hasDiscount: _selectedPlan == SubscriptionPlan.platinum,
              discountText: _selectedPlan == SubscriptionPlan.platinum
                  ? 'For you 50% off'
                  : null,
            ),
            SizedBox(height: 4.h),
            CustomButton.filled(
              label: 'Pay Now',
              onPressed: _loading ? null : _handlePayment,
              backgroundColor: AppColors.white,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final String title;
  final String multiplier;
  final String price;
  final String originalPrice;
  final List<String> features;
  final bool isSelected;
  final bool isCurrentPlan;
  final VoidCallback onTap;
  final bool hasDiscount;
  final String? discountText;

  const _SubscriptionCard({
    required this.plan,
    required this.title,
    required this.multiplier,
    required this.price,
    required this.originalPrice,
    required this.features,
    required this.isSelected,
    required this.onTap,
    this.isCurrentPlan = false,
    this.hasDiscount = false,
    this.discountText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected || isCurrentPlan
                    ? AppColors.blueGray374957
                    : Colors.transparent,
                width: isSelected || isCurrentPlan ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueGray374957,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grayF9,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        multiplier,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueGray374957,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                ...features.map((feature) => Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check,
                            size: 18,
                            color: AppColors.blueGray374957,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.blueGray374957
                                    .withValues(alpha: 0.54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Text(
                      price,
                      style: AppTypography.body.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueGray374957,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      originalPrice,
                      style: AppTypography.body.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.gray8B959E,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.gray8B959E,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (hasDiscount && discountText != null)
            Positioned(
              top: -10,
              right: 40,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 0.8.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blueGray374957,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  discountText!,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFFDEFEED),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
