// lib/widgets/common/list_type_icon.dart — List type visual — renders custom PNG sticker, falls back to Material icon

import 'package:flutter/material.dart';

import '../../config/list_types_config.dart';

/// 🎨 Visual representation of a list type — sticker PNG when available,
/// Material icon fallback for types without a sticker yet (e.g. household).
///
/// The sticker's colors are baked into the PNG (warm pastel palette
/// matching the sticky-note system), so [fallbackColor] only tints the
/// Material icon path.
class ListTypeIcon extends StatelessWidget {
  /// List type key (e.g. `supermarket`, `pharmacy`). Resolved via
  /// `ListTypes.getByKeySafe` — unknown keys fall back to `other`.
  final String typeKey;

  /// Render size. The sticker scales with `BoxFit.contain`; the Material
  /// icon receives this as its `size`.
  final double size;

  /// Tint for the Material icon fallback. Ignored when a sticker is shown.
  final Color? fallbackColor;

  const ListTypeIcon({
    super.key,
    required this.typeKey,
    required this.size,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final config = ListTypes.getByKeySafe(typeKey);
    final asset = config.stickerAsset;
    if (asset != null) {
      return Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return Icon(
      config.icon,
      color: fallbackColor,
      size: size,
    );
  }
}
