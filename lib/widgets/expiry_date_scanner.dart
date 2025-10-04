// 📄 File: lib/widgets/expiry_date_scanner.dart
// תיאור: דיאלוג לצילום תאריך תוקף באמצעות המצלמה
//
// תכונות:
// - פתיחת מצלמה במסך מלא
// - מסגרת מנחה למיקום תאריך התוקף
// - החלפה בין מצלמות (אם קיימות)
// - צילום ושמירת תמונה
// - תואם Material Design: theme colors, גדלי מגע 48px
//
// תלויות:
// - camera package
// - path_provider package
// - path package
// - Theme colors (AppBrand)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../theme/app_theme.dart';

// ============================
// קבועים
// ============================

const double _kDialogHeight = 500.0;
const double _kDialogPadding = 16.0;
const double _kHeaderPadding = 12.0;
const double _kHeaderFontSize = 16.0;
const double _kFrameWidth = 250.0;
const double _kFrameHeight = 120.0;
const double _kFrameBorderWidth = 3.0;
const double _kFrameBorderRadius = 12.0;
const double _kInstructionFontSize = 14.0;
const double _kHintFontSize = 12.0;
const double _kButtonMinHeight = 48.0;
const double _kIconSize = 24.0;

// ============================
// Widget
// ============================

class ExpiryDateScannerDialog extends StatefulWidget {
  final void Function(File file) onImageCaptured;

  const ExpiryDateScannerDialog({super.key, required this.onImageCaptured});

  @override
  State<ExpiryDateScannerDialog> createState() =>
      _ExpiryDateScannerDialogState();
}

class _ExpiryDateScannerDialogState extends State<ExpiryDateScannerDialog> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  bool _isBusy = false;
  int _cameraIndex = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'לא נמצאה מצלמה במכשיר';
        });
        return;
      }

      _controller = CameraController(
        _cameras![_cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isReady = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint('❌ שגיאה באתחול מצלמה: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'שגיאה באתחול המצלמה';
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() => _isReady = false);

    try {
      _cameraIndex = (_cameraIndex + 1) % _cameras!.length;
      await _controller?.dispose();
      await _initCamera();
    } catch (e) {
      debugPrint('❌ שגיאה בהחלפת מצלמה: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'שגיאה בהחלפת מצלמה';
          _isReady = false;
        });
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isBusy) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      final image = await _controller!.takePicture();
      final dir = await getTemporaryDirectory();
      final filePath = p.join(
        dir.path,
        'expiry_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final saved = await File(image.path).copy(filePath);

      widget.onImageCaptured(saved);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ שגיאה בצילום: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'שגיאה בצילום התמונה';
          _isBusy = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    return Dialog(
      insetPadding: const EdgeInsets.all(_kDialogPadding),
      child: SizedBox(
        height: _kDialogHeight,
        child: Column(
          children: [
            // Header
            _buildHeader(theme, cs, brand),

            // תוכן ראשי - תצוגת מצלמה או שגיאה
            Expanded(
              child: _errorMessage != null
                  ? _buildErrorState(cs)
                  : (_isReady
                        ? _buildCameraPreview(cs, brand)
                        : _buildLoadingState(cs, brand)),
            ),

            // כפתורי פעולה
            _buildActions(cs, brand),

            // הוראות שימוש
            _buildInstructions(theme, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme cs, AppBrand? brand) {
    return Padding(
      padding: const EdgeInsets.all(_kHeaderPadding),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: brand?.accent ?? cs.primary,
            size: _kIconSize,
          ),
          const SizedBox(width: 8),
          Text(
            'צילום תאריך תוקף',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: _kHeaderFontSize,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(ColorScheme cs, AppBrand? brand) {
    return Semantics(
      label: 'תצוגת מצלמה לצילום תאריך תוקף',
      child: Stack(
        children: [
          // תצוגת המצלמה
          CameraPreview(_controller!),

          // מסגרת מנחה
          Center(
            child: Container(
              width: _kFrameWidth,
              height: _kFrameHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: brand?.accent ?? cs.primary,
                  width: _kFrameBorderWidth,
                ),
                borderRadius: BorderRadius.circular(_kFrameBorderRadius),
                color: (brand?.accent ?? cs.primary).withValues(alpha: 0.1),
              ),
            ),
          ),

          // הוראה על המסך
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: brand?.accent ?? cs.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'מקם את תאריך התוקף בתוך המסגרת',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: _kInstructionFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme cs, AppBrand? brand) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: brand?.accent ?? cs.primary),
          const SizedBox(height: 16),
          Text('מאתחל מצלמה...', style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildErrorState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'שגיאה לא ידועה',
              style: TextStyle(color: cs.error, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isReady = false;
                });
                _initCamera();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('נסה שוב'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(ColorScheme cs, AppBrand? brand) {
    return Padding(
      padding: const EdgeInsets.all(_kHeaderPadding),
      child: Row(
        children: [
          // כפתור החלפת מצלמה
          if (_cameras != null && _cameras!.length > 1)
            SizedBox(
              width: _kButtonMinHeight,
              height: _kButtonMinHeight,
              child: IconButton(
                icon: const Icon(Icons.cameraswitch),
                onPressed: _isReady && !_isBusy ? _switchCamera : null,
                tooltip: 'החלף מצלמה',
              ),
            ),

          const Spacer(),

          // כפתור צילום
          SizedBox(
            height: _kButtonMinHeight,
            child: ElevatedButton.icon(
              onPressed: _isReady && !_isBusy ? _capturePhoto : null,
              icon: _isBusy
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(_isBusy ? 'מצלם...' : 'צלם תאריך'),
              style: ElevatedButton.styleFrom(
                backgroundColor: brand?.accent ?? cs.primary,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(ThemeData theme, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'צלם את תאריך התוקף המודפס על האריזה\nהמערכת תנסה לזהות אותו אוטומטית',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: _kHintFontSize,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
