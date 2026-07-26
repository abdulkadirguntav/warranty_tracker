import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/product_document.dart';
import '../../domain/entities/service_record.dart';
import '../../domain/entities/warranty_item.dart';
import '../../l10n/app_localizations.dart';
import '../providers/warranty_items_provider.dart';
import '../widgets/product_thumbnail.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/warranty_countdown_ring.dart';

/// Details screen: shows full information about a single [WarrantyItem],
/// with a premium "product vault" hero at the top featuring the large
/// circular remaining-days indicator. Technical ids are hidden from the
/// normal user.
class DetailsScreen extends ConsumerStatefulWidget {
  const DetailsScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  WarrantyItem? _item;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    final item = await ref
        .read(warrantyItemsProvider.notifier)
        .getItem(widget.itemId);
    if (mounted) {
      setState(() {
        _item = item;
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDeleteTitle),
        content: Text(l.confirmDeleteBody.withName(_item?.productName ?? '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(warrantyItemsProvider.notifier).deleteItem(widget.itemId);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final item = _item;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.notFound)),
        body: Center(child: Text(l.itemNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.detailsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l.edit,
            onPressed: () async {
              await context.push(AppConstants.routeAddEdit, extra: item);
              await _loadItem();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l.delete,
            onPressed: _confirmDelete,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Hero(item: item, l: l),
          if (item.productImagePath != null) ...[
            const SizedBox(height: 16),
            _ProductImage(item: item, l: l),
          ],
          if (item.hasExtendedWarranty) ...[
            const SizedBox(height: 16),
            _ExtendedWarrantyCard(item: item, l: l),
          ],
          const SizedBox(height: 16),
          _InfoRows(item: item, l: l),
          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _NotesCard(item: item, l: l),
          ],
          if (item.receiptImagePath != null) ...[
            const SizedBox(height: 16),
            _ReceiptImage(item: item, l: l),
          ],
          if (item.documents.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DocumentsSection(item: item, l: l),
          ],
          const SizedBox(height: 16),
          _ServiceHistorySection(item: item, l: l),
        ],
      ),
    );
  }

  // ── Document previews / deletions ────────────────────────────────
  void _previewDocument(ProductDocument doc) {
    final l = AppLocalizations.of(context);
    final file = File(doc.filePath);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.fileNotFound)),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DocumentViewer(
          filePath: doc.filePath,
          label: doc.label,
        ),
      ),
    );
  }

  Future<void> _deleteDocument(ProductDocument doc) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteDocumentTitle),
        content: Text(l.deleteDocumentBody.withName(doc.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(warrantyItemsProvider.notifier).deleteDocument(doc.id);
    await _loadItem();
  }

  Future<void> _addServiceRecord(String itemId) async {
    final result = await showDialog<ServiceRecord>(
      context: context,
      builder: (_) => _ServiceRecordDialog(warrantyItemId: itemId),
    );
    if (result == null) return;
    await ref.read(warrantyItemsProvider.notifier).saveServiceRecord(result);
    await _loadItem();
  }

  Future<void> _editServiceRecord(ServiceRecord record) async {
    final result = await showDialog<ServiceRecord>(
      context: context,
      builder: (_) => _ServiceRecordDialog(
        record: record,
        warrantyItemId: record.warrantyItemId,
      ),
    );
    if (result == null) return;
    await ref.read(warrantyItemsProvider.notifier).saveServiceRecord(result);
    await _loadItem();
  }

  Future<void> _deleteServiceRecord(ServiceRecord record) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteRecordTitle),
        content: Text(l.deleteRecordBody.withName(record.serviceCenter)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(warrantyItemsProvider.notifier).deleteServiceRecord(record.id);
    await _loadItem();
  }
}

