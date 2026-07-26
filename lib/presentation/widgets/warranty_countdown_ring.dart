import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/warranty_calculator.dart';
import '../../domain/entities/warranty_item.dart';
import '../../l10n/app_localizations.dart';

/// A circular countdown badge showing the remaining warranty days.
///
/// Visual style: minimal circle with a colored progress arc that
/// shrinks as the warranty runs out, centered text showing the days
/// remaining ("120 days"). The color reflects the warranty status:
/// * Active → teal/green
/// * Expiring soon → amber/orange
/// * Expired → red, ring is empty / 0
///
/// Use [WarrantyCountdownRing.compact] inside product cards and
/// [WarrantyCountdownRing] with a larger [size] on the details screen.
class WarrantyCountdownRing extends StatelessWidget {
  const WarrantyCountdownRing({
    super.key,
    required this.item,
    this.size = 96,
    this.strokeWidth,
    this.trackWidth,
    this.showLabel = true,
    this.daysValue,
  }) : compact = false;

  /// Compact variant for use inside list cards.
  const WarrantyCountdownRing.compact({
    super.key,
    required this.item,
    this.size = 56,
    this.strokeWidth,
    this.trackWidth,
    this.showLabel = false,
    this.daysValue,
  }) : compact = true;

  /// The warranty item to visualize.
  final WarrantyItem item;

  /// Outer diameter of the ring in logical pixels.
  final double size;

  /// Optional override for the colored arc thickness. Defaults to a
  /// size-relative width so the ring stays proportional.
  final double? strokeWidth;

  /// Optional override for the track (background ring) thickness.
  final double? trackWidth;

  /// When true, shows a small label below the day count.
  final bool showLabel;

  /// Optionally supply the remaining days explicitly. Defaults to the
  /// item's [WarrantyItem.remainingDays], clamped to >= 0 for display.
  final int? daysValue;

  /// Whether the widget is rendered in compact mode.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final level = WarrantyCalculator.level(endDate: item.effectiveEndDate);
    final color = AppTheme.levelColor(level);
    final trackColor = color.withValues(alpha: 0.14);

    final days = daysValue ?? item.remainingDays;
    final displayDays = days < 0 ? 0 : days;
    final fraction = WarrantyCalculator.remainingFraction(
      purchaseDate: item.purchaseDate,
      endDate: item.effectiveEndDate,
    ).clamp(0.0, 1.0);

    final arcWidth = (strokeWidth ?? size * 0.09).clamp(3.0, 18.0);
    final baseWidth = (trackWidth ?? arcWidth).clamp(2.0, 18.0);

    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RingPainter(
                fraction: 1.0,
                color: trackColor,
                strokeWidth: baseWidth,
                startAngle: -math.pi / 2,
                sweep: math.pi * 2,
                roundedCaps: true,
              ),
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RingPainter(
                fraction: fraction,
                color: color,
                strokeWidth: arcWidth,
                startAngle: -math.pi / 2,
                roundedCaps: true,
                glow: !compact,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.08),
            child: _RingCenter(
              item: item,
              days: displayDays,
              color: color,
              compact: compact,
              showLabel: showLabel,
              theme: theme,
              context: context,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingCenter extends StatelessWidget {
  const _RingCenter({
    required this.item,
    required this.days,
    required this.color,
    required this.compact,
    required this.showLabel,
    required this.theme,
    required this.context,
  });

  final WarrantyItem item;
  final int days;
  final Color color;
  final bool compact;
  final bool showLabel;
  final ThemeData theme;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(this.context);

    if (compact) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$days',
            maxLines: 1,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            l.daysUnit,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.85),
              fontSize: 9,
              height: 1.0,
              letterSpacing: 0.4,
            ),
          ),
        ],
      );
    }

    final labelText = DateFormatter.remaining(item.effectiveEndDate, l);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          maxLines: 1,
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: '$days',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  fontSize: 28,
                  fontFeatures: const [ui.FontFeature.tabularFigures()],
                ),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: l.daysUnit,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 2),
          Text(
            labelText,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}

/// Paints a partial ring given a [fraction] of the full 360° sweep.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    this.sweep = math.pi * 2,
    this.roundedCaps = false,
    this.glow = false,
  });

  final double fraction;
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweep;
  final bool roundedCaps;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth / 2;
    if (radius <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = roundedCaps ? StrokeCap.round : StrokeCap.butt;

    if (glow) {
      final outerPaint = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweep * fraction,
        false,
        outerPaint,
      );
    }

    // Avoid zero-length arc which can still draw a dot.
    if (fraction > 0) {
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweep * fraction,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) {
    return old.fraction != fraction ||
        old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.startAngle != startAngle ||
        old.sweep != sweep ||
        old.glow != glow;
  }
}
