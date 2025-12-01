import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/usecase/usecase.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/features/auth/domain/usecases/get_cached_session_usecase.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _circleController;
  late AnimationController _textController;

  late Animation<double> _backgroundRevealAnimation;
  late Animation<double> _bigCircleAnimation;
  late Animation<double> _smallCircleAnimation;
  late Animation<double> _bigCircleSlideAnimation;
  late Animation<double> _smallCircleSlideAnimation;
  late Animation<double> _textRevealAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _circleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _bigCircleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _smallCircleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _bigCircleSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _smallCircleSlideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _textRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await _backgroundController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _circleController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    await _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final GetCachedSessionUseCase getCachedSession =
        sl<GetCachedSessionUseCase>();
    final session = await getCachedSession(const NoParams());

    if (!mounted) return;
    final String destination = session == null
        ? AppRoutePaths.onboarding
        : AppRoutePaths.dashboardHome;
    context.go(destination);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _circleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _circleController,
          _textController,
        ]),
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(color: AppColors.white),
              ClipPath(
                clipper: _CircularRevealClipper(
                  _backgroundRevealAnimation.value,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppColors.primary,
                ),
              ),
              Center(
                child: SizedBox(
                  width: 55.w,
                  height: 55.w,
                  child: Stack(
                    children: [
                      // Large outer circle (blue-gray)
                      Positioned(
                        left: 5.w + (_bigCircleSlideAnimation.value * 4.w),
                        top: 5.w,
                        child: Transform.scale(
                          scale: _bigCircleAnimation.value,
                          child: Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.blueGray374957,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 6.w +
                            20.w -
                            16.w +
                            (_smallCircleSlideAnimation.value * 3.w),
                        top: 9.w + 22.w - 16.w,
                        child: Transform.scale(
                          scale: _smallCircleAnimation.value,
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10.h,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRect(
                    child: AnimatedBuilder(
                      animation: _textRevealAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            (1 - _textRevealAnimation.value) * -50.w,
                            0,
                          ),
                          child: Opacity(
                            opacity: _textOpacityAnimation.value,
                            child: Text(
                              'Oysloe',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blueGray374957,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  final double animationValue;

  _CircularRevealClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    final path = Path();

    final center = Offset(size.width / 2, size.height);
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    final currentRadius = maxRadius * animationValue;

    path.addOval(Rect.fromCircle(center: center, radius: currentRadius));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is _CircularRevealClipper &&
        oldClipper.animationValue != animationValue;
  }
}