// ══════════════════════════════════════════════════════════════════════
// Hero — product image + name + category + status + large ring
// ══════════════════════════════════════════════════════════════════════
class _Hero extends StatelessWidget {
  const _Hero({required this.item, required this.l});
  final WarrantyItem item;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductThumbnail(
                  imagePath: item.productImagePath,
                  size: 76,
                  borderRadius: AppTheme.radiusMd,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.productName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.brandCategory,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      StatusBadge(
                        endDate: item.effectiveEndDate,
                        showRemaining: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: WarrantyCountdownRing(
                item: item,
                size: 168,
                strokeWidth: 12,
                showLabel: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Info rows
// ══════════════════════════════════════════════════════════════════════
class _InfoRows extends StatelessWidget {
  const _InfoRows({required this.item, required this.l});
  final WarrantyItem item;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(
          children: [
            _row(context, Icons.calendar_today_outlined, l.purchaseDate,
                DateFormatter.format(item.purchaseDate)),
            const Divider(),
            _row(context, Icons.event_outlined, l.warrantyEnd,
                DateFormatter.format(item.endDate)),
            if (item.hasExtendedWarranty) ...[
              const Divider(),
              _row(context, Icons.shield_outlined, l.effectiveEnd,
                  DateFormatter.format(item.effectiveEndDate),
                  tint: Theme.of(context).colorScheme.primary),
            ],
            const Divider(),
            _row(
              context,
              Icons.timelapse_outlined,
              l.duration,
              '${item.warrantyDurationInMonths}${l.durationMonthsSuffix}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? tint,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: tint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Extended warranty card
// ══════════════════════════════════════════════════════════════════════
class _ExtendedWarrantyCard extends StatelessWidget {
  const _ExtendedWarrantyCard({required this.item, required this.l});
  final WarrantyItem item;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final bodyLine = item.extendedWarrantyMonths != null
        ? l.extendedDurationLabel.withN(item.extendedWarrantyMonths!)
        : (item.extendedWarrantyEndDate != null
            ? l.extendedEndDateLabel.withDate(
                DateFormatter.format(item.extendedWarrantyEndDate!),
              )
            : '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        color: accent.withValues(alpha: 0.08),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.extendedWarranty,
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  bodyLine,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  l.effectiveEndDate
                      .withDate(DateFormatter.format(item.effectiveEndDate)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Notes card
// ══════════════════════════════════════════════════════════════════════
class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.item, required this.l});
  final WarrantyItem item;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.notes, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              item.notes,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Product image
// ══════════════════════════════════════════════════════════════════════
class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.item, required this.l});
  final WarrantyItem item;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.productPhoto, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: Image.file(
                  File(item.productImagePath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 160,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: Center(child: Text(l.productPhotoMissing)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Receipt image
// ══════════════════════════════════════════════════════════════════════
class _ReceiptImage extends StatelessWidget {
  const _ReceiptImage({required this.item, required this.l});
  final WarrantyItem item;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.receipt, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Image.file(
                File(item.receiptImagePath!),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  height: 200,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  child: Center(child: Text(l.receiptImageMissing)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Documents
// ══════════════════════════════════════════════════════════════════════
class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({required this.item, required this.l});
  final WarrantyItem item;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.documents, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...item.documents.map((doc) {
              final fileExists = File(doc.filePath).existsSync();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.4),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(doc.label),
                subtitle: Text(
                  fileExists ? l.tapToView : l.fileNotFound,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () async {
                    final state = context
                        .findAncestorStateOfType<_DetailsScreenState>();
                    await state?._deleteDocument(doc);
                  },
                ),
                onTap: () {
                  context
                      .findAncestorStateOfType<_DetailsScreenState>()
                      ?._previewDocument(doc);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Service history
// ══════════════════════════════════════════════════════════════════════
class _ServiceHistorySection extends StatelessWidget {
  const _ServiceHistorySection({required this.item, required this.l});
  final WarrantyItem item;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.serviceHistory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l.add),
                  onPressed: () {
                    context
                        .findAncestorStateOfType<_DetailsScreenState>()
                        ?._addServiceRecord(item.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (item.serviceRecords.isEmpty)
              Text(
                l.noServiceRecords,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...item.serviceRecords.map((r) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    _ServiceRecordTile(record: r, l: l),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ServiceRecordTile extends StatelessWidget {
  const _ServiceRecordTile({required this.record, required this.l});
  final ServiceRecord record;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(
        Icons.build_outlined,
        color: theme.colorScheme.primary.withValues(alpha: 0.7),
      ),
      title: Text(
        '${record.serviceCenter} — ${DateFormatter.format(record.serviceDate)}',
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (record.description.isNotEmpty)
            Text(
              record.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (record.cost != null)
            Text(
              l.costLabel.withValue(record.cost!.toStringAsFixed(2)),
              style: theme.textTheme.bodySmall,
            ),
          if (record.trackingNumber != null)
            Text(
              l.trackingLabel.withValue(record.trackingNumber!),
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (action) {
          final state = context.findAncestorStateOfType<_DetailsScreenState>();
          if (action == 'edit') {
            state?._editServiceRecord(record);
          } else if (action == 'delete') {
            state?._deleteServiceRecord(record);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text(l.edit)),
          PopupMenuItem(value: 'delete', child: Text(l.delete)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Document viewer
// ══════════════════════════════════════════════════════════════════════
class _DocumentViewer extends StatelessWidget {
  const _DocumentViewer({required this.filePath, required this.label});
  final String filePath;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: InteractiveViewer(
        child: Center(
          child: Image.file(
            File(filePath),
            errorBuilder: (_, _, _) => Center(child: Text(l.fileNotFound)),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Service record dialog
// ══════════════════════════════════════════════════════════════════════
class _ServiceRecordDialog extends StatefulWidget {
  const _ServiceRecordDialog({this.record, required this.warrantyItemId});

  final ServiceRecord? record;
  final String warrantyItemId;

  @override
  State<_ServiceRecordDialog> createState() => _ServiceRecordDialogState();
}

class _ServiceRecordDialogState extends State<_ServiceRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serviceCenterCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _trackingCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _serviceDate;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _serviceCenterCtrl = TextEditingController(text: r?.serviceCenter ?? '');
    _descriptionCtrl = TextEditingController(text: r?.description ?? '');
    _costCtrl = TextEditingController(
      text: r?.cost != null ? r!.cost!.toString() : '',
    );
    _trackingCtrl = TextEditingController(text: r?.trackingNumber ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _serviceDate = r?.serviceDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _serviceCenterCtrl.dispose();
    _descriptionCtrl.dispose();
    _costCtrl.dispose();
    _trackingCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEditing = widget.record != null;
    return AlertDialog(
      title: Text(isEditing ? l.editServiceRecord : l.addServiceRecord),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l.serviceDateLabel,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormatter.format(_serviceDate)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serviceCenterCtrl,
                decoration:
                    InputDecoration(labelText: l.serviceCenterLabel),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? l.serviceCenterRequired
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: InputDecoration(labelText: l.descriptionLabel),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costCtrl,
                decoration:
                    InputDecoration(labelText: l.costOptionalLabel),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _trackingCtrl,
                decoration:
                    InputDecoration(labelText: l.trackingOptionalLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration:
                    InputDecoration(labelText: l.notesOptionalLabel),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEditing ? l.save : l.add),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _serviceDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    double? cost;
    final costStr = _costCtrl.text.trim();
    if (costStr.isNotEmpty) {
      cost = double.tryParse(costStr);
      if (cost == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).invalidCost)),
        );
        return;
      }
    }

    final record = ServiceRecord(
      id: widget.record?.id ?? const Uuid().v4(),
      warrantyItemId: widget.warrantyItemId,
      serviceDate: _serviceDate,
      serviceCenter: _serviceCenterCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      cost: cost,
      trackingNumber:
          _trackingCtrl.text.trim().isEmpty ? null : _trackingCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );
    Navigator.of(context).pop(record);
  }
}
