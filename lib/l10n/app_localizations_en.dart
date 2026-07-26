import 'app_localizations.dart';

/// English strings (canonical).
class AppLocalizationsEn extends AppLocalizations {
  const AppLocalizationsEn(super.locale);

  @override
  String get(String key) {
    switch (key) {
      case 'appName':
        return 'Warrantify';
      case 'initializing':
        return 'Initializing…';
      case 'initFailed':
        return 'Initialization failed';
      case 'cancel':
        return 'Cancel';
      case 'delete':
        return 'Delete';
      case 'save':
        return 'Save';
      case 'saveChanges':
        return 'Save changes';
      case 'add':
        return 'Add';
      case 'edit':
        return 'Edit';
      case 'remove':
        return 'Remove';
      case 'ok':
        return 'OK';
      case 'retry':
        return 'Retry';
      case 'notFound':
        return 'Not found';
      case 'routeNotFound':
        return 'Route not found';
      case 'statusActive':
        return 'Active';
      case 'statusExpiringSoon':
        return 'Expiring soon';
      case 'statusExpired':
        return 'Expired';
      case 'daysLeft':
        return 'days left';
      case 'oneDayLeft':
        return '1 day left';
      case 'expiresToday':
        return 'Expires today';
      case 'expiredOneDayAgo':
        return 'Expired 1 day ago';
      case 'expiredDaysAgo':
        return 'Expired {n} days ago';
      case 'daysUnit':
        return 'days';
      case 'dashboardTitle':
        return 'Warrantify';
      case 'dashboardSubtitle':
        return 'Keep track of all your warranties';
      case 'searchHint':
        return 'Search products, categories, notes…';
      case 'tabAll':
        return 'All';
      case 'tabExpiring':
        return 'Expiring';
      case 'tabActive':
        return 'Active';
      case 'tabExpired':
        return 'Expired';
      case 'refresh':
        return 'Refresh';
      case 'summaryTotal':
        return 'Total products';
      case 'summaryActive':
        return 'Active';
      case 'summaryExpiring':
        return 'Expiring soon';
      case 'summaryExpired':
        return 'Expired';
      case 'emptyTitle':
        return 'No warranties tracked yet';
      case 'emptyBody':
        return 'Tap the + button to add your first product and never miss a warranty expiration.';
      case 'loadFailed':
        return 'Failed to load data';
      case 'deletedItem':
        return 'Deleted "{name}"';
      case 'deleteItemTitle':
        return 'Delete item?';
      case 'deleteItemBody':
        return 'Are you sure you want to remove "{name}"?';
      case 'detailsTitle':
        return 'Details';
      case 'itemNotFound':
        return 'This warranty item could not be found.';
      case 'warrantyProgress':
        return 'Warranty progress';
      case 'purchaseDate':
        return 'Purchase date';
      case 'warrantyEnd':
        return 'Warranty end';
      case 'effectiveEnd':
        return 'Effective end';
      case 'duration':
        return 'Duration';
      case 'durationMonthsSuffix':
        return ' months';
      case 'extendedWarranty':
        return 'Extended warranty';
      case 'extendedDurationLabel':
        return 'Duration: {n} months';
      case 'extendedEndDateLabel':
        return 'End date: {date}';
      case 'effectiveEndDate':
        return 'Effective end date: {date}';
      case 'notes':
        return 'Notes';
      case 'productPhoto':
        return 'Product photo';
      case 'productPhotoMissing':
        return 'Could not load product image';
      case 'receipt':
        return 'Receipt';
      case 'receiptImageMissing':
        return 'Could not load receipt image';
      case 'documents':
        return 'Documents';
      case 'tapToView':
        return 'Tap to view';
      case 'fileNotFound':
        return 'File not found';
      case 'deleteDocumentTitle':
        return 'Delete document?';
      case 'deleteDocumentBody':
        return 'Remove "{name}"?';
      case 'serviceHistory':
        return 'Service history';
      case 'noServiceRecords':
        return 'No service records yet. Tap "Add" to record a repair.';
      case 'costLabel':
        return 'Cost: {value}';
      case 'trackingLabel':
        return 'Tracking: {value}';
      case 'addServiceRecord':
        return 'Add service record';
      case 'editServiceRecord':
        return 'Edit service record';
      case 'deleteRecordTitle':
        return 'Delete record?';
      case 'deleteRecordBody':
        return 'Remove service record from "{name}"?';
      case 'confirmDeleteTitle':
        return 'Delete item?';
      case 'confirmDeleteBody':
        return 'Remove "{name}" permanently?';
      case 'addWarrantyTitle':
        return 'Add Warranty';
      case 'editWarrantyTitle':
        return 'Edit Warranty';
      case 'sectionProductInfo':
        return 'Product information';
      case 'sectionWarrantyInfo':
        return 'Warranty information';
      case 'sectionAttachment':
        return 'Documents';
      case 'sectionNotes':
        return 'Notes';
      case 'productNameLabel':
        return 'Product name';
      case 'productNameHint':
        return 'e.g. Galaxy S24 Ultra';
      case 'productNameRequired':
        return 'Please enter a product name';
      case 'categoryLabel':
        return 'Category';
      case 'purchaseDateLabel':
        return 'Purchase date';
      case 'durationLabel':
        return 'Duration (months)';
      case 'monthsSuffix':
        return ' months';
      case 'customDuration':
        return 'Custom duration';
      case 'monthsWord':
        return 'Months';
      case 'extendedWarrantyType':
        return 'Extended warranty type';
      case 'extendedTypeDuration':
        return 'Duration (months)';
      case 'extendedTypeDate':
        return 'Specific end date';
      case 'extendedMonthsLabel':
        return 'Extended (months)';
      case 'customExtendedDuration':
        return 'Custom extended duration';
      case 'extendedEndDateInputLabel':
        return 'Extended warranty end date';
      case 'extendedWarrantyHint':
        return 'Add extra protection beyond the original warranty period.';
      case 'previewLabel':
        return 'Preview';
      case 'warrantyEndsLabel':
        return 'Warranty ends: {date}';
      case 'effectiveEndsLabel':
        return 'Effective end: {date}';
      case 'notesLabel':
        return 'Notes';
      case 'notesHint':
        return 'Serial number, store, etc.';
      case 'productPhotoOptional':
        return 'Product photo (optional)';
      case 'addProductPhoto':
        return 'Add product photo';
      case 'changePhoto':
        return 'Change photo';
      case 'addPhoto':
        return 'Add photo';
      case 'receiptPhotoOptional':
        return 'Receipt photo (optional)';
      case 'documentsOptional':
        return 'Documents (optional)';
      case 'documentsHint':
        return 'Attach receipt, warranty certificate, service form, etc.';
      case 'takeWithCamera':
        return 'Take with camera';
      case 'chooseFromGallery':
        return 'Choose from gallery';
      case 'documentTypeLabel':
        return 'Document type';
      case 'docLabelReceipt':
        return 'Receipt';
      case 'docLabelWarrantyCertificate':
        return 'Warranty Certificate';
      case 'docLabelServiceForm':
        return 'Service Form';
      case 'docLabelBoxLabel':
        return 'Box Label';
      case 'docLabelOther':
        return 'Other';
      case 'itemUpdated':
        return 'Item updated';
      case 'itemAdded':
        return 'Item added';
      case 'invalidCost':
        return 'Invalid cost value';
      case 'serviceDateLabel':
        return 'Service date';
      case 'serviceCenterLabel':
        return 'Service center';
      case 'serviceCenterRequired':
        return 'Required';
      case 'descriptionLabel':
        return 'Description';
      case 'costOptionalLabel':
        return 'Cost (optional)';
      case 'trackingOptionalLabel':
        return 'Tracking number (optional)';
      case 'notesOptionalLabel':
        return 'Notes (optional)';
      case 'daysBadgeExpired':
        return 'Expired';
      case 'daysBadgeToday':
        return 'Today';
      case 'daysBadgeYearsSuffix':
        return 'yrs';
      case 'daysBadgeDaysSuffix':
        return 'days';
      case 'dismissDeleteLabel':
        return 'Delete';
      case 'appearance':
        return 'Appearance';
      default:
        return key;
    }
  }

