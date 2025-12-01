import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';

class AdaptiveProgressIndicator extends StatelessWidget {
  const AdaptiveProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {

    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueGray263238),
          strokeWidth: 3,
        ),
      ),
    );
  }
}
