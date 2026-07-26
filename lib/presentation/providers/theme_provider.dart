import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Holds the current [ThemeMode] and persists the user's choice locally.
///
/// Defaults to [ThemeMode.system] so the app respects the device setting
/// on first launch. The user can override it from the Account/Settings
/// screen, and the choice is restored on the next launch.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadSavedMode();
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _saveMode(mode);
  }

  Future<void> toggle() async {
    await setMode(switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark  => ThemeMode.light,
      ThemeMode.system => ThemeMode.dark,
    });
  }

  Future<void> _loadSavedMode() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) return;

      final raw = (await file.readAsString()).trim();
      final savedMode = _modeFromName(raw);
      if (savedMode != null) {
        state = savedMode;
      }
    } catch (_) {
      // Keep the default system theme if local settings cannot be read.
    }
  }

  Future<void> _saveMode(ThemeMode mode) async {
    try {
      final file = await _settingsFile();
      await file.parent.create(recursive: true);
      await file.writeAsString(mode.name);
    } catch (_) {
      // Theme changes should still apply even if persistence fails.
    }
  }

  Future<File> _settingsFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/settings/theme_mode.txt');
  }

  ThemeMode? _modeFromName(String name) {
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
