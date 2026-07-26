import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/warranty_calculator.dart';
import '../../domain/entities/warranty_item.dart';
import '../../l10n/app_localizations.dart';

/// Premium warranty item card.
///
/// Design:
/// * White card with soft shadow (no border).
/// * Left: product image/icon placeholder.
/// * Center: product name, category, expiry date.
/// * Right: colored rounded days-badge (replaces circular ring).
/// * Bottom: colored status pill.
class WarrantyItemCard extends StatelessWidget {
  const WarrantyItemCard({super.key, required this.item});

  final WarrantyItem item;

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final l       = AppLocalizations.of(context);
    final level   = WarrantyCalculator.level(endDate: item.effectiveEndDate);
    final color   = AppTheme.levelColor(level);
    final days    = WarrantyCalculator.remainingDays(item.effectiveEndDate);
    final cat     = _categoryFor(item);
    final isDark  = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('${AppConstants.routeDetails}/${item.id}'),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: isDark ? AppTheme.cardShadowDark : AppTheme.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Product image / icon ───────────────
                _ProductIcon(
                  imagePath: item.productImagePath,
                  icon: cat.icon,
                  color: color,
                ),
                const SizedBox(width: 14),

                // ── Content ───────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.productName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.brandCategory,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatusPill(color: color, level: level, l: l),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              DateFormatter.format(item.effectiveEndDate),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // ── Days badge ────────────────────────
                _DaysBadge(days: days, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static _CatMeta _categoryFor(WarrantyItem item) {
    for (final c in _CatMeta.all) {
      if (c.canonicalLabel == item.brandCategory) return c;
    }
    return _CatMeta.other;
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────

class _ProductIcon extends StatelessWidget {
  const _ProductIcon({
    required this.imagePath,
    required this.icon,
    required this.color,
  });
  final String? imagePath;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync();

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.color,
    required this.level,
    required this.l,
  });
  final Color color;
  final WarrantyLevel level;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final label = switch (level) {
      WarrantyLevel.active       => l.statusActive,
      WarrantyLevel.expiringSoon => l.statusExpiringSoon,
      WarrantyLevel.expired      => l.statusExpired,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded colored badge showing remaining days / years.
class _DaysBadge extends StatelessWidget {
  const _DaysBadge({required this.days, required this.color});
  final int days;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    // Compact, locale-aware label + subtext.
    final String topLabel;
    final String subLabel;

    if (days < 0) {
      topLabel = l.daysBadgeExpired;
      subLabel = '';
    } else if (days == 0) {
      topLabel = l.daysBadgeToday;
      subLabel = '';
    } else if (days > 365) {
      final years = (days / 365).floor();
      topLabel = '$years+';
      subLabel = l.daysBadgeYearsSuffix;
    } else {
      topLabel = '$days';
      subLabel = l.daysBadgeDaysSuffix;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            topLabel,
            style: TextStyle(
              color: color,
              fontSize: topLabel.length > 3 ? 12 : 14,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          if (subLabel.isNotEmpty)
            Text(
              subLabel,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

/// Category metadata for icon lookup.
class _CatMeta {
  final String canonicalLabel;
  final IconData icon;
  const _CatMeta(this.canonicalLabel, this.icon);
  static const _CatMeta other = _CatMeta('Other', Icons.category_outlined);

  static const all = [
    _CatMeta('Electronics', Icons.devices_outlined),
    _CatMeta('Home Appliance', Icons.home_outlined),
    _CatMeta('Mobile / Tablet', Icons.phone_iphone_outlined),
    _CatMeta('Computer / Laptop', Icons.laptop_mac_outlined),
    _CatMeta('Audio / Video', Icons.speaker_outlined),
    _CatMeta('Kitchen', Icons.kitchen_outlined),
    _CatMeta('Tools / Hardware', Icons.build_outlined),
    _CatMeta('Furniture', Icons.chair_outlined),
    _CatMeta('Automotive', Icons.directions_car_outlined),
    _CatMeta('Other', Icons.category_outlined),
  ];
}
