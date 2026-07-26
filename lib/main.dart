import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/notification_init_provider.dart';
import 'presentation/providers/repository_providers.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/routing/app_router.dart';
import 'presentation/widgets/app_logo.dart';

/// Entry point. A [ProviderScope] is required for Riverpod to function.
void main() {
  runApp(const ProviderScope(child: WarrantyTrackerApp()));
}

/// Root widget.
///
/// It waits for the Hive-backed repository to be initialized before
/// rendering the [GoRouter]-powered UI, showing a minimal loading
/// screen in the meantime. It also initializes the notification service.
///
/// Language follows the device locale automatically. Supported locales
/// are English and Turkish; everything else falls back to English.
class WarrantyTrackerApp extends ConsumerWidget {
  const WarrantyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repoReady = ref.watch(warrantyRepositoryProvider);

    // Initialize the notification service on startup.
    ref.watch(notificationInitProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: AppLocalizations.resolutionCallback,
      routerConfig: appRouter,
      builder: (context, child) {
        return repoReady.when(
          loading: () => const _InitializingScreen(),
          error: (error, _) => _InitErrorScreen(error: error),
          data: (_) => child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _InitializingScreen extends StatelessWidget {
  const _InitializingScreen();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 88, withGlow: true),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l.initializing,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InitErrorScreen extends StatelessWidget {
  const _InitErrorScreen({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                l.initFailed,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('$error', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
