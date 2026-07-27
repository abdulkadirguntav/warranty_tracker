import 'app_localizations_en.dart';

/// Turkish strings.
class AppLocalizationsTr extends AppLocalizationsEn {
  AppLocalizationsTr(super.locale);

  @override
  String get(String key) {
    switch (key) {
      case 'appName':
        return 'Warrantify';
      case 'initializing':
        return 'Başlatılıyor…';
      case 'initFailed':
        return 'Başlatma başarısız';
      case 'cancel':
        return 'İptal';
      case 'delete':
        return 'Sil';
      case 'save':
        return 'Kaydet';
      case 'saveChanges':
        return 'Değişiklikleri kaydet';
      case 'add':
        return 'Ekle';
      case 'edit':
        return 'Düzenle';
      case 'remove':
        return 'Kaldır';
      case 'ok':
        return 'Tamam';
      case 'retry':
        return 'Tekrar dene';
      case 'notFound':
        return 'Bulunamadı';
      case 'routeNotFound':
        return 'Sayfa bulunamadı';
      case 'statusActive':
        return 'Aktif';
      case 'statusExpiringSoon':
        return 'Yakında bitiyor';
      case 'statusExpired':
        return 'Süresi doldu';
      case 'daysLeft':
        return 'gün kaldı';
      case 'oneDayLeft':
        return '1 gün kaldı';
      case 'expiresToday':
        return 'Bugün bitiyor';
      case 'expiredOneDayAgo':
        return '1 gün önce süresi doldu';
      case 'expiredDaysAgo':
        return '{n} gün önce süresi doldu';
      case 'daysUnit':
        return 'gün';
      case 'dashboardTitle':
        return 'Warrantify';
      case 'dashboardSubtitle':
        return 'Tüm garantilerinizi takip edin';
      case 'searchHint':
        return 'Ürün, kategori, not ara…';
      case 'tabAll':
        return 'Tümü';
      case 'tabExpiring':
        return 'Bitenler';
      case 'tabActive':
        return 'Aktif';
      case 'tabExpired':
        return 'Süresi dolan';
      case 'refresh':
        return 'Yenile';
      case 'summaryTotal':
        return 'Toplam ürün';
      case 'summaryActive':
        return 'Aktif';
      case 'summaryExpiring':
        return 'Yakında bitiyor';
      case 'summaryExpired':
        return 'Süresi dolan';
      case 'emptyTitle':
        return 'Henüz takip edilen garanti yok';
      case 'emptyBody':
        return 'İlk ürününüzü eklemek için + düğmesine dokunun ve bir daha garanti bitiş tarihini kaçırmayın.';
      case 'loadFailed':
        return 'Veriler yüklenemedi';
      case 'deletedItem':
        return 'Silindi: "{name}"';
      case 'deleteItemTitle':
        return 'Ürün silinsin mi?';
      case 'deleteItemBody':
        return '"{name}" ürününü kaldırmak istediğinize emin misiniz?';
      case 'detailsTitle':
        return 'Detaylar';
      case 'itemNotFound':
        return 'Bu garanti ürünü bulunamadı.';
      case 'warrantyProgress':
        return 'Garanti ilerlemesi';
      case 'purchaseDate':
        return 'Satın alma tarihi';
      case 'warrantyEnd':
        return 'Garanti bitişi';
      case 'effectiveEnd':
        return 'Geçerli bitiş';
      case 'duration':
        return 'Süre';
      case 'durationMonthsSuffix':
        return ' ay';
      case 'extendedWarranty':
        return 'Genişletilmiş garanti';
      case 'extendedDurationLabel':
        return 'Süre: {n} ay';
      case 'extendedEndDateLabel':
        return 'Bitiş tarihi: {date}';
      case 'effectiveEndDate':
        return 'Geçerli bitiş tarihi: {date}';
      case 'notes':
        return 'Notlar';
      case 'productPhoto':
        return 'Ürün fotoğrafı';
      case 'productPhotoMissing':
        return 'Ürün fotoğrafı yüklenemedi';
      case 'receipt':
        return 'Fatura';
      case 'receiptImageMissing':
        return 'Fatura görseli yüklenemedi';
      case 'documents':
        return 'Belgeler';
      case 'tapToView':
        return 'Görüntülemek için dokun';
      case 'fileNotFound':
        return 'Dosya bulunamadı';
      case 'deleteDocumentTitle':
        return 'Belge silinsin mi?';
      case 'deleteDocumentBody':
        return '"{name}" kaldırılsın mı?';
      case 'serviceHistory':
        return 'Servis geçmişi';
      case 'noServiceRecords':
        return 'Henüz servis kaydı yok. Bir onarım eklemek için "Ekle"ye dokunun.';
      case 'costLabel':
        return 'Tutar: {value}';
      case 'trackingLabel':
        return 'Takip no: {value}';
      case 'addServiceRecord':
        return 'Servis kaydı ekle';
      case 'editServiceRecord':
        return 'Servis kaydını düzenle';
      case 'deleteRecordTitle':
        return 'Kayıt silinsin mi?';
      case 'deleteRecordBody':
        return '"{name}" servis kaydı kaldırılsın mı?';
      case 'confirmDeleteTitle':
        return 'Ürün silinsin mi?';
      case 'confirmDeleteBody':
        return '"{name}" kalıcı olarak kaldırılsın mı?';
      case 'addWarrantyTitle':
        return 'Garanti Ekle';
      case 'editWarrantyTitle':
        return 'Garantiyi Düzenle';
      case 'sectionProductInfo':
        return 'Ürün bilgileri';
      case 'sectionWarrantyInfo':
        return 'Garanti bilgileri';
      case 'sectionAttachment':
        return 'Belgeler';
      case 'sectionNotes':
        return 'Notlar';
      case 'productNameLabel':
        return 'Ürün adı';
      case 'productNameHint':
        return 'ör. Galaxy S24 Ultra';
      case 'productNameRequired':
        return 'Lütfen bir ürün adı girin';
      case 'categoryLabel':
        return 'Kategori';
      case 'purchaseDateLabel':
        return 'Satın alma tarihi';
      case 'durationLabel':
        return 'Süre (ay)';
      case 'monthsSuffix':
        return ' ay';
      case 'customDuration':
        return 'Özel süre';
      case 'monthsWord':
        return 'Ay';
      case 'extendedWarrantyType':
        return 'Genişletilmiş garanti türü';
      case 'extendedTypeDuration':
        return 'Süre (ay)';
      case 'extendedTypeDate':
        return 'Belirli bitiş tarihi';
      case 'extendedMonthsLabel':
        return 'Genişletilmiş (ay)';
      case 'customExtendedDuration':
        return 'Özel genişletilmiş süre';
      case 'extendedEndDateInputLabel':
        return 'Genişletilmiş garanti bitiş tarihi';
      case 'extendedWarrantyHint':
        return 'Orijinal garanti süresi ötesinde ek koruma ekleyin.';
      case 'previewLabel':
        return 'Önizleme';
      case 'warrantyEndsLabel':
        return 'Garanti bitişi: {date}';
      case 'effectiveEndsLabel':
        return 'Geçerli bitiş: {date}';
      case 'notesLabel':
        return 'Notlar';
      case 'notesHint':
        return 'Seri numarası, mağaza vb.';
      case 'productPhotoOptional':
        return 'Ürün fotoğrafı (isteğe bağlı)';
      case 'addProductPhoto':
        return 'Ürün fotoğrafı ekle';
      case 'changePhoto':
        return 'Fotoğrafı değiştir';
      case 'addPhoto':
        return 'Fotoğraf ekle';
      case 'receiptPhotoOptional':
        return 'Fatura fotoğrafı (isteğe bağlı)';
      case 'documentsOptional':
        return 'Belgeler (isteğe bağlı)';
      case 'documentsHint':
        return 'Fatura, garanti sertifikası, servis formu vb. ekleyin.';
      case 'takeWithCamera':
        return 'Kamera ile çek';
      case 'chooseFromGallery':
        return 'Galeriden seç';
      case 'documentTypeLabel':
        return 'Belge türü';
      case 'docLabelReceipt':
        return 'Fatura';
      case 'docLabelWarrantyCertificate':
        return 'Garanti Sertifikası';
      case 'docLabelServiceForm':
        return 'Servis Formu';
      case 'docLabelBoxLabel':
        return 'Kutu Etiketi';
      case 'docLabelOther':
        return 'Diğer';
      case 'itemUpdated':
        return 'Ürün güncellendi';
      case 'itemAdded':
        return 'Ürün eklendi';
      case 'invalidCost':
        return 'Geçersiz tutar';
      case 'serviceDateLabel':
        return 'Servis tarihi';
      case 'serviceCenterLabel':
        return 'Servis merkezi';
      case 'serviceCenterRequired':
        return 'Zorunlu';
      case 'descriptionLabel':
        return 'Açıklama';
      case 'costOptionalLabel':
        return 'Tutar (isteğe bağlı)';
      case 'trackingOptionalLabel':
        return 'Takip numarası (isteğe bağlı)';
      case 'notesOptionalLabel':
        return 'Notlar (isteğe bağlı)';
      case 'daysBadgeExpired':
        return 'Bitti';
      case 'daysBadgeToday':
        return 'Bugün';
      case 'daysBadgeYearsSuffix':
        return 'yıl';
      case 'daysBadgeDaysSuffix':
        return 'gün';
      case 'dismissDeleteLabel':
        return 'Sil';
      case 'appearance':
        return 'Görünüm';
      case 'dataBackup':
        return 'Veri yedeği';
      case 'exportBackup':
        return 'Yedeği dışa aktar';
      case 'restoreBackup':
        return 'Yedeği geri yükle';
      case 'exportBackupSubtitle':
        return 'Saklayabileceğiniz veya paylaşabileceğiniz yerel bir JSON dosyası oluşturur.';
      case 'restoreBackupSubtitle':
        return 'Daha önce dışa aktarılmış Warrantify JSON yedeğini içe aktarır.';
      case 'backupExported':
        return 'Yedek dışa aktarıldı';
      case 'backupExportFailed':
        return 'Yedek dışa aktarılamadı';
      case 'backupRestored':
        return '{n} ürün geri yüklendi';
      case 'backupRestoreFailed':
        return 'Yedek geri yüklenemedi';
      case 'restoreBackupTitle':
        return 'Yedek geri yüklensin mi?';
      case 'restoreBackupBody':
        return 'Bu işlem cihazda kayıtlı mevcut garantilerin yerine yedekteki verileri koyar.';
      default:
        return super.get(key);
    }
  }

  @override
  String catElectronics() => 'Elektronik';
  @override
  String catHomeAppliance() => 'Ev Aleti';
  @override
  String catMobile() => 'Mobil / Tablet';
  @override
  String catComputer() => 'Bilgisayar / Dizüstü';
  @override
  String catAudioVideo() => 'Ses / Görüntü';
  @override
  String catKitchen() => 'Mutfak';
  @override
  String catTools() => 'Aletler / Donanım';
  @override
  String catFurniture() => 'Mobilya';
  @override
  String catAutomotive() => 'Otomotiv';
  @override
  String catOther() => 'Diğer';
}
