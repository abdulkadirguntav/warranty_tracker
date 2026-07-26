import '../../l10n/app_localizations.dart';

/// Predefined product categories used when creating a warranty item.
///
/// The [label] field is the canonical, persisted English string and is
/// stored inside [WarrantyItem.brandCategory]. Display strings come from
/// [localizedName] so the UI can show localized category names while the
/// underlying data layer stays stable.
enum BrandCategory {
  electronics('Electronics'),
  homeAppliance('Home Appliance'),
  mobile('Mobile / Tablet'),
  computer('Computer / Laptop'),
  audioVideo('Audio / Video'),
  kitchen('Kitchen'),
  tools('Tools / Hardware'),
  furniture('Furniture'),
  automotive('Automotive'),
  other('Other');

  final String label;
  const BrandCategory(this.label);

  static List<BrandCategory> get all => BrandCategory.values;

  /// Returns the localized display name for this category.
  String localizedName(AppLocalizations l) {
    switch (this) {
      case BrandCategory.electronics:
        return l.catElectronics();
      case BrandCategory.homeAppliance:
        return l.catHomeAppliance();
      case BrandCategory.mobile:
        return l.catMobile();
      case BrandCategory.computer:
        return l.catComputer();
      case BrandCategory.audioVideo:
        return l.catAudioVideo();
      case BrandCategory.kitchen:
        return l.catKitchen();
      case BrandCategory.tools:
        return l.catTools();
      case BrandCategory.furniture:
        return l.catFurniture();
      case BrandCategory.automotive:
        return l.catAutomotive();
      case BrandCategory.other:
        return l.catOther();
    }
  }

  /// Finds a [BrandCategory] from a possibly-localized label, falling
  /// back to the English [label] for backwards compatibility.
  static BrandCategory fromAnyLabel(String text, AppLocalizations l) {
    for (final c in BrandCategory.all) {
      if (c.label == text || c.localizedName(l) == text) return c;
    }
    return BrandCategory.other;
  }

  /// All known localized display names for this category (EN + TR),
  /// excluding the canonical [label]. Used by search filters that run
  /// outside of a [BuildContext] to match user queries written in any
  /// supported language.
  List<String> get allLocalizedNames {
    switch (this) {
      case BrandCategory.electronics:
        return const ['Electronics', 'Elektronik'];
      case BrandCategory.homeAppliance:
        return const ['Home Appliance', 'Ev Aleti'];
      case BrandCategory.mobile:
        return const ['Mobile / Tablet', 'Mobil / Tablet'];
      case BrandCategory.computer:
        return const ['Computer / Laptop', 'Bilgisayar / Dizüstü'];
      case BrandCategory.audioVideo:
        return const ['Audio / Video', 'Ses / Görüntü'];
      case BrandCategory.kitchen:
        return const ['Kitchen', 'Mutfak'];
      case BrandCategory.tools:
        return const ['Tools / Hardware', 'Aletler / Donanım'];
      case BrandCategory.furniture:
        return const ['Furniture', 'Mobilya'];
      case BrandCategory.automotive:
        return const ['Automotive', 'Otomotiv'];
      case BrandCategory.other:
        return const ['Other', 'Diğer'];
    }
  }
}
