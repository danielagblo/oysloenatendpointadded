import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await initDependencies();

      await Future.wait([
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      ]);

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: AppColors.white,
          systemNavigationBarIconBrightness:
              AppColors.white.computeLuminance() > 0.5
                  ? Brightness.dark
                  : Brightness.light,
        ),
      );

      runApp(const OyesloeMobile());
    },
    (error, stackTrace) {
      debugPrint('Unhandled error: $error');
    },
  );
}

class OyesloeMobile extends StatelessWidget {
  const OyesloeMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp.router(
          title: 'Oysloe Mobile',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          routerConfig: appRouter,
        );
      },
    );
  }
}
