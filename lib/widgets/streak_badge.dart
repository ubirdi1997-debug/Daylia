import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool large;

  const StreakBadge({super.key, required this.streak, this.large = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = large ? 60.0 : 40.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warningLight.withOpacity(0.8),
            AppColors.warningLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.warningLight.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          Text(
            streak.toString(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: large ? 16 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
