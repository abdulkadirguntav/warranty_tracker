import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

/// Hand-rolled localization delegate so we do not depend on code-gen
/// (flutter gen-l10n). Strings are grouped into [AppLocalizations] which
/// also exposes typed accessors for every user-facing string in the app.
///
/// The locale is automatically resolved from the device locale via
/// [AppLocalizations.delegate] wired into [MaterialApp.localizationsDelegates].
/// Turkish is supported; every other locale falls back to English.
abstract class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  /// The currently active [AppLocalizations], if any.
  /// Falls back to a stub English instance when accessed outside of a
  /// [Localizations] context (e.g. from raw Dart code).
  static AppLocalizations of(BuildContext context) {
    final l = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return l ?? AppLocalizationsEn(const Locale('en'));
  }

  /// Delegate used by [MaterialApp].
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Locales the app ships with. Anything else falls back to English.
  static const supportedLocales = <Locale>[Locale('en'), Locale('tr')];

  /// Returns true when [locale] is one of the supported languages.
  static bool isSupported(Locale locale) {
    return supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  // ── Locale resolution ─────────────────────────────────────────────
  /// Resolves the requested locale to a supported one. English is the
  /// fallback for unsupported languages. If the device locale lists
  /// multiple preferred locales, the first supported match wins.
  static Locale? resolutionCallback(
    Locale? deviceLocale,
    Iterable<Locale> supportedLocales,
  ) {
    if (deviceLocale == null) return const Locale('en');
    for (final candidate in supportedLocales) {
      if (candidate.languageCode == deviceLocale.languageCode) {
        return candidate;
      }
    }
    return const Locale('en');
  }

  // ── Lookup helper ──────────────────────────────────────────────────
  /// Concrete subclasses override this to return the localized value
  /// for [key]. English is the canonical source of truth.
  String get(String key);

  // ── App ────────────────────────────────────────────────────────────
  String get appName;
  String get initializing;
  String get initFailed;

  // ── Generic ────────────────────────────────────────────────────────
  String get cancel;
  String get delete;
  String get save;
  String get saveChanges;
  String get add;
  String get edit;
  String get remove;
  String get ok;
  String get retry;
  String get notFound;
  String get routeNotFound;

  // ── Status ─────────────────────────────────────────────────────────
  String get statusActive;
  String get statusExpiringSoon;
  String get statusExpired;
  String get daysLeft;
  String get oneDayLeft;
  String get expiresToday;
  String get expiredOneDayAgo;
  String get expiredDaysAgo;
  String get daysUnit;

  // ── Dashboard ──────────────────────────────────────────
  String get dashboardTitle;
  String get dashboardSubtitle;
  String get searchHint;
  String get tabAll;
  String get tabExpiring;
  String get tabActive;
  String get tabExpired;
  String get refresh;
  String get summaryTotal;
  String get summaryActive;
  String get summaryExpiring;
  String get summaryExpired;
  String get emptyTitle;
  String get emptyBody;
  String get loadFailed;
  String get deletedItem;
  String get deleteItemTitle;
  String get deleteItemBody;

  // ── Details ────────────────────────────────────────────────────────
  String get detailsTitle;
  String get itemNotFound;
  String get warrantyProgress;
  String get purchaseDate;
  String get warrantyEnd;
  String get effectiveEnd;
  String get duration;
  String get durationMonthsSuffix;
  String get extendedWarranty;
  String get extendedDurationLabel;
  String get extendedEndDateLabel;
  String get effectiveEndDate;
  String get notes;
  String get productPhoto;
  String get productPhotoMissing;
  String get receipt;
  String get receiptImageMissing;
  String get documents;
  String get tapToView;
  String get fileNotFound;
  String get deleteDocumentTitle;
  String get deleteDocumentBody;
  String get serviceHistory;
  String get noServiceRecords;
  String get costLabel;
  String get trackingLabel;
  String get addServiceRecord;
  String get editServiceRecord;
  String get deleteRecordTitle;
  String get deleteRecordBody;
  String get confirmDeleteTitle;
  String get confirmDeleteBody;

  // ── Add / Edit ─────────────────────────────────────────────────────
  String get addWarrantyTitle;
  String get editWarrantyTitle;
  String get sectionProductInfo;
  String get sectionWarrantyInfo;
  String get sectionAttachment;
  String get sectionNotes;
  String get productNameLabel;
  String get productNameHint;
  String get productNameRequired;
  String get categoryLabel;
  String get purchaseDateLabel;
  String get durationLabel;
  String get monthsSuffix;
  String get customDuration;
  String get monthsWord;
  String get extendedWarrantyType;
  String get extendedTypeDuration;
  String get extendedTypeDate;
  String get extendedMonthsLabel;
  String get customExtendedDuration;
  String get extendedEndDateInputLabel;
  String get extendedWarrantyHint;
  String get previewLabel;
  String get warrantyEndsLabel;
  String get effectiveEndsLabel;
  String get notesLabel;
  String get notesHint;
  String get productPhotoOptional;
  String get addProductPhoto;
  String get changePhoto;
  String get addPhoto;
  String get receiptPhotoOptional;
  String get documentsOptional;
  String get documentsHint;
  String get takeWithCamera;
  String get chooseFromGallery;
  String get documentTypeLabel;
  String get docLabelReceipt;
  String get docLabelWarrantyCertificate;
  String get docLabelServiceForm;
  String get docLabelBoxLabel;
  String get docLabelOther;
  String get itemUpdated;
  String get itemAdded;
  String get invalidCost;

  // ── Service record dialog ──────────────────────────────────────────
  String get serviceDateLabel;
  String get serviceCenterLabel;
  String get serviceCenterRequired;
  String get descriptionLabel;
  String get costOptionalLabel;
  String get trackingOptionalLabel;
  String get notesOptionalLabel;

  // ── Days badge (compact card) ───────────────────────────────────────
  String get daysBadgeExpired;
  String get daysBadgeToday;
  String get daysBadgeYearsSuffix;
  String get daysBadgeDaysSuffix;

  // ── Dashboard dismiss ───────────────────────────────────────────────
  String get dismissDeleteLabel;

  // ── Appearance ──────────────────────────────────────────────────────
  String get appearance;
  String get dataBackup;
  String get exportBackup;
  String get restoreBackup;
  String get exportBackupSubtitle;
  String get restoreBackupSubtitle;
  String get backupExported;
  String get backupExportFailed;
  String get backupRestored;
  String get backupRestoreFailed;
  String get restoreBackupTitle;
  String get restoreBackupBody;

  // ── Categories ──────────────────────────────────────────────────────
  String catElectronics();
  String catHomeAppliance();
  String catMobile();
  String catComputer();
  String catAudioVideo();
  String catKitchen();
  String catTools();
  String catFurniture();
  String catAutomotive();
  String catOther();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Initialize intl's default locale so DateFormat / NumberFormat follow
    // the resolved locale automatically.
    Intl.defaultLocale = locale.toLanguageTag();

    switch (locale.languageCode) {
      case 'tr':
        return AppLocalizationsTr(locale);
      default:
        return AppLocalizationsEn(locale);
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
