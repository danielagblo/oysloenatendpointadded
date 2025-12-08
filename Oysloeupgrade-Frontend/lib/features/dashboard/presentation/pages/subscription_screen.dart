import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/common/widgets/buttons.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'dart:async';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/subscription_usecases.dart';
import 'package:intl/intl.dart';

enum SubscriptionStatus { none, active, expired }

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with WidgetsBindingObserver {
  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.none;
  int _daysRemaining = 0;
  int? _currentPlanId;
  String? _currentPlanName;
  String? _currentPlanTier;
  int? _selectedPlanId;
  List<Map<String, dynamic>> _plans = <Map<String, dynamic>>[];
  bool _loading = true;
  String? _userSubscriptionId;
  Timer? _refreshTimer;
  bool _isPollingForPayment = false;

  late final GetUserSubscriptionUseCase _getUserSubscriptionUseCase;
  late final GetAvailableSubscriptionsUseCase _getAvailableSubscriptionsUseCase;
  late final CreateUserSubscriptionUseCase _createUserSubscriptionUseCase;
  late final UpdateUserSubscriptionUseCase _updateUserSubscriptionUseCase;
  late final InitializePaystackPaymentUseCase _initializePaystackPaymentUseCase;

  Color _tierColor(String? tier) {
    final normalized = tier?.toLowerCase() ?? '';
    if (normalized.contains('plat')) return const Color(0xFFFF6B6B);
    if (normalized.contains('bus')) return const Color(0xFF00FFF2);
    return const Color(0xFF74FFA7);
  }

  String get _planLabel {
    if (_currentPlanName != null && _currentPlanName!.isNotEmpty) {
      // Format: "Basic Promo" -> "Basic package", "Business" -> "Business package"
      final name = _currentPlanName!.toLowerCase();
      if (name.contains('basic')) return 'Basic package';
      if (name.contains('business')) return 'Business package';
      if (name.contains('platinum')) return 'Platinum package';
      return '$_currentPlanName package';
    }
    return 'Subscription';
  }

  String get _expiryText {
    if (_daysRemaining > 0) {
      return 'Expires in $_daysRemaining days';
    }
    return 'Active plan';
  }

  int _calculateDaysRemaining(String? endDateStr) {
    if (endDateStr == null || endDateStr.isEmpty) return 0;
    try {
      final endDate = DateTime.parse(endDateStr);
      final now = DateTime.now();
      final difference = endDate.difference(now).inDays;
      return difference > 0 ? difference : 0;
    } catch (_) {
      return 0;
    }
  }

  Map<String, dynamic> _normalizeUserSubscriptionData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    return <String, dynamic>{};
  }

  Future<void> _fetchAvailablePlans() async {
    try {
      final subs = await _getAvailableSubscriptionsUseCase();
      _plans = subs.cast<Map<String, dynamic>>();
    } catch (_) {
      _plans = <Map<String, dynamic>>[];
    }
  }

  String? _extractPaymentUrl(Map<String, dynamic> response) {
    final visited = <int>{};

    String? Function(dynamic node)? walk;

    String? pick(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.startsWith('http')) return s;

      // Try to parse JSON-encoded raw_response strings that may contain a URL.
      if (s.contains('{') && s.contains('}')) {
        try {
          final decoded = jsonDecode(s);
          final nested = walk?.call(decoded);
          if (nested != null) return nested;
        } catch (_) {
          // ignore malformed JSON strings
        }
      }
      return null;
    }

    walk = (dynamic node) {
      if (node == null) return null;
      final id = identityHashCode(node);
      if (visited.contains(id)) return null;
      visited.add(id);

      if (node is Map) {
        for (final entry in node.entries) {
          final key = entry.key.toString().toLowerCase();
          final value = entry.value;
          // direct string value candidates
          if (['authorization_url', 'payment_url', 'checkout_url', 'url']
                  .contains(key) ||
              key.contains('authorization') ||
              key.contains('payment') ||
              key.contains('checkout')) {
            final hit = pick(value);
            if (hit != null) return hit;
          }
          // nested search
          final nested = walk?.call(value);
          if (nested != null) return nested;
        }
      } else if (node is Iterable) {
        for (final item in node) {
          final nested = walk?.call(item);
          if (nested != null) return nested;
        }
      } else {
        final hit = pick(node);
        if (hit != null) return hit;
      }
      return null;
    };

    return walk?.call(response);
  }

  List<Widget> _buildPlanCards() {
    if (_plans.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'No plans available. Please try again later.',
            style: AppTypography.body.copyWith(
              color: AppColors.blueGray374957,
            ),
          ),
        ),
      ];
    }

    return _plans
        .map(
          (plan) => Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: _SubscriptionCard(
              id: int.tryParse(plan['id'].toString()) ?? plan['id'] as int,
              title: plan['name']?.toString() ?? 'Plan',
              tier: plan['tier']?.toString(),
              multiplier: plan['multiplier']?.toString(),
              price: plan['effective_price']?.toString() ?? plan['price']?.toString() ?? '',
              originalPrice: plan['original_price']?.toString() ?? '',
              features: _extractFeatures(plan),
              isSelected:
                  _selectedPlanId != null &&
                  _selectedPlanId ==
                      (int.tryParse(plan['id'].toString()) ??
                          plan['id'] as int),
              isCurrentPlan: _currentPlanId != null &&
                  _currentPlanId ==
                      (int.tryParse(plan['id'].toString()) ??
                          plan['id'] as int),
              onTap: () {
                final id =
                    int.tryParse(plan['id'].toString()) ?? plan['id'] as int;
                _selectPlan(id);
              },
              badgeText: plan['discount_percentage'] != null &&
                      plan['discount_percentage'].toString().isNotEmpty
                  ? '${plan['discount_percentage']}% off'
                  : null,
            ),
          ),
        )
        .toList();
  }

  List<String> _extractFeatures(Map<String, dynamic> plan) {
    if (plan['features_list'] is List) {
      return (plan['features_list'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (plan['features'] is String) {
      return plan['features']
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getUserSubscriptionUseCase = sl<GetUserSubscriptionUseCase>();
    _getAvailableSubscriptionsUseCase = sl<GetAvailableSubscriptionsUseCase>();
    _createUserSubscriptionUseCase = sl<CreateUserSubscriptionUseCase>();
    _updateUserSubscriptionUseCase = sl<UpdateUserSubscriptionUseCase>();
    _initializePaystackPaymentUseCase = sl<InitializePaystackPaymentUseCase>();
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh subscription status when app comes back to foreground
    // (e.g., after returning from Paystack payment)
    if (state == AppLifecycleState.resumed) {
      _fetchSubscriptionStatus();
      _stopPolling();
    }
  }

  void _startPollingForPayment() {
    _isPollingForPayment = true;
    _refreshTimer?.cancel();
    debugPrint('Starting payment polling...');
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isPollingForPayment || !mounted) {
        timer.cancel();
        return;
      }
      
      // Check if subscription became active
      final previousStatus = _subscriptionStatus;
      final previousPlanId = _currentPlanId;
      final previousIsActive = previousStatus == SubscriptionStatus.active;
      
      debugPrint('Polling: Checking subscription status (previous: $previousStatus, plan: $previousPlanId)');
      
      // Don't set loading during polling to avoid UI flicker
      await _fetchSubscriptionStatus();
      await _fetchAvailablePlans();
      
      if (mounted) {
        setState(() {});
      }
      
      debugPrint('Polling: Current status: $_subscriptionStatus, plan: $_currentPlanId, active: ${_subscriptionStatus == SubscriptionStatus.active}');
      
      // If subscription became active, stop polling and show success
      final currentIsActive = _subscriptionStatus == SubscriptionStatus.active;
      if (mounted && 
          !previousIsActive && 
          currentIsActive) {
        _stopPolling();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Subscription activated.'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      // Also check if plan changed (upgrade scenario)
      if (mounted && 
          currentIsActive && 
          _currentPlanId != null &&
          _currentPlanId != previousPlanId &&
          previousPlanId != null) {
        _stopPolling();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription upgraded successfully!'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      // Stop polling after 2 minutes
      if (timer.tick >= 24) { // 24 * 5 seconds = 2 minutes
        _stopPolling();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment verification timeout. Please refresh manually if payment was successful.'),
              backgroundColor: AppColors.blueGray374957,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    });
  }

  void _stopPolling() {
    _isPollingForPayment = false;
    _refreshTimer?.cancel();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await Future.wait<void>([
      _fetchAvailablePlans(),
      _fetchSubscriptionStatus(),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _fetchSubscriptionStatus() async {
    try {
      final data = await _getUserSubscriptionUseCase();
      final normalized = _normalizeUserSubscriptionData(data);
      _userSubscriptionId = normalized['id']?.toString();

      final subscriptionMap =
          normalized['subscription'] is Map<String, dynamic> ? normalized['subscription'] as Map<String, dynamic> : null;

      final newPlanId = subscriptionMap?['id'] as int?;
      final newPlanName = subscriptionMap?['name']?.toString();
      final newPlanTier = subscriptionMap?['tier']?.toString();
      
      // Update plan info
      _currentPlanId = newPlanId;
      _currentPlanName = newPlanName;
      _currentPlanTier = newPlanTier;
      _selectedPlanId ??= _currentPlanId;

      final wasActive = _subscriptionStatus == SubscriptionStatus.active;
      
      if (normalized['is_active'] == true) {
        _subscriptionStatus = SubscriptionStatus.active;
        // Calculate days remaining from end_date if days_remaining is not provided
        _daysRemaining = normalized['days_remaining'] as int? ?? 
                        _calculateDaysRemaining(normalized['end_date']?.toString());
      } else {
        _subscriptionStatus = SubscriptionStatus.none;
        _daysRemaining = 0;
      }
      
      // Always update UI after fetching status
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Don't reset status on error during polling - might be temporary
      if (!_isPollingForPayment) {
        _subscriptionStatus = SubscriptionStatus.none;
        _daysRemaining = 0;
      }
      debugPrint('Error fetching subscription status: $e');
    }
  }

  void _selectPlan(int planId) {
    setState(() {
      _selectedPlanId = planId;
    });
  }

  Future<void> _handlePayment() async {
    final selectedPlanId = _selectedPlanId ?? _currentPlanId;
    if (selectedPlanId == null) {
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
      final subs = _plans.isNotEmpty ? _plans : await _getAvailableSubscriptionsUseCase();
      final selectedSub = subs.cast<Map<String, dynamic>?>().firstWhere(
            (s) => s != null && int.tryParse(s['id'].toString()) == selectedPlanId,
            orElse: () => null,
          );

      if (selectedSub == null || selectedSub['id'] == null) {
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

      final int subscriptionId = int.tryParse(selectedSub['id'].toString()) ??
          (selectedSub['id'] as int);
      const callbackUrl = 'https://oysloe.com/payment/callback';
      
      // Get plan price for Paystack - use effective_price (actual amount after discount)
      // If effective_price is not available, use price
      final effectivePrice = selectedSub['effective_price']?.toString();
      final basePrice = selectedSub['price']?.toString();
      final planPrice = effectivePrice ?? basePrice ?? '0';
      final planPriceDouble = double.tryParse(planPrice) ?? 0.0;
      
      // Initialize Paystack payment for all plans
      final paystackResponse = await _initializePaystackPaymentUseCase(
        InitializePaystackPaymentParams(
          subscriptionId: subscriptionId,
          callbackUrl: callbackUrl,
          amount: planPriceDouble > 0 ? planPrice : null,
        ),
      );

      // Extract payment URL from Paystack response
      final paymentUrl = _extractPaymentUrl(paystackResponse);
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        final uri = Uri.parse(paymentUrl);
        final launched = await url_launcher.launchUrl(
          uri,
          mode: url_launcher.LaunchMode.externalApplication,
        );

        if (launched) {
          // Show message that payment is processing
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Redirecting to payment... Complete payment and return to see your subscription activated.'),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 4),
              ),
            );
          }
          // Start polling for payment completion
          _startPollingForPayment();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch payment URL'),
              backgroundColor: AppColors.redFF6B6B,
            ),
          );
        }
      } else {
        // If no payment URL (free plan), create subscription directly
        Map<String, dynamic> response;
        final bool canUpdateExisting =
            _subscriptionStatus == SubscriptionStatus.active &&
                _userSubscriptionId != null;

        if (canUpdateExisting) {
          response = await _updateUserSubscriptionUseCase(
            UpdateUserSubscriptionParams(
              userSubscriptionId: _userSubscriptionId!,
              subscriptionId: subscriptionId,
              callbackUrl: callbackUrl,
            ),
          );
        } else {
          response = await _createUserSubscriptionUseCase(
            CreateUserSubscriptionParams(
              subscriptionId: subscriptionId,
              callbackUrl: callbackUrl,
            ),
          );
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription activated successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
          await _fetchSubscriptionStatus();
          // Reload plans to ensure UI is up to date
          await _fetchAvailablePlans();
          if (mounted) {
            setState(() {});
          }
        }
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

  Future<void> _handleRefresh() async {
    setState(() => _loading = true);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: CustomAppBar(
        title: 'Subscription',
        backgroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _handleRefresh,
            tooltip: 'Refresh subscription status',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _subscriptionStatus == SubscriptionStatus.active &&
                  _currentPlanId != null
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
                                color: _tierColor(_currentPlanTier),
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

            // Show all available plans from backend
            ..._buildPlanCards(),

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
            ..._buildPlanCards(),
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
  final int id;
  final String title;
  final String? tier;
  final String? multiplier;
  final String price;
  final String originalPrice;
  final List<String> features;
  final bool isSelected;
  final bool isCurrentPlan;
  final VoidCallback onTap;
  final String? badgeText;

  const _SubscriptionCard({
    required this.id,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.features,
    required this.isSelected,
    required this.onTap,
    this.tier,
    this.multiplier,
    this.isCurrentPlan = false,
    this.badgeText,
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
                    if (tier != null && tier!.isNotEmpty)
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
                          tier!,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueGray374957,
                          ),
                        ),
                      ),
                    if (multiplier != null && multiplier!.isNotEmpty) ...[
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
                          multiplier!,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueGray374957,
                          ),
                        ),
                      ),
                    ],
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
                      _formatPrice(price),
                      style: AppTypography.body.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueGray374957,
                      ),
                    ),
                    if (originalPrice.isNotEmpty &&
                        originalPrice != price) ...[
                      SizedBox(width: 3.w),
                      Text(
                        _formatPrice(originalPrice),
                        style: AppTypography.body.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.gray8B959E,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.gray8B959E,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (badgeText != null && badgeText!.isNotEmpty)
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
              badgeText!,
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

  String _formatPrice(String value) {
    final clean = value.isEmpty ? '0' : value;
    return '₵ $clean';
  }
}
