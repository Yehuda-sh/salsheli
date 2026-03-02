// 📄 lib/widgets/common/product_image_widget.dart
//
// Widget להצגת תמונת מוצר מ-Open Food Facts עם fallback לאייקון קטגוריה.
// כולל loading state, error handling, ותמיכה בגדלים שונים עם CachedNetworkImage.
//
// ✨ Features:
// - טעינת Skeleton מבוססת Skeletonizer
// - אפקט Shimmer פרימיום
// - אנימציית 'צמיחה' (Scale-in) לסיום טעינה
// - אופטימיזציית RepaintBoundary
//
// ✅ תיקונים:
//    - החלפת Colors.grey קשיחים בצבעי Theme (cs.surfaceContainerHighest)
//    - החלפת borderRadius קשיח בקבוע kBorderRadius
//    - הוספת Semantics לנגישות עם semanticLabel
//    - תמיכה ב-Dark Mode
//
// 🔗 Related: ProductImageService, CachedNetworkImage, Skeletonizer
//
// Version: 4.0 - Hybrid Premium (Skeleton + Scale-in)
// Last Updated: 22/02/2026

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

    return RepaintBoundary(
      child: Semantics(
        image: true,
        label: effectiveSemanticLabel,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: cs.surfaceContainerHighest,
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: _buildContent(cs),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs) {
    // מצב טעינה - Skeleton
    if (_isLoading) {
      return _buildSkeletonPlaceholder(cs);
    }

    // יש תמונה - הצג אותה עם אנימציית Scale-in
    if (_imageUrl != null && !_hasError) {
      return CachedNetworkImage(
        imageUrl: _imageUrl!,
        fit: widget.fit,
        fadeInDuration: Duration.zero, // ❌ נשלט ע"י flutter_animate
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => _buildSkeletonPlaceholder(cs),
        errorWidget: (context, url, error) => _buildFallbackIcon(cs),
        imageBuilder: (context, imageProvider) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: widget.fit,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOutBack)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              );
        },
      );
    }

    // אין תמונה - הצג אייקון
    return _buildFallbackIcon(cs);
  }

  /// 💀 Skeleton placeholder בזמן טעינה (Skeletonizer + Shimmer)
  Widget _buildSkeletonPlaceholder(ColorScheme cs) {
    return Skeletonizer(
      child: Container(
        width: widget.size,
        height: widget.size,
        color: cs.surfaceContainerHighest,
      ),
    );
  }

  /// 🎨 Fallback לאייקון קטגוריה עם גרדיאנט עדין
  Widget _buildFallbackIcon(ColorScheme cs) {
    final icon = widget.icon ?? '📦';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.surfaceContainerLow,
            cs.surfaceContainer,
          ],
        ),
      ),
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