  // ── App title etc. typed accessors ─────────────────────────────────
  @override
  String get appName => get('appName');
  @override
  String get initializing => get('initializing');
  @override
  String get initFailed => get('initFailed');
  @override
  String get cancel => get('cancel');
  @override
  String get delete => get('delete');
  @override
  String get save => get('save');
  @override
  String get saveChanges => get('saveChanges');
  @override
  String get add => get('add');
  @override
  String get edit => get('edit');
  @override
  String get remove => get('remove');
  @override
  String get ok => get('ok');
  @override
  String get retry => get('retry');
  @override
  String get notFound => get('notFound');
  @override
  String get routeNotFound => get('routeNotFound');
  @override
  String get statusActive => get('statusActive');
  @override
  String get statusExpiringSoon => get('statusExpiringSoon');
  @override
  String get statusExpired => get('statusExpired');
  @override
  String get daysLeft => get('daysLeft');
  @override
  String get oneDayLeft => get('oneDayLeft');
  @override
  String get expiresToday => get('expiresToday');
  @override
  String get expiredOneDayAgo => get('expiredOneDayAgo');
  @override
  String get expiredDaysAgo => get('expiredDaysAgo');
  @override
  String get daysUnit => get('daysUnit');
  @override
  String get dashboardTitle => get('dashboardTitle');
  @override
  String get dashboardSubtitle => get('dashboardSubtitle');
  @override
  String get searchHint => get('searchHint');
  @override
  String get tabAll => get('tabAll');
  @override
  String get tabExpiring => get('tabExpiring');
  @override
  String get tabActive => get('tabActive');
  @override
  String get tabExpired => get('tabExpired');
  @override
  String get refresh => get('refresh');
  @override
  String get summaryTotal => get('summaryTotal');
  @override
  String get summaryActive => get('summaryActive');
  @override
  String get summaryExpiring => get('summaryExpiring');
  @override
  String get summaryExpired => get('summaryExpired');
  @override
  String get emptyTitle => get('emptyTitle');
  @override
  String get emptyBody => get('emptyBody');
  @override
  String get loadFailed => get('loadFailed');
  @override
  String get deletedItem => get('deletedItem');
  @override
  String get deleteItemTitle => get('deleteItemTitle');
  @override
  String get deleteItemBody => get('deleteItemBody');
  @override
  String get detailsTitle => get('detailsTitle');
  @override
  String get itemNotFound => get('itemNotFound');
  @override
  String get warrantyProgress => get('warrantyProgress');
  @override
  String get purchaseDate => get('purchaseDate');
  @override
  String get warrantyEnd => get('warrantyEnd');
  @override
  String get effectiveEnd => get('effectiveEnd');
  @override
  String get duration => get('duration');
  @override
  String get durationMonthsSuffix => get('durationMonthsSuffix');
  @override
  String get extendedWarranty => get('extendedWarranty');
  @override
  String get extendedDurationLabel => get('extendedDurationLabel');
  @override
  String get extendedEndDateLabel => get('extendedEndDateLabel');
  @override
  String get effectiveEndDate => get('effectiveEndDate');
  @override
  String get notes => get('notes');
  @override
  String get productPhoto => get('productPhoto');
  @override
  String get productPhotoMissing => get('productPhotoMissing');
  @override
  String get receipt => get('receipt');
  @override
  String get receiptImageMissing => get('receiptImageMissing');
  @override
  String get documents => get('documents');
  @override
  String get tapToView => get('tapToView');
  @override
  String get fileNotFound => get('fileNotFound');
  @override
  String get deleteDocumentTitle => get('deleteDocumentTitle');
  @override
  String get deleteDocumentBody => get('deleteDocumentBody');
  @override
  String get serviceHistory => get('serviceHistory');
  @override
  String get noServiceRecords => get('noServiceRecords');
  @override
  String get costLabel => get('costLabel');
  @override
  String get trackingLabel => get('trackingLabel');
  @override
  String get addServiceRecord => get('addServiceRecord');
  @override
  String get editServiceRecord => get('editServiceRecord');
  @override
  String get deleteRecordTitle => get('deleteRecordTitle');
  @override
  String get deleteRecordBody => get('deleteRecordBody');
  @override
  String get confirmDeleteTitle => get('confirmDeleteTitle');
  @override
  String get confirmDeleteBody => get('confirmDeleteBody');
  @override
  String get addWarrantyTitle => get('addWarrantyTitle');
  @override
  String get editWarrantyTitle => get('editWarrantyTitle');
  @override
  String get sectionProductInfo => get('sectionProductInfo');
  @override
  String get sectionWarrantyInfo => get('sectionWarrantyInfo');
  @override
  String get sectionAttachment => get('sectionAttachment');
  @override
  String get sectionNotes => get('sectionNotes');
  @override
  String get productNameLabel => get('productNameLabel');
  @override
  String get productNameHint => get('productNameHint');
  @override
  String get productNameRequired => get('productNameRequired');
  @override
  String get categoryLabel => get('categoryLabel');
  @override
  String get purchaseDateLabel => get('purchaseDateLabel');
  @override
  String get durationLabel => get('durationLabel');
  @override
  String get monthsSuffix => get('monthsSuffix');
  @override
  String get customDuration => get('customDuration');
  @override
  String get monthsWord => get('monthsWord');
  @override
  String get extendedWarrantyType => get('extendedWarrantyType');
  @override
  String get extendedTypeDuration => get('extendedTypeDuration');
  @override
  String get extendedTypeDate => get('extendedTypeDate');
  @override
  String get extendedMonthsLabel => get('extendedMonthsLabel');
  @override
  String get customExtendedDuration => get('customExtendedDuration');
  @override
  String get extendedEndDateInputLabel => get('extendedEndDateInputLabel');
  @override
  String get extendedWarrantyHint => get('extendedWarrantyHint');
  @override
  String get previewLabel => get('previewLabel');
  @override
  String get warrantyEndsLabel => get('warrantyEndsLabel');
  @override
  String get effectiveEndsLabel => get('effectiveEndsLabel');
  @override
  String get notesLabel => get('notesLabel');
  @override
  String get notesHint => get('notesHint');
  @override
  String get productPhotoOptional => get('productPhotoOptional');
  @override
  String get addProductPhoto => get('addProductPhoto');
  @override
  String get changePhoto => get('changePhoto');
  @override
  String get addPhoto => get('addPhoto');
  @override
  String get receiptPhotoOptional => get('receiptPhotoOptional');
  @override
  String get documentsOptional => get('documentsOptional');
  @override
  String get documentsHint => get('documentsHint');
  @override
  String get takeWithCamera => get('takeWithCamera');
  @override
  String get chooseFromGallery => get('chooseFromGallery');
  @override
  String get documentTypeLabel => get('documentTypeLabel');
  @override
  String get docLabelReceipt => get('docLabelReceipt');
  @override
  String get docLabelWarrantyCertificate => get('docLabelWarrantyCertificate');
  @override
  String get docLabelServiceForm => get('docLabelServiceForm');
  @override
  String get docLabelBoxLabel => get('docLabelBoxLabel');
  @override
  String get docLabelOther => get('docLabelOther');
  @override
  String get itemUpdated => get('itemUpdated');
  @override
  String get itemAdded => get('itemAdded');
  @override
  String get invalidCost => get('invalidCost');
  @override
  String get serviceDateLabel => get('serviceDateLabel');
  @override
  String get serviceCenterLabel => get('serviceCenterLabel');
  @override
  String get serviceCenterRequired => get('serviceCenterRequired');
  @override
  String get descriptionLabel => get('descriptionLabel');
  @override
  String get costOptionalLabel => get('costOptionalLabel');
  @override
  String get trackingOptionalLabel => get('trackingOptionalLabel');
  @override
  String get notesOptionalLabel => get('notesOptionalLabel');
  @override
  String get daysBadgeExpired => get('daysBadgeExpired');
  @override
  String get daysBadgeToday => get('daysBadgeToday');
  @override
  String get daysBadgeYearsSuffix => get('daysBadgeYearsSuffix');
  @override
  String get daysBadgeDaysSuffix => get('daysBadgeDaysSuffix');
  @override
  String get dismissDeleteLabel => get('dismissDeleteLabel');
  @override
  String get appearance => get('appearance');

  @override
  String catElectronics() => 'Electronics';
  @override
  String catHomeAppliance() => 'Home Appliance';
  @override
  String catMobile() => 'Mobile / Tablet';
  @override
  String catComputer() => 'Computer / Laptop';
  @override
  String catAudioVideo() => 'Audio / Video';
  @override
  String catKitchen() => 'Kitchen';
  @override
  String catTools() => 'Tools / Hardware';
  @override
  String catFurniture() => 'Furniture';
  @override
  String catAutomotive() => 'Automotive';
  @override
  String catOther() => 'Other';
}
