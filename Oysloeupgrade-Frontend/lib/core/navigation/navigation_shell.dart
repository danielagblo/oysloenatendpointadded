import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/navigation/navigation_state.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/alerts/alerts_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/alerts/alerts_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/bottom_navigation.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/profile_menu_drawer.dart';

class NavigationShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const NavigationShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  late NavigationState _navigationState;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _forcedIndex; // When end drawer is open, highlight Profile tab
  int _drawerKey = 0; // Force drawer rebuild on open

  @override
  void initState() {
    super.initState();
    _navigationState = NavigationState();
    _navigationState.setCurrentIndex(widget.currentIndex);
  }

  @override
  void didUpdateWidget(NavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _navigationState.setCurrentIndex(widget.currentIndex);
    }
  }

  Future<bool> _ensureAuthenticated() async {
    final AuthRepository repository = sl<AuthRepository>();
    final session = await repository.cachedSession();
    final bool isLoggedIn = session != null;

    if (!isLoggedIn && mounted) {
      showErrorSnackBar(context, 'Please log in to continue.');
      context.go(AppRoutePaths.login);
    }

    return isLoggedIn;
  }

  Future<void> _onTabTapped(int index) async {
    switch (index) {
      case 0:
        context.go(AppRoutePaths.dashboardHome);
        break;
      case 1:
        if (!await _ensureAuthenticated()) return;
        if (!mounted) return;
        context.go(AppRoutePaths.dashboardAlerts);
        break;
      case 2:
        if (!await _ensureAuthenticated()) return;
        if (!mounted) return;
        context.go(AppRoutePaths.dashboardPostAd);
        break;
      case 3:
        if (!await _ensureAuthenticated()) return;
        if (!mounted) return;
        context.go(AppRoutePaths.dashboardInbox);
        break;
      case 4:
        if (!await _ensureAuthenticated()) return;
        if (!mounted) return;
        // Open the right drawer for Profile instead of navigating
        // If drawer is already open, close it.
        if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
          Navigator.of(context).maybePop();
        } else {
          _scaffoldKey.currentState?.openEndDrawer();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Close end drawer first if it's open
        if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
          Navigator.of(context).maybePop();
          return;
        }

        if (!_navigationState.handleBackPress()) {
          // If we can't pop within the current tab, handle app exit or go to home tab
          if (_navigationState.currentIndex != 0) {
            _onTabTapped(0);
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: widget.child,
        endDrawerEnableOpenDragGesture: false,
        endDrawer: LayoutBuilder(
          builder: (context, constraints) {
            final width = MediaQuery.of(context).size.width * 0.8;
            return SizedBox(
              width: width,
              child: ProfileMenuDrawer(key: ValueKey(_drawerKey)),
            );
          },
        ),
        onEndDrawerChanged: (isOpened) {
          setState(() {
            _forcedIndex = isOpened ? 4 : null;
            if (isOpened) {
              // Force drawer to rebuild with fresh data when opened
              _drawerKey++;
            }
          });
        },
        bottomNavigationBar: BlocBuilder<AlertsCubit, AlertsState>(
          builder: (context, alertsState) {
            // Calculate unread alerts count
            final int unreadCount = alertsState.alerts
                .where((alert) => !alert.isRead)
                .length;

            return ListenableBuilder(
              listenable: _navigationState,
              builder: (context, _) {
                return CustomBottomNavigation(
                  currentIndex: _forcedIndex ?? widget.currentIndex,
                  onTap: (index) => _onTabTapped(index),
                  unreadAlertsCount: unreadCount,
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navigationState.dispose();
    super.dispose();
  }
}
