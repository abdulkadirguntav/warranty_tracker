import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A flat, bordered card with a consistent premium look used across
/// the redesigned screens. Wraps a single child with padding by default.
///
/// Unlike Material's default [Card], this variant uses a fixed 1px
/// outline (no drop shadow) so it reads as calm, organized, and
/// modern — closer to a "vault" panel than a stack of cards.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accentColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: card,
      ),
    );
  }
}
