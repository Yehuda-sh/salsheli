// lib/widgets/common/product_photo_uploader.dart — User-photo CTA + bottom sheet (camera / gallery / remove)

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../services/user_product_photos_service.dart';

/// Image-picker compression tuning. Match [ImageUploadService] so the
/// camera-roll thumbnails feel consistent across the app. We're showing
/// these at 96–140px in the dialog hero — 512px source gives 3× headroom
/// for retina + zoomed views without bloating the on-device store.
const int _kMaxImageDimension = 512;
const int _kImageQuality = 80;

/// "Add photo" / "Change photo" CTA shown next to a product thumbnail.
///
/// Why a separate widget (not inline inside the two dialogs):
/// shopping_list and pantry dialogs both need exactly this affordance —
/// a small chip that opens a bottom sheet with Camera / Gallery /
/// Remove. Extracting it keeps the dialogs from drifting (one growing a
/// "remove" option, the other not) and centralizes the
/// [UserProductPhotosService] calls.
///
/// Privacy contract: photos are stored **only on this device**. The CTA
/// label intentionally avoids "upload" — there's no server round-trip.
class ProductPhotoUploader extends StatefulWidget {
  /// Barcode of the product. Photos are keyed by barcode so the same
  /// user-shot image surfaces wherever the product appears (shopping
  /// list ⇄ pantry).
  final String barcode;

  /// Called after a successful save/remove so the parent can refresh
  /// its thumbnail. The new path (or null on remove) is passed.
  final void Function(String? newPath)? onChanged;

  const ProductPhotoUploader({
    super.key,
    required this.barcode,
    this.onChanged,
  });

  @override
  State<ProductPhotoUploader> createState() => _ProductPhotoUploaderState();
}

class _ProductPhotoUploaderState extends State<ProductPhotoUploader> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  bool get _hasPhoto =>
      UserProductPhotosService.getPhotoPath(widget.barcode) != null;

  Future<void> _openSheet() async {
    if (_busy) return;
    unawaited(HapticFeedback.selectionClick());
    final hasPhoto = _hasPhoto;
    final strings = AppStrings.inventory;

    final result = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  kSpacingMedium,
                  kSpacingSmall,
                  kSpacingMedium,
                  kSpacingXTiny,
                ),
                child: Row(
                  children: [
                    Text(
                      strings.photoSheetTitle,
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  kSpacingMedium, 0, kSpacingMedium, kSpacingSmall,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.photoSheetHint,
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(strings.photoOptionCamera),
                onTap: () => Navigator.pop(ctx, _PhotoAction.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(strings.photoOptionGallery),
                onTap: () => Navigator.pop(ctx, _PhotoAction.gallery),
              ),
              if (hasPhoto)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(ctx).colorScheme.error,
                  ),
                  title: Text(
                    strings.photoOptionRemove,
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.error,
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx, _PhotoAction.remove),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || result == null) return;
    switch (result) {
      case _PhotoAction.camera:
        await _pickAndSave(ImageSource.camera);
      case _PhotoAction.gallery:
        await _pickAndSave(ImageSource.gallery);
      case _PhotoAction.remove:
        await _remove();
    }
  }

  Future<void> _pickAndSave(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final xfile = await _picker.pickImage(
        source: source,
        maxWidth: _kMaxImageDimension.toDouble(),
        maxHeight: _kMaxImageDimension.toDouble(),
        imageQuality: _kImageQuality,
      );
      if (xfile == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final newPath = await UserProductPhotosService.savePhoto(
        barcode: widget.barcode,
        sourceFile: File(xfile.path),
      );
      if (!mounted) return;
      unawaited(HapticFeedback.lightImpact());
      widget.onChanged?.call(newPath);
      _showToast(AppStrings.inventory.photoSavedToast, isError: false);
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ ProductPhotoUploader: $e');
      if (!mounted) return;
      _showToast(AppStrings.inventory.photoErrorToast, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    setState(() => _busy = true);
    try {
      await UserProductPhotosService.deletePhoto(widget.barcode);
      if (!mounted) return;
      unawaited(HapticFeedback.lightImpact());
      widget.onChanged?.call(null);
      _showToast(AppStrings.inventory.photoRemovedToast, isError: false);
    } catch (e) {
      // Mirror _pickAndSave: a failed delete must surface an error toast,
      // not fail silently on a destructive action.
      if (kDebugMode) debugPrint('⚠️ ProductPhotoUploader remove: $e');
      if (!mounted) return;
      _showToast(AppStrings.inventory.photoErrorToast, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showToast(String message, {required bool isError}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: kSnackBarDuration,
          backgroundColor: isError
              ? StatusColors.getColor(StatusType.error, context)
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.inventory;
    final hasPhoto = _hasPhoto;

    return TextButton.icon(
      onPressed: _busy ? null : _openSheet,
      icon: _busy
          ? const SizedBox(
              width: kIconSizeSmall,
              height: kIconSizeSmall,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              hasPhoto
                  ? Icons.photo_camera
                  : Icons.add_a_photo_outlined,
              size: kIconSizeSmall,
              color: cs.primary,
            ),
      label: Text(
        hasPhoto ? strings.photoChangeCta : strings.photoAddCta,
        style: TextStyle(
          fontSize: kFontSizeSmall,
          color: cs.primary,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingSmall,
          vertical: kSpacingXTiny,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

enum _PhotoAction { camera, gallery, remove }
