import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/warranty_calculator.dart';
import '../../l10n/app_localizations.dart';

/// Compact pill that displays the warranty status using the app's color
/// system ([AppTheme.levelColor]).
///
/// Green  → Active
/// Amber  → Expiring soon (< 3 months)
/// Red    → Expired
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.endDate,
    this.compact = false,
    this.showRemaining = false,
  });

  final DateTime endDate;
  final bool compact;
  final bool showRemaining;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final level = WarrantyCalculator.level(endDate: endDate);
    final color = AppTheme.levelColor(level);
    final label = switch (level) {
      WarrantyLevel.active => l.statusActive,
      WarrantyLevel.expiringSoon => l.statusExpiringSoon,
      WarrantyLevel.expired => l.statusExpired,
    };
    final remaining = DateFormatter.remaining(endDate, l);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            compact || !showRemaining
                ? label
                : '$label · $remaining',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
