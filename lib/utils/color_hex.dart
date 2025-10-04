// utils/color_hex.dart
import 'package:flutter/material.dart';

Color? colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  var h = hex.replaceAll('#', '');
  if (h.length == 6) h = 'FF$h'; // alpha מלא
  final val = int.tryParse(h, radix: 16);
  if (val == null) return null;
  return Color(val);
}
