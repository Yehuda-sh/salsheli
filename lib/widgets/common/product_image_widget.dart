// 📄 lib/widgets/common/product_image_widget.dart
//
// Widget להצגת תמונת מוצר מ-Open Food Facts עם fallback לאייקון קטגוריה.
// כולל loading state, error handling, ותמיכה בגדלים שונים עם CachedNetworkImage.
//
// ✅ תיקונים:
//    - החלפת Colors.grey קשיחים בצבעי Theme (cs.surfaceContainerHighest)
//    - החלפת borderRadius קשיח בקבוע kBorderRadius
//    - הוספת Semantics לנגישות עם semanticLabel
//    - הוספת fadeInDuration/fadeOutDuration לאנימציית טעינה חלקה
//    - תמיכה ב-Dark Mode
//
// 🔗 Related: ProductImageService, CachedNetworkImage

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../services/product_image_service.dart';

class ProductImageWidget extends StatefulWidget {
  final String? barcode;
  final String? category;
  final String? icon;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// תווית נגישות לקוראי מסך (אופציונלי)
  final String? semanticLabel;

  const ProductImageWidget({
    super.key,
    this.barcode,
    this.category,
    this.icon,
    this.size = 60,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  State<ProductImageWidget> createState() => _ProductImageWidgetState();
}

class _ProductImageWidgetState extends State<ProductImageWidget> {
  final ProductImageService _imageService = ProductImageService();
  String? _imageUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ProductImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.barcode != widget.barcode) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final imageUrl = await _imageService.getProductImageUrl(widget.barcode);

      if (!mounted) return;

      setState(() {
        _imageUrl = imageUrl;
        _isLoading = false;
        _hasError = imageUrl == null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(kBorderRadius);

    // ✅ תווית נגישות ברירת מחדל
    final effectiveSemanticLabel = widget.semanticLabel ??
        (widget.category != null ? 'תמונת מוצר - ${widget.category}' : 'תמונת מוצר');

    return Semantics(
      image: true,
      label: effectiveSemanticLabel,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: cs.surfaceContainerHighest, // ✅ Theme-aware במקום Colors.grey[100]
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: _buildContent(cs),
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs) {
    // מצב טעינה
    if (_isLoading) {
      return _buildPlaceholder(cs);
    }

    // יש תמונה - הצג אותה
    if (_imageUrl != null && !_hasError) {
      return CachedNetworkImage(
        imageUrl: _imageUrl!,
        fit: widget.fit,
        fadeInDuration: const Duration(milliseconds: 300), // ✅ אנימציית fade-in חלקה
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => _buildPlaceholder(cs),
        errorWidget: (context, url, error) => _buildFallbackIcon(cs),
      );
    }

    // אין תמונה - הצג אייקון
    return _buildFallbackIcon(cs);
  }

  /// Placeholder בזמן טעינה
  Widget _buildPlaceholder(ColorScheme cs) {
    return Center(
      child: SizedBox(
        width: widget.size * 0.3,
        height: widget.size * 0.3,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            cs.onSurfaceVariant, // ✅ Theme-aware במקום Colors.grey[400]
          ),
        ),
      ),
    );
  }

  /// Fallback לאייקון קטגוריה
  Widget _buildFallbackIcon(ColorScheme cs) {
    final icon = widget.icon ?? '📦';

    return Container(
      color: cs.surfaceContainerLow, // ✅ Theme-aware במקום Colors.grey[50]
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}
