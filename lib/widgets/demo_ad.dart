// 📄 File: lib/widgets/demo_ad.dart
// תיאור: פרסומת דמו (Banner Ad) להצגה במסכים
//
// ⚠️ לשימוש בדמו/פיתוח בלבד - לא לפרודקשן!
//
// תכונות:
// - תצוגת פרסומת כרטיס עם תמונה, כותרת, תיאור וכפתור
// - בחירה אקראית מרשימת פרסומות
// - אפשרות לסגירה
// - תואם Material Design: theme colors, גדלי מגע 48px
//
// תלויות:
// - Theme colors (AppBrand)

import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// ============================
// קבועים
// ============================

const double _kCardMargin = 12.0;
const double _kCardPadding = 12.0;
const double _kCardBorderRadius = 12.0;
const double _kImageSize = 64.0;
const double _kImageBorderRadius = 8.0;
const double _kTitleFontSize = 16.0;
const double _kDescriptionFontSize = 13.0;
const double _kButtonMinHeight = 48.0;
const double _kCloseButtonSize = 32.0;

// ============================
// Widget
// ============================

class DemoAd extends StatefulWidget {
  /// סוג הפרסומת (כרגע רק 'banner')
  final String type;

  const DemoAd({super.key, this.type = 'banner'});

  @override
  State<DemoAd> createState() => _DemoAdState();
}

class _DemoAdState extends State<DemoAd> {
  bool _isVisible = true;

  // רשימת פרסומות דמו
  final List<Map<String, String>> _ads = [
    {
      'title': 'מבצעי השבוע בשופרסל!',
      'description': 'כל מוצרי החלב ב-20% הנחה. אל תפספסו!',
      'emoji': '🛒',
      'cta': 'לקופונים',
    },
    {
      'title': 'חדש ברמי לוי!',
      'description': 'סדרת מוצרים אורגניים במחירים שיפתיעו אתכם.',
      'emoji': '🌿',
      'cta': 'לפרטים',
    },
    {
      'title': 'סופר סופר!',
      'description': 'מבצע 1+1 על מאות מוצרים. תבדקו במדפים!',
      'emoji': '🎉',
      'cta': 'למבצעים',
    },
  ];

  late final Map<String, String> _selectedAd;

  @override
  void initState() {
    super.initState();
    _selectedAd = _ads[Random().nextInt(_ads.length)];
  }

  void _handleClose() {
    setState(() => _isVisible = false);
  }

  void _handleCtaClick(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('נלחץ: ${_selectedAd["cta"]}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    switch (widget.type) {
      case 'banner':
        return _buildBannerAd(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBannerAd(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    return Semantics(
      label: 'פרסומת: ${_selectedAd["title"]}',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(sizeFactor: animation, child: child),
          );
        },
        child: Card(
          key: ValueKey(_selectedAd['title']),
          margin: const EdgeInsets.only(bottom: _kCardMargin),
          color: cs.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kCardBorderRadius),
            side: BorderSide(
              color: (brand?.accent ?? cs.primary).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(_kCardPadding),
                child: Row(
                  children: [
                    // אמוג'י במקום תמונה חיצונית
                    Container(
                      width: _kImageSize,
                      height: _kImageSize,
                      decoration: BoxDecoration(
                        color: (brand?.accent ?? cs.primary).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          _kImageBorderRadius,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _selectedAd['emoji'] ?? '📢',
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // תוכן
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAd['title'] ?? '',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: _kTitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAd['description'] ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: _kDescriptionFontSize,
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // כפתור CTA
                    SizedBox(
                      height: _kButtonMinHeight,
                      child: ElevatedButton(
                        onPressed: () => _handleCtaClick(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand?.accent ?? cs.primary,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(_selectedAd['cta'] ?? 'לחץ'),
                      ),
                    ),
                  ],
                ),
              ),

              // כפתור סגירה
              Positioned(
                top: 4,
                left: 4,
                child: Semantics(
                  button: true,
                  label: 'סגור פרסומת',
                  child: SizedBox(
                    width: _kCloseButtonSize,
                    height: _kCloseButtonSize,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: _handleClose,
                      tooltip: 'סגור',
                      color: cs.onSurfaceVariant,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
