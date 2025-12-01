import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/alerts_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/home_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/inbox_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/pages/post_ad_upload_images_screen.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/bottom_navigation.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final bool isAuthenticated = _isAuthenticated();
    _pages = [
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<ProductsCubit>()..fetch(),
          ),
          BlocProvider(
            create: (_) => sl<CategoriesCubit>()..fetch(),
          ),
        ],
        child: const AnimatedHomeScreen(),
      ),
      const AlertsScreen(),
      if (isAuthenticated) const PostAdUploadImagesScreen(),
      const InboxScreen(),
    ];
  }

  bool _isAuthenticated() {
    // TODO: Replace with your actual authentication check
    // For now, always return false (guest mode)
    // Example: return sl<AuthRepository>().isLoggedIn;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
