import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/date_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../services/backup_service.dart';
import '../providers/repository_providers.dart';
import '../providers/theme_provider.dart';
import '../providers/warranty_items_provider.dart';
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
        children: const [
          _AppearanceCard(),
          SizedBox(height: 16),
          _BackupCard(),
        ],
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
                    (m) =>
                        ButtonSegment<ThemeMode>(value: m, icon: Icon(icon(m))),
                  )
                  .toList(),
              selected: {currentMode},
              onSelectionChanged: (s) => notifier.setMode(s.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupCard extends ConsumerStatefulWidget {
  const _BackupCard();

  @override
  ConsumerState<_BackupCard> createState() => _BackupCardState();
}

class _BackupCardState extends ConsumerState<_BackupCard> {
  bool _busy = false;

  Future<BackupService> _backupService() async {
    final repository = await ref.read(warrantyRepositoryProvider.future);
    return BackupService(repository);
  }

  Future<void> _exportBackup() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = AppLocalizations.of(context);
    try {
      final path = await (await _backupService()).exportBackup();
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], text: l.backupExported),
      );
      if (mounted) _showSnack(l.backupExported);
    } catch (_) {
      if (mounted) _showSnack(l.backupExportFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.restoreBackupTitle),
        content: Text(l.restoreBackupBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.restoreBackup),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        allowMultiple: false,
      );
      if (result == null || result.files.single.path == null) return;

      final jsonStr = await File(result.files.single.path!).readAsString();
      final count = await (await _backupService()).importBackup(jsonStr);
      await ref.read(warrantyItemsProvider.notifier).refresh();

      final items = ref.read(warrantyItemsProvider);
      final notifications = await ref.read(notificationServiceProvider.future);
      await notifications.cancelAllNotifications();
      for (final item in items) {
        await notifications.scheduleItemNotifications(item);
      }

      if (mounted) _showSnack(l.backupRestored.withN(count));
    } catch (_) {
      if (mounted) _showSnack(l.backupRestoreFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.backup_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(l.dataBackup, style: theme.textTheme.titleSmall),
              const Spacer(),
              if (_busy)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _BackupTile(
            icon: Icons.ios_share_outlined,
            title: l.exportBackup,
            subtitle: l.exportBackupSubtitle,
            onTap: _busy ? null : _exportBackup,
          ),
          Divider(color: theme.dividerColor),
          _BackupTile(
            icon: Icons.restore_outlined,
            title: l.restoreBackup,
            subtitle: l.restoreBackupSubtitle,
            onTap: _busy ? null : _restoreBackup,
          ),
        ],
      ),
    );
  }
}

class _BackupTile extends StatelessWidget {
  const _BackupTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: onTap != null,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
