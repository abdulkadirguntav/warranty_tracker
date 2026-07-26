import 'dart:io';

import 'package:flutter/material.dart';

/// A rounded, elevation-styled thumbnail that displays a product image
/// stored on disk. Falls back to a category-themed placeholder icon
/// when no image path is available or the file can't be read.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    this.imagePath,
    this.size = 64,
    this.borderRadius = 16,
    this.placeholderIcon = Icons.inventory_2_outlined,
  });

  final String? imagePath;
  final double size;
  final double borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.18),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.30),
          ],
        ),
        boxShadow: hasImage
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage && File(imagePath!).existsSync()
          ? Image.file(
              File(imagePath!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  _Placeholder(icon: placeholderIcon, size: size),
            )
          : _Placeholder(icon: placeholderIcon, size: size),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.size});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Icon(
        icon,
        size: size * 0.42,
        color: theme.colorScheme.primary.withValues(alpha: 0.7),
      ),
    );
  }
}
