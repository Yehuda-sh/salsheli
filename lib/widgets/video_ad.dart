// lib/widgets/video_ad.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// מודעת וידאו/באנר עם ספירת דילוג, פרוגרס ונגישות.
/// לוגים: משתמשים ב-debugPrint עם תגית קבועה.
class VideoAd extends StatefulWidget {
  /// צבע ברירת מחדל לשכבת הרקע (מוגדר כ-const כדי למנוע invalid_constant בדיפולטים).
  static const Color kDefaultBarrierColor = Color(0xD9000000); // ~85% שחור

  /// נקרא כאשר המודעה נסגרת (בין אם ע"י דילוג או סגירה אוטומטית).
  final VoidCallback onAdFinish;

  /// סה"כ זמן התצוגה לפני סגירה אוטומטית.
  final Duration totalDuration;

  /// הזמן עד שהדילוג הופך לזמין (<= totalDuration).
  final Duration skipAvailableAfter;

  /// צבע שכבת הרקע (scrim).
  final Color barrierColor;

  /// טקסטים ניתנים להתאמה (RTL by default).
  final String titleText;
  final String subtitleText;
  final String skipHintPrefix; // "תוכל לדלג בעוד"
  final String skipCtaText; // "דלג על המודעה"
  final String closeTooltip; // "סגור פרסומת"
  final String adLabelText; // "מודעה"

  /// כפתור CTA אופציונלי
  final String? ctaText;
  final VoidCallback? onCtaPressed;

  /// הוקים לאנליטיקות
  final VoidCallback? onImpression;
  final VoidCallback? onSkip;
  final VoidCallback? onClosed;

  /// תגית לוגים (אופציונלי)
  final String logTag;

  const VideoAd({
    super.key,
    required this.onAdFinish,
    this.totalDuration = const Duration(seconds: 6),
    this.skipAvailableAfter = const Duration(seconds: 3),
    this.barrierColor = kDefaultBarrierColor,
    this.titleText = "מתכוננים לקנייה!",
    this.subtitleText = "בעוד רגע נתחיל את הקנייה החכמה שלך",
    this.skipHintPrefix = "תוכל לדלג בעוד",
    this.skipCtaText = "דלג על המודעה",
    this.closeTooltip = "סגור פרסומת",
    this.adLabelText = "מודעה",
    this.ctaText,
    this.onCtaPressed,
    this.onImpression,
    this.onSkip,
    this.onClosed,
    this.logTag = "VideoAd",
  }) : assert(skipAvailableAfter >= Duration.zero),

       assert(totalDuration > Duration.zero),
       assert(skipAvailableAfter <= totalDuration);

  @override
  State<VideoAd> createState() => _VideoAdState();
}

