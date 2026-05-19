// lib/services/user_product_photos_service.dart — Local user-uploaded product photos, keyed by barcode

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:path_provider/path_provider.dart';

import 'prefs_cache.dart';

/// User-uploaded product photos kept **on-device only**.
///
/// Why local-only:
/// The user said "appears only for them" — i.e. if a household member
/// uploads a photo of a product without a catalog image, only that user
/// should see it. Keeping the bytes on-device avoids Firebase Storage
/// costs, cross-device permission gymnastics, and a Firestore round-trip
/// every time the thumbnail renders.
///
/// Trade-off accepted: re-installing the app loses the photos. We can
/// add an opt-in backup later (Drive / iCloud) without changing this API.
///
/// Storage layout:
///   `ApplicationDocumentsDirectory/`
///     `user_product_photos/`
///       `{barcode}.jpg`                          ← image bytes
///   `SharedPreferences[user_product_photos_map]` ← `{barcode: path}` JSON
///
/// The prefs map is the source of truth. A file with no map entry is
/// treated as orphaned; a map entry whose file is missing is auto-pruned
/// on next read.
class UserProductPhotosService {
  UserProductPhotosService._();

  static const String _kPrefsKey = 'user_product_photos_map';
  static const String _kPhotosDirName = 'user_product_photos';

  /// In-memory mirror of the persisted map. Hydrated on first call; kept
  /// in sync with prefs on every mutation. Reads are O(1) — important
  /// because ProductThumbnail.build() calls [getPhotoPath] inline.
  static Map<String, String>? _cache;

  static void _hydrate() {
    if (_cache != null) return;
    final prefs = PrefsCache.instance;
    if (prefs == null) {
      _cache = {};
      return;
    }
    final raw = prefs.getString(_kPrefsKey);
    if (raw == null || raw.isEmpty) {
      _cache = {};
      return;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _cache = decoded.map((k, v) => MapEntry(k, v as String));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ UserProductPhotosService: failed to decode prefs, resetting');
      }
      _cache = {};
    }
  }

  static Future<void> _persist() async {
    final prefs = PrefsCache.instance;
    if (prefs == null) return;
    await prefs.setString(_kPrefsKey, jsonEncode(_cache ?? {}));
  }

  /// Resolves the on-device path to the saved photo for [barcode], or
  /// `null` if none. Cheap, synchronous — safe to call from build().
  ///
  /// Does *not* verify the file exists on disk (that would be a sync
  /// stat per render). [pruneMissing] is the lazy housekeeping path.
  static String? getPhotoPath(String? barcode) {
    if (barcode == null || barcode.isEmpty) return null;
    _hydrate();
    return _cache![barcode];
  }

  /// Persists [sourceFile] as the user photo for [barcode]. Returns the
  /// final on-device path (inside ApplicationDocumentsDirectory) so the
  /// caller can immediately render it.
  ///
  /// If a previous photo existed for this barcode it is deleted before
  /// the new one is written — keeps the directory bounded.
  static Future<String> savePhoto({
    required String barcode,
    required File sourceFile,
  }) async {
    if (barcode.isEmpty) {
      throw ArgumentError('barcode must not be empty');
    }
    _hydrate();

    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${docsDir.path}/$_kPhotosDirName');
    if (!photosDir.existsSync()) {
      photosDir.createSync(recursive: true);
    }

    // Delete previous photo for this barcode, if any — bound directory
    // size when a user re-shoots the same product.
    final existing = _cache![barcode];
    if (existing != null) {
      try {
        final oldFile = File(existing);
        if (oldFile.existsSync()) oldFile.deleteSync();
      } catch (_) {
        // Best-effort — proceed with the new write.
      }
    }

    // Use barcode as filename — barcodes are alphanumeric so no escaping
    // needed. Always .jpg because image_picker re-encodes to JPEG.
    final destPath = '${photosDir.path}/$barcode.jpg';
    await sourceFile.copy(destPath);

    _cache![barcode] = destPath;
    await _persist();
    return destPath;
  }

  /// Removes the saved photo for [barcode] (file + prefs entry).
  /// Idempotent — silently succeeds if nothing is stored.
  static Future<void> deletePhoto(String? barcode) async {
    if (barcode == null || barcode.isEmpty) return;
    _hydrate();
    final path = _cache!.remove(barcode);
    if (path != null) {
      try {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      } catch (_) {
        // Best-effort.
      }
      await _persist();
    }
  }

  /// Drops map entries whose underlying file is missing. Run on app
  /// boot or after a "clear cache" action — not on the render path.
  static Future<void> pruneMissing() async {
    _hydrate();
    final removed = <String>[];
    for (final entry in _cache!.entries) {
      if (!File(entry.value).existsSync()) {
        removed.add(entry.key);
      }
    }
    if (removed.isEmpty) return;
    for (final k in removed) {
      _cache!.remove(k);
    }
    await _persist();
  }

  /// Test/QA hook — wipes both the prefs map and the on-disk directory.
  /// Not exposed in production UI.
  static Future<void> clearAll() async {
    _hydrate();
    _cache!.clear();
    await _persist();
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${docsDir.path}/$_kPhotosDirName');
      if (photosDir.existsSync()) {
        photosDir.deleteSync(recursive: true);
      }
    } catch (_) {
      // Best-effort.
    }
  }
}
