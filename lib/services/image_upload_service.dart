// 📄 lib/services/image_upload_service.dart
//
// 🎯 שירות העלאת תמונות לפרופיל משתמש
// מעלה תמונות ל-Firebase Storage ומחזיר download URL.
//
// 🔗 Related: UserContext, settings_screen.dart, storage.rules

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/error_utils.dart';
import '../l10n/app_strings.dart';

/// שירות העלאת תמונות פרופיל ל-Firebase Storage
///
/// כולל rate limiting — ניתן להחליף תמונה אחת ל-24 שעות.
class ImageUploadService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  /// מפתח ב-SharedPreferences לשמירת זמן העלאה אחרון
  static const _kLastUploadKey = 'profile_image_last_upload';

  /// cooldown בין העלאות (24 שעות)
  static const _uploadCooldown = Duration(hours: 24);

  ImageUploadService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  /// בדיקה אם ניתן להעלות תמונה (cooldown 24 שעות)
  ///
  /// מחזיר null אם מותר, או Duration שנותר לחכות.
  Future<Duration?> getCooldownRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpload = prefs.getInt(_kLastUploadKey) ?? 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastUpload;
    final remaining = _uploadCooldown.inMilliseconds - elapsed;
    if (remaining <= 0) return null; // מותר להעלות
    return Duration(milliseconds: remaining);
  }

  /// שמירת זמן העלאה אחרון
  Future<void> _recordUploadTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastUploadKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// בחירת תמונה מהגלריה או מהמצלמה
  ///
  /// מחזיר [XFile] או null אם המשתמש ביטל.
  /// התמונה נדחסת ל-512px מקסימום (חוסך storage + bandwidth).
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ ImagePicker error: $e');
      return null;
    }
  }

  /// העלאת תמונת פרופיל ל-Firebase Storage
  ///
  /// Path: `/users/{userId}/profile/avatar.jpg`
  /// מחזיר את ה-download URL של התמונה.
  ///
  /// ```dart
  /// final url = await imageService.uploadProfileImage('user123', file);
  /// await userContext.updateUserProfile(profileImageUrl: url);
  /// ```
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    // 🛡️ Rate limiting — בדיקת cooldown
    final cooldown = await getCooldownRemaining();
    if (cooldown != null) {
      final hours = cooldown.inHours;
      final minutes = cooldown.inMinutes % 60;
      final timeStr = hours > 0 ? '$hours שעות ו-$minutes דקות' : '$minutes דקות';
      throw Exception(AppStrings.settings.imageUploadCooldown(timeStr));
    }

    try {
      final ref = _storage.ref('users/$userId/profile/avatar.jpg');

      // metadata לכיווץ cache + content type
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=86400', // 24 hours cache
      );

      await ref.putFile(imageFile, metadata);

      final downloadUrl = await ref.getDownloadURL();

      // שמירת זמן העלאה — cooldown מתחיל
      await _recordUploadTime();

      if (kDebugMode) debugPrint('✅ Profile image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      if (e.toString().contains(AppStrings.settings.imageUploadCooldown(''))) rethrow;
      throw Exception(userFriendlyError(e, context: 'uploadProfileImage'));
    }
  }

  /// מחיקת תמונת פרופיל מ-Firebase Storage
  Future<void> deleteProfileImage(String userId) async {
    try {
      final ref = _storage.ref('users/$userId/profile/avatar.jpg');
      await ref.delete();
      if (kDebugMode) debugPrint('🗑️ Profile image deleted for $userId');
    } catch (e) {
      // שגיאת object-not-found זה OK — אין תמונה למחוק
      if (e is FirebaseException && e.code == 'object-not-found') return;
      if (kDebugMode) debugPrint('⚠️ Delete profile image error: $e');
    }
  }
}
