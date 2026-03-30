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

import '../core/error_utils.dart';

/// שירות העלאת תמונות פרופיל ל-Firebase Storage
class ImageUploadService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  ImageUploadService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

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
    try {
      final ref = _storage.ref('users/$userId/profile/avatar.jpg');

      // metadata לכיווץ cache + content type
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=86400', // 24 hours cache
      );

      await ref.putFile(imageFile, metadata);

      final downloadUrl = await ref.getDownloadURL();
      if (kDebugMode) debugPrint('✅ Profile image uploaded: $downloadUrl');

      return downloadUrl;
    } catch (e) {
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
