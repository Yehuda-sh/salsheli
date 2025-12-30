// 📄 lib/widgets/common/product_image_widget.dart
//
// Widget להצגת תמונת מוצר מ-Open Food Facts עם fallback לאייקון קטגוריה.
// כולל loading state, error handling, ותמיכה בגדלים שונים עם CachedNetworkImage.
//
// 🔗 Related: ProductImageService, CachedNetworkImage

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../services/product_image_service.dart';

class ProductImageWidget extends StatefulWidget {
  final String? barcode;
  final String? category;
  final String? icon;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImageWidget({
    super.key,
    this.barcode,
    this.category,
    this.icon,
    this.size = 60,
    this.fit = BoxFit.cover,
    this.borderRadius,
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
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // מצב טעינה
    if (_isLoading) {
      return _buildPlaceholder();
    }

    // יש תמונה - הצג אותה
    if (_imageUrl != null && !_hasError) {
      return CachedNetworkImage(
        imageUrl: _imageUrl!,
        fit: widget.fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildFallbackIcon(),
      );
    }

    // אין תמונה - הצג אייקון
    return _buildFallbackIcon();
  }

  /// Placeholder בזמן טעינה
  Widget _buildPlaceholder() {
    return Center(
      child: SizedBox(
        width: widget.size * 0.3,
        height: widget.size * 0.3,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.grey[400]!,
          ),
        ),
      ),
    );
  }

  /// Fallback לאייקון קטגוריה
  Widget _buildFallbackIcon() {
    final icon = widget.icon ?? '📦';

    return Container(
      color: Colors.grey[50],
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
