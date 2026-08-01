import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/warranty_calculator.dart';
import '../../domain/entities/brand_category.dart';
import '../../domain/entities/product_document.dart';
import '../../domain/entities/warranty_item.dart';
import '../../l10n/app_localizations.dart';
import '../providers/warranty_items_provider.dart';
import '../widgets/product_thumbnail.dart';
import '../widgets/section_card.dart';

/// Add/Edit screen: a form for creating or modifying a [WarrantyItem].
///
/// Redesigned into clear sections (Product, Warranty, Documents, Notes)
/// to avoid the long-plain-form feeling. On submit the
/// [WarrantyItem.endDate] is auto-calculated by the [WarrantyCalculator]
/// before being persisted.
class AddEditScreen extends ConsumerStatefulWidget {
  const AddEditScreen({super.key, this.existingItem});

  final WarrantyItem? existingItem;

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _productNameFieldKey = GlobalKey();
  final _categoryFieldKey = GlobalKey();
  final _warrantySectionKey = GlobalKey();
  late final TextEditingController _productNameCtrl;
  late final TextEditingController _notesCtrl;
  BrandCategory? _category;
  late DateTime _purchaseDate;
  late int _warrantyMonths;
  String? _receiptImagePath;
  String? _productImagePath;

  bool _hasExtendedWarranty = false;
  int _extendedWarrantyMonths = 12;
  bool _extendedUsesMonths = true;
  DateTime? _extendedWarrantyEndDate;

  final List<_DocumentDraft> _documents = [];

  bool get _isEditing => widget.existingItem != null;

  /// Matches an existing item's stored brand-category label (the
  /// canonical English [BrandCategory.label]) without needing a
  /// [BuildContext]. Falls back to [BrandCategory.other].
  BrandCategory _matchCategoryFromCanonical(String label) {
    for (final c in BrandCategory.all) {
      if (c.label == label) return c;
    }
    return BrandCategory.other;
  }

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _productNameCtrl = TextEditingController(text: item?.productName ?? '');
    _notesCtrl = TextEditingController(text: item?.notes ?? '');
    _category = item != null
        ? _matchCategoryFromCanonical(item.brandCategory)
        : null;
    _purchaseDate = item?.purchaseDate ?? DateTime.now();
    _warrantyMonths =
        item?.warrantyDurationInMonths ?? AppConstants.defaultWarrantyMonths;
    _receiptImagePath = item?.receiptImagePath;
    _productImagePath = item?.productImagePath;

    if (item != null && item.hasExtendedWarranty) {
      _hasExtendedWarranty = true;
      if (item.extendedWarrantyMonths != null) {
        _extendedWarrantyMonths = item.extendedWarrantyMonths!;
        _extendedUsesMonths = true;
      } else if (item.extendedWarrantyEndDate != null) {
        _extendedWarrantyEndDate = item.extendedWarrantyEndDate;
        _extendedUsesMonths = false;
      }
    }

