import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../widgets/section_card.dart';

/// Appearance (theme) screen.
///
/// A minimal settings page that lets the user pick the app theme
/// (light / dark / system). The theme picker is rendered as a
/// [SegmentedButton] that shows only icons (no text labels) so the
/// control stays compact and does not overflow on narrow screens or in
/// other languages where the "System default" literal is long.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.appearance)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: const [_AppearanceCard()],
      ),
    );
  }
}

class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final currentMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final theme = Theme.of(context);

    IconData icon(ThemeMode mode) => switch (mode) {
          ThemeMode.light => Icons.light_mode_outlined,
          ThemeMode.dark => Icons.dark_mode_outlined,
          ThemeMode.system => Icons.brightness_auto_outlined,
        };

    return SectionCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(l.appearance, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 14),
            SegmentedButton<ThemeMode>(
              segments: ThemeMode.values
                  .map(
                    (m) => ButtonSegment<ThemeMode>(
                      value: m,
                      icon: Icon(icon(m)),
                    ),
                  )
                  .toList(),
              selected: {currentMode},
              onSelectionChanged: (s) => notifier.setMode(s.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
