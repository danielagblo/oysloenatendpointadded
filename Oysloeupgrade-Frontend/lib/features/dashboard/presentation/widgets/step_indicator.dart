import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/constants/body_paddings.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  final int currentStep; // 1-based
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.black26;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: BodyPaddings.horizontalPage.horizontal,
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            _StepChip(
              index: i + 1,
              label: labels[i],
              state: (i + 1) < currentStep
                  ? _StepState.completed
                  : (i + 1) == currentStep
                      ? _StepState.active
                      : _StepState.upcoming,
            ),
            if (i != labels.length - 1)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  height: 1,
                  color: dividerColor,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

enum _StepState { active, completed, upcoming }

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.index,
    required this.label,
    required this.state,
  });

  final int index;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final bool isActive = state == _StepState.active;
    final bool isCompleted = state == _StepState.completed;

    final Color fillColor;
    final Color circleBorderColor;
    final Color textColor;

    if (isActive) {
      fillColor = AppColors.primary;
      circleBorderColor = AppColors.primary;
      textColor = AppColors.blueGray374957;
    } else if (isCompleted) {
      fillColor = AppColors.white;
      circleBorderColor = AppColors.white;
      textColor = AppColors.blueGray374957;
    } else {
      fillColor = AppColors.white;
      circleBorderColor = AppColors.blueGray374957.withValues(alpha: 0.18);
      textColor = AppColors.gray8B959E;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: fillColor,
            shape: BoxShape.circle,
            border: Border.all(color: circleBorderColor, width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: AppTypography.bodySmall.copyWith(
              color: isActive ? AppColors.blueGray374957 : AppColors.gray8B959E,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