    if (item != null) {
      for (final doc in item.documents) {
        _documents.add(_DocumentDraft.fromExisting(doc));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _productNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Date pickers ──────────────────────────────────────────────────
  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _pickExtendedEndDate() async {
    final baseEndDate = WarrantyCalculator.calculateEndDate(
      purchaseDate: _purchaseDate,
      warrantyDurationInMonths: _warrantyMonths,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: _extendedWarrantyEndDate ?? baseEndDate,
      firstDate: baseEndDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _extendedWarrantyEndDate = picked);
  }

  // ── Image pickers ──────────────────────────────────────────────────
  Future<void> _pickReceiptImage() async {
    final savedPath = await _persistImage(
      source: ImageSource.gallery,
      folder: AppConstants.receiptImageFolder,
      prefix: 'receipt',
    );
    if (savedPath != null) setState(() => _receiptImagePath = savedPath);
  }

  Future<void> _pickProductImage() async {
    if (!mounted) return;
    final source = await _showImageSourceSheet();
    if (source == null || !mounted) return;
    final savedPath = await _persistImage(
      source: source,
      folder: AppConstants.productImageFolder,
      prefix: 'product',
    );
    if (savedPath != null && mounted) {
      setState(() => _productImagePath = savedPath);
    }
  }

  Future<ImageSource?> _showImageSourceSheet() {
    final l = AppLocalizations.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l.addProductPhoto,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l.takeWithCamera),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l.chooseFromGallery),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _persistImage({
    required ImageSource source,
    required String folder,
    required String prefix,
  }) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 70);
    if (xFile == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, folder));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final fileName =
        '${prefix}_${DateTime.now().millisecondsSinceEpoch}${p.extension(xFile.path)}';
    final savedPath = p.join(dir.path, fileName);
    await File(xFile.path).copy(savedPath);
    return savedPath;
  }

  // ── Documents ──────────────────────────────────────────────────────
  Future<void> _addDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(
      p.join(appDir.path, AppConstants.documentsImageFolder),
    );
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final fileName =
        'doc_${DateTime.now().millisecondsSinceEpoch}${p.extension(filePath)}';
    final savedPath = p.join(dir.path, fileName);
    await File(filePath).copy(savedPath);

    if (!mounted) return;

    final label = await _showDocumentLabelDialog();
    if (label == null) return;

    setState(() {
      _documents.add(
        _DocumentDraft(id: null, filePath: savedPath, label: label),
      );
    });
  }

  Future<String?> _showDocumentLabelDialog() {
    final l = AppLocalizations.of(context);
    final labels = [
      l.docLabelReceipt,
      l.docLabelWarrantyCertificate,
      l.docLabelServiceForm,
      l.docLabelBoxLabel,
      l.docLabelOther,
    ];
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.documentTypeLabel),
        content: SizedBox(
          width: double.minPositive,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: labels
                .map(
                  (label) => ListTile(
                    title: Text(label),
                    leading: const Icon(Icons.description_outlined),
                    onTap: () => Navigator.of(ctx).pop(label),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
        ],
      ),
    );
  }

  void _removeDocument(int index) => setState(() => _documents.removeAt(index));

  // ── Save ────────────────────────────────────────────────────────────
  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }

    final productName = _productNameCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final endDate = WarrantyCalculator.calculateEndDate(
      purchaseDate: _purchaseDate,
      warrantyDurationInMonths: _warrantyMonths,
    );
    final id = widget.existingItem?.id ?? const Uuid().v4();

    int? extMonths;
    DateTime? extEndDate;
    if (_hasExtendedWarranty) {
      if (_extendedUsesMonths) {
        extMonths = _extendedWarrantyMonths;
      } else {
        extEndDate = _extendedWarrantyEndDate;
      }
    }

    final effectiveEndDate = _effectiveEndFromFields(
      baseEndDate: endDate,
      extendedWarrantyMonths: extMonths,
      extendedWarrantyEndDate: extEndDate,
    );
    if (_isPastDate(effectiveEndDate)) {
      await _scrollTo(_warrantySectionKey);
      if (!mounted) return;
      final shouldContinue = await _confirmExpiredWarranty(effectiveEndDate);
      if (shouldContinue != true) return;
    }

    final item = WarrantyItem(
      id: id,
      productName: productName,
      brandCategory: _category!.label,
      purchaseDate: _purchaseDate,
      warrantyDurationInMonths: _warrantyMonths,
      endDate: endDate,
      receiptImagePath: _receiptImagePath,
      productImagePath: _productImagePath,
      notes: notes,
      extendedWarrantyMonths: extMonths,
      extendedWarrantyEndDate: extEndDate,
    );

    await ref.read(warrantyItemsProvider.notifier).saveItem(item);

    for (final draft in _documents) {
      final doc = ProductDocument(
        id: draft.id ?? const Uuid().v4(),
        warrantyItemId: id,
        filePath: draft.filePath,
        label: draft.label,
      );
      await ref.read(warrantyItemsProvider.notifier).saveDocument(doc);
    }

    if (!mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? l.itemUpdated : l.itemAdded)),
    );
    context.pop();
  }

  void _scrollToFirstError() {
    final targetKey = _productNameCtrl.text.trim().isEmpty
        ? _productNameFieldKey
        : _categoryFieldKey;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollTo(targetKey));
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: 0.12,
    );
  }

  bool _isPastDate(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isBefore(todayOnly);
  }

  DateTime _effectiveEndFromFields({
    required DateTime baseEndDate,
    required int? extendedWarrantyMonths,
    required DateTime? extendedWarrantyEndDate,
  }) {
    if (!_hasExtendedWarranty) return baseEndDate;
    if (extendedWarrantyEndDate != null) return extendedWarrantyEndDate;
    if (extendedWarrantyMonths != null) {
      return WarrantyCalculator.calculateEndDateEx(
        baseDate: baseEndDate,
        additionalMonths: extendedWarrantyMonths,
      );
    }
    return baseEndDate;
  }

  Future<bool?> _confirmExpiredWarranty(DateTime effectiveEndDate) {
    final l = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.expiredWarrantyTitle),
        content: Text(
          l.expiredWarrantyBody.withDate(
            DateFormatter.format(effectiveEndDate),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: OutlinedButton.styleFrom(minimumSize: const Size(112, 48)),
              child: Text(l.cancel),
            ),
          ),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(minimumSize: const Size(112, 48)),
              child: Text(l.addExpiredWarranty),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.editWarrantyTitle : l.addWarrantyTitle),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _sectionLabel(l.sectionProductInfo),
              _productInfoSection(l),
              const SizedBox(height: 16),
              _sectionLabel(l.sectionWarrantyInfo),
              KeyedSubtree(
                key: _warrantySectionKey,
                child: _warrantySection(l),
              ),
              const SizedBox(height: 16),
              _sectionLabel(l.sectionAttachment),
              _attachmentsSection(l),
              const SizedBox(height: 16),
              _sectionLabel(l.sectionNotes),
              _notesSection(l),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(_isEditing ? l.saveChanges : l.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  // ── Product information ────────────────────────────────────────────
  Widget _productInfoSection(AppLocalizations l) {
    final hasImage =
        _productImagePath != null &&
        _productImagePath!.isNotEmpty &&
        File(_productImagePath!).existsSync();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: _productNameFieldKey,
            controller: _productNameCtrl,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: l.productNameLabel,
              hintText: l.productNameHint,
            ),
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (val) => (val == null || val.trim().isEmpty)
                ? l.productNameRequired
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BrandCategory>(
            key: _categoryFieldKey,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            dropdownColor: Theme.of(context).cardTheme.color,
            initialValue: _category,
            decoration: InputDecoration(labelText: l.categoryLabel),
            hint: Text(l.categoryHint),
            items: BrandCategory.all
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      c.localizedName(l),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() => _category = value);
            },
            validator: (value) => value == null ? l.categoryRequired : null,
          ),
          const SizedBox(height: 16),
          Text(
            l.productPhotoOptional,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ProductThumbnail(
                imagePath: hasImage ? _productImagePath : null,
                size: 80,
                borderRadius: AppTheme.radiusMd,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(hasImage ? l.changePhoto : l.addPhoto),
                      onPressed: _pickProductImage,
                    ),
                    if (hasImage)
                      TextButton(
                        onPressed: () =>
                            setState(() => _productImagePath = null),
                        child: Text(l.remove),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Warranty information ───────────────────────────────────────────
  Widget _warrantySection(AppLocalizations l) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _pickPurchaseDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l.purchaseDateLabel,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(DateFormatter.format(_purchaseDate)),
            ),
          ),
          const SizedBox(height: 12),
          Text(l.durationLabel, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.commonWarrantyDurations.map((m) {
              final selected = m == _warrantyMonths;
              return ChoiceChip(
                label: Text('$m${l.monthsSuffix}'),
                selected: selected,
                onSelected: (_) => setState(() => _warrantyMonths = m),
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: Text(l.customDuration),
                onPressed: () => _showCustomDurationDialog(
                  label: l.customDuration,
                  monthsWord: l.monthsWord,
                  ok: l.ok,
                  cancel: l.cancel,
                  current: _warrantyMonths,
                  onResult: (v) {
                    if (v != null && v > 0) {
                      setState(() => _warrantyMonths = v);
                    }
                  },
                ),
              ),
            ],
          ),
          Divider(color: Theme.of(context).dividerColor),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l.extendedWarranty,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              l.extendedWarrantyHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: _hasExtendedWarranty,
            onChanged: (v) => setState(() => _hasExtendedWarranty = v),
          ),
          if (_hasExtendedWarranty) ...[
            const SizedBox(height: 4),
            DropdownButtonFormField<bool>(
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              dropdownColor: Theme.of(context).cardTheme.color,
              decoration: InputDecoration(labelText: l.extendedWarrantyType),
              initialValue: _extendedUsesMonths,
              items: [
                DropdownMenuItem(
                  value: true,
                  child: Text(
                    l.extendedTypeDuration,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text(
                    l.extendedTypeDate,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              onChanged: (useMonths) {
                if (useMonths == null) return;
                setState(() => _extendedUsesMonths = useMonths);
                if (!useMonths) _pickExtendedEndDate();
              },
            ),
            const SizedBox(height: 12),
            if (_extendedUsesMonths)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.extendedMonthsLabel,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.commonExtendedWarrantyDurations.map((
                      m,
                    ) {
                      final selected = m == _extendedWarrantyMonths;
                      return ChoiceChip(
                        label: Text('$m${l.monthsSuffix}'),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _extendedWarrantyMonths = m),
                      );
                    }).toList(),
                  ),
                ],
              )
            else
              InkWell(
                onTap: _pickExtendedEndDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l.extendedEndDateInputLabel,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _extendedWarrantyEndDate != null
                        ? DateFormatter.format(_extendedWarrantyEndDate!)
                        : '—',
                  ),
                ),
              ),
            const SizedBox(height: 12),
            _effectiveEndPreview(l),
          ],
        ],
      ),
    );
  }

  Widget _effectiveEndPreview(AppLocalizations l) {
    final effectiveEnd = _computeEffectiveEndDate();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.effectiveEndDate.withDate(
                    DateFormatter.format(effectiveEnd),
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  DateFormatter.remaining(effectiveEnd, l),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime _computeEffectiveEndDate() {
    final baseEndDate = WarrantyCalculator.calculateEndDate(
      purchaseDate: _purchaseDate,
      warrantyDurationInMonths: _warrantyMonths,
    );
    if (!_hasExtendedWarranty) return baseEndDate;
    if (!_extendedUsesMonths && _extendedWarrantyEndDate != null) {
      return _extendedWarrantyEndDate!;
    }
    return WarrantyCalculator.calculateEndDateEx(
      baseDate: baseEndDate,
      additionalMonths: _extendedWarrantyMonths,
    );
  }

  void _showCustomDurationDialog({
    required String label,
    required String monthsWord,
    required String ok,
    required String cancel,
    required int current,
    required ValueChanged<int?> onResult,
  }) async {
    final controller = TextEditingController(text: current.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: monthsWord,
            suffixText: monthsWord,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(cancel),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              Navigator.of(ctx).pop(val);
            },
            child: Text(ok),
          ),
        ],
      ),
    );
    onResult(result);
  }

  // ── Attachments ───────────────────────────────────────────────────
  Widget _attachmentsSection(AppLocalizations l) {
    final hasReceipt =
        _receiptImagePath != null &&
        _receiptImagePath!.isNotEmpty &&
        File(_receiptImagePath!).existsSync();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.receiptPhotoOptional,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ProductThumbnail(
                imagePath: hasReceipt ? _receiptImagePath : null,
                size: 72,
                borderRadius: AppTheme.radiusMd,
                placeholderIcon: Icons.receipt_long_outlined,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        _receiptImagePath == null ? l.addPhoto : l.changePhoto,
                      ),
                      onPressed: _pickReceiptImage,
                    ),
                    if (_receiptImagePath != null)
                      TextButton(
                        onPressed: () =>
                            setState(() => _receiptImagePath = null),
                        child: Text(l.remove),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Theme.of(context).dividerColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.documentsOptional,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              TextButton.icon(
                icon: const Icon(Icons.attach_file, size: 18),
                label: Text(l.add),
                onPressed: _addDocument,
              ),
            ],
          ),
          if (_documents.isEmpty)
            Text(l.documentsHint, style: Theme.of(context).textTheme.bodySmall)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _documents.length,
              padding: const EdgeInsets.only(top: 4),
              itemBuilder: (context, index) {
                final doc = _documents[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: const Icon(Icons.description_outlined),
                  title: Text(doc.label),
                  subtitle: Text(
                    p.basename(doc.filePath),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeDocument(index),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Notes ──────────────────────────────────────────────────────────
  Widget _notesSection(AppLocalizations l) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _notesCtrl,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: l.notesLabel,
              hintText: l.notesHint,
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            maxLines: 4,
            minLines: 3,
          ),
        ],
      ),
    );
  }
}

/// Temporary document entry used in the add/edit form before saving.
class _DocumentDraft {
  final String? id;
  final String filePath;
  final String label;

  _DocumentDraft({this.id, required this.filePath, required this.label});

  factory _DocumentDraft.fromExisting(ProductDocument doc) {
    return _DocumentDraft(id: doc.id, filePath: doc.filePath, label: doc.label);
  }
}