class _VideoAdState extends State<VideoAd>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _fadeController;
  late final CurvedAnimation _fade;
  Timer? _ticker; // טיימר עדכון פרוגרס
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  bool _isVisible = true;
  bool _skipAvailable = false;
  bool _autoClosed = false;

  // דיווח נוח
  void _log(String msg) => debugPrint('[${widget.logTag}] $msg');

  // חישובים נלווים
  Duration get _remainingTotal =>
      widget.totalDuration - _elapsed < Duration.zero
      ? Duration.zero
      : widget.totalDuration - _elapsed;

  Duration get _remainingToSkip =>
      widget.skipAvailableAfter - _elapsed < Duration.zero
      ? Duration.zero
      : widget.skipAvailableAfter - _elapsed;

  // אחוז פרוגרס (0..1) מסה"כ זמן
  double get _progress =>
      (_elapsed.inMilliseconds / widget.totalDuration.inMilliseconds).clamp(
        0.0,
        1.0,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    _startTimers();
  }

  void _startTimers() {
    _startTime ??= DateTime.now();
    _log(
      'Impression. total=${widget.totalDuration.inMilliseconds}ms, '
      'skipAfter=${widget.skipAvailableAfter.inMilliseconds}ms',
    );

    widget.onImpression?.call();

    // עדכון כל 100ms לפרוגרס/ספירה
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (t) {
      final now = DateTime.now();
      _elapsed = now.difference(_startTime!);

      final newSkip = _elapsed >= widget.skipAvailableAfter;
      if (newSkip != _skipAvailable) {
        setState(() {
          _skipAvailable = newSkip;
        });
        if (newSkip) {
          _log('Skip became available at ${_elapsed.inMilliseconds}ms');
        }
      }

      // סגירה אוטומטית
      if (_elapsed >= widget.totalDuration && !_autoClosed) {
        _autoClosed = true;
        _log('Auto close fired at ${_elapsed.inMilliseconds}ms');
        _handleClose(invokeOnSkip: false); // לא נחשיב כדילוג
      } else {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _log('Lifecycle: $state');
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _pause();
    } else if (state == AppLifecycleState.resumed) {
      _resume();
    }
  }

  void _pause() {
    if (_ticker != null && _ticker!.isActive) {
      _ticker!.cancel();
      _ticker = null;
      _log('Timers paused at ${_elapsed.inMilliseconds}ms');
    }
  }

  void _resume() {
    if (_startTime == null) return;
    // מעדכנים את startTime כך שהזמן שהאפליקציה הייתה paused לא יספר.
    _startTime = DateTime.now().subtract(_elapsed);
    _log('Timers resumed at ${_elapsed.inMilliseconds}ms');
    _startTimers();
  }

  Future<void> _handleClose({required bool invokeOnSkip}) async {
    if (!_isVisible || !mounted) {
      return;
    }

    // משוב מוחשי קטן (עטוף ב-try כדי לא להפיל בפלטפורמות שלא תומכות)
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}

    _isVisible = false;
    _ticker?.cancel();

    if (invokeOnSkip) {
      _log('Skip pressed at ${_elapsed.inMilliseconds}ms');
      widget.onSkip?.call();
    } else {
      _log('Closed (no skip) at ${_elapsed.inMilliseconds}ms');
    }

    await _fadeController.reverse();

    // נסגור למעלה (נרשום גם onClosed לצורכי אנליטיקות)
    widget.onClosed?.call();
    widget.onAdFinish();
  }

  String _formatMs(Duration d) {
    final s = d.inSeconds;
    final ss = (s % 60).toString().padLeft(2, '0');
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final canCloseNow = _skipAvailable;

    // שבריר שנייה עגול להודעת ה-"בעוד X"
    final secondsLeftToSkip = (_remainingToSkip.inMilliseconds / 1000)
        .ceil()
        .clamp(0, 999);

    return FadeTransition(
      opacity: _fade,
      child: Scaffold(
        backgroundColor: widget.barrierColor,
        body: SafeArea(
          child: Center(
            child: Semantics(
              label: widget.adLabelText,
              explicitChildNodes: true,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // תוכן המודעה (Placeholder)
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "🛒",
                                style: TextStyle(
                                  fontSize: 64,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.titleText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.subtitleText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              if (widget.ctaText != null &&
                                  widget.onCtaPressed != null) ...[
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    _log(
                                      'CTA pressed at ${_elapsed.inMilliseconds}ms',
                                    );
                                    widget.onCtaPressed!.call();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                  ),
                                  child: Text(widget.ctaText!),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // כפתור סגירה למעלה ימין (נגישות + tooltip)
                      PositionedDirectional(
                        top: 8,
                        end: 8,
                        child: Tooltip(
                          message: canCloseNow
                              ? widget.closeTooltip
                              : '${widget.skipHintPrefix} $secondsLeftToSkip שניות',
                          child: Semantics(
                            button: true,
                            label: widget.closeTooltip,
                            enabled: canCloseNow,
                            child: IconButton(
                              onPressed: canCloseNow
                                  ? () => _handleClose(invokeOnSkip: true)
                                  : null,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // פס התקדמות + חיווי זמן
                      Positioned.fill(
                        bottom: null,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LinearProgressIndicator(
                                value: _progress,
                                minHeight: 3,
                                color: Colors.yellow,
                                backgroundColor: Colors.white10,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${widget.adLabelText} • ${_formatMs(_remainingTotal)}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.white70),
                                    ),
                                    if (!_skipAvailable)
                                      Text(
                                        '${widget.skipHintPrefix} $secondsLeftToSkip...',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.white),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // כפתור "דלג" למטה ימין כאשר זמין
                      PositionedDirectional(
                        bottom: 16,
                        end: 16,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: _skipAvailable
                              ? ElevatedButton.icon(
                                  key: const ValueKey('skip_btn'),
                                  onPressed: () =>
                                      _handleClose(invokeOnSkip: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    elevation: 1,
                                  ),
                                  icon: const Icon(Icons.skip_next),
                                  label: Text(
                                    widget.skipCtaText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(
                                  key: const ValueKey('skip_hint'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${widget.skipHintPrefix} $secondsLeftToSkip...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      // חסימת Back עד שהדילוג זמין (שימוש ב-PopScope החדש)
                      Positioned.fill(
                        child: PopScope(
                          canPop: _skipAvailable,
                          onPopInvokedWithResult:
                              (bool didPop, Object? result) async {
                                if (!didPop) {
                                  if (_skipAvailable) {
                                    _log('Back pressed -> closing via back');
                                    await _handleClose(invokeOnSkip: true);
                                  } else {
                                    _log(
                                      'Back pressed but skip not available yet',
                                    );
                                  }
                                }
                              },
                          child: const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
