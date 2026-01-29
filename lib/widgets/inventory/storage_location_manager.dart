// 📄 lib/widgets/inventory/storage_location_manager.dart
//
// ווידג'ט לניהול מלאי לפי מיקומי אחסון - מקרר, מזווה, הקפאה וכו'.
// כולל סינון, מיון, תפוגה צבעונית, מיקומים מותאמים עם Undo, ו-cache לביצועים.
//
// 🔗 Related: InventoryItem, LocationsProvider, StorageLocationsConfig

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: directives_ordering
import 'package:memozap/config/filters_config.dart';
import 'package:memozap/config/storage_locations_config.dart';
import 'package:memozap/core/status_colors.dart';
import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/models/custom_location.dart';
import 'package:memozap/models/inventory_item.dart';
import 'package:memozap/providers/locations_provider.dart';

class StorageLocationManager extends StatefulWidget {
  final List<InventoryItem> inventory;
  final String searchQuery;
  final Function(InventoryItem)? onEditItem;
  final Function(InventoryItem)? onDeleteItem;
  final Function(InventoryItem, int)? onUpdateQuantity;
  final Function(InventoryItem)? onAddToList;

  const StorageLocationManager({
    super.key,
    required this.inventory,
    this.searchQuery = '',
    this.onEditItem,
    this.onDeleteItem,
    this.onUpdateQuantity,
    this.onAddToList,
  });

  @override
  State<StorageLocationManager> createState() => _StorageLocationManagerState();
}

class _StorageLocationManagerState extends State<StorageLocationManager> {
  String selectedLocation = 'all';
  bool gridMode = true;
  String sortBy = 'name'; // name, quantity, category

  /// דגל למניעת לחיצות כפולות בזמן שמירה/מחיקה
  bool _isSaving = false;

  final TextEditingController newLocationController = TextEditingController();

  // Cache לביצועים
  List<InventoryItem> _cachedFilteredItems = [];
  String _lastCacheKey = '';

  // רשימת אמוג'י לבחירה
  final List<String> _availableEmojis = [
    '📍',
    '🏠',
    '❄️',
    '🧊',
    '📦',
    '🛁',
    '🧺',
    '🚗',
    '🧼',
    '🧂',
    '🍹',
    '🍕',
    '🎁',
    '🎒',
    '🧰',
    '🎨',
    '📚',
    '🔧',
    '🏺',
    '🗄️',
  ];

  @override
  void initState() {
    super.initState();
    _loadGridMode();
  }

  @override
  void didUpdateWidget(StorageLocationManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    // נקה cache כשה-inventory משתנה
    if (widget.inventory != oldWidget.inventory) {
      _lastCacheKey = '';
      _cachedFilteredItems = [];
    }
  }

  @override
  void dispose() {
    newLocationController.dispose();
    super.dispose();
  }

  /// טעינת העדפת תצוגה (grid vs list) מ-SharedPreferences
  Future<void> _loadGridMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getBool('storage_grid_mode') ?? true;
      // ✅ בדיקת mounted אחרי async operation
      if (!mounted) return;
      setState(() {
        gridMode = savedMode;
      });
    } catch (e) {
      // ברירת מחדל
      if (!mounted) return;
      setState(() {
        gridMode = true;
      });
    }
  }

  /// שמירת העדפת תצוגה ל-SharedPreferences
  ///
  /// שומר את בחירת המשתמש בין תצוגת grid לlist
  /// משמש כיד עבור _loadGridMode() בעת ההתחלה
  ///
  /// [value] - true לـ grid, false לـ list
  Future<void> _saveGridMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('storage_grid_mode', value);
    } catch (e) {
      // שגיאה בשמירה - התעלם
    }
  }

  /// סינון מלאי לפי מיקום וחיפוש עם Cache לביצועים
  ///
  /// תהליך:
  /// 1. בדיקה אם cache עדיין בעל ערך (cacheKey זהה)
  /// 2. סינון לפי selectedLocation (אם לא "all")
  /// 3. סינון לפי searchQuery (case-insensitive)
  /// 4. מיון לפי sortBy (name, quantity, category)
  /// 5. עדכון cache עם התוצאה
  ///
  /// Performance: Cache מנקה כשמשתנה selectedLocation/searchQuery/sortBy
  ///
  /// Returns: List&lt;InventoryItem&gt; מסננת ומסודרת
  List<InventoryItem> get filteredInventory {
    final cacheKey = '$selectedLocation|${widget.searchQuery}|$sortBy';

    // ✅ Cache תקף גם לרשימות ריקות - בדיקת cacheKey מספיקה
    if (cacheKey == _lastCacheKey) {
      return _cachedFilteredItems;
    }

    // יצירת עותק modifiable של הרשימה
    var items = List<InventoryItem>.from(widget.inventory);

    // סינון לפי מיקום
    if (selectedLocation != 'all') {
      items = items.where((i) => i.location == selectedLocation).toList();
    }

    // סינון לפי חיפוש - לא רגיש לאותיות גדולות/קטנות
    if (widget.searchQuery.isNotEmpty) {
      final query = widget.searchQuery.toLowerCase();
      items = items
          .where(
            (i) =>
                i.productName.toLowerCase().contains(query) ||
                i.category.toLowerCase().contains(query) ||
                i.location.toLowerCase().contains(query),
          )
          .toList();
    }

    // מיון
    switch (sortBy) {
      case 'quantity':
        items.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'category':
        items.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'expiry':
        // מיון לפי תפוגה - פגי תוקף ראשונים, אחריהם קרובים לתפוגה, אחרונים ללא תפוגה
        items.sort((a, b) {
          // אם לשניהם אין תפוגה - לפי שם
          if (a.expiryDate == null && b.expiryDate == null) {
            return a.productName.compareTo(b.productName);
          }
          // אם רק לאחד אין תפוגה - הוא בסוף
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          // שניהם עם תפוגה - לפי תאריך
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
      case 'name':
      default:
        items.sort((a, b) => a.productName.compareTo(b.productName));
    }

    _cachedFilteredItems = items;
    _lastCacheKey = cacheKey;

    return items;
  }

  /// קבלת אמוג'י לפי קטגוריה (תמיכה בעברית ואנגלית)
  ///
  /// חיפוש:
  /// 1. בקטגוריות עברית → המרה לאנגלית → אמוג'י
  /// 2. בקטגוריות אנגלית ישירות
  /// 3. ברירת מחדל: "📦" אם לא נמצא
  ///
  /// דוגמאות:
  /// - "מוצרי חלב" → "🥛"
  /// - "dairy" → "🥛"
  /// - "ירקות" → "🥬"
  ///
  /// [category] - שם הקטגוריה בעברית או אנגלית
  /// Returns: Emoji string
  String _getProductEmoji(String category) {
    // נסה להמיר מעברית לאנגלית
    final englishKey = hebrewCategoryToEnglish(category);
    if (englishKey != null) {
      return getCategoryEmoji(englishKey);
    }

    // נסה ישירות כמפתח אנגלית
    return getCategoryEmoji(category);
  }

  /// הצגת תפריט מיון
  void _showSortMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(value: 'name', child: Text('לפי שם')),
        const PopupMenuItem(value: 'quantity', child: Text('לפי כמות')),
        const PopupMenuItem(value: 'category', child: Text('לפי קטגוריה')),
        const PopupMenuItem(value: 'expiry', child: Text('לפי תפוגה')),
      ],
    ).then((value) {
      if (value != null) {
        unawaited(HapticFeedback.selectionClick());
        setState(() {
          sortBy = value;
          _lastCacheKey = '';
        });
      }
    });
  }

  /// הצגת דיאלוג להוספת מיקום אחסון חדש
  ///
  /// תכונות:
  /// - בחירת אמוג'י מרשימה (_availableEmojis)
  /// - TextField לשם המיקום
  /// - RTL support (Directionality)
  /// - Validation: שם לא יכול להיות ריק
  /// - Error handling: בדיקה אם מיקום כבר קיים
  /// - UI Feedback: SnackBar בהצלחה/כשל
  /// - Provider integration: LocationsProvider.addLocation()
  ///
  /// Emojis:
  /// - דפוליים: "📍", "🏠", "❄️", "🧊", "📦", וכו'
  /// - בחירה באמצעות GestureDetector + StatefulBuilder
  void _showAddLocationDialog() {
    final cs = Theme.of(context).colorScheme;
    newLocationController.clear();
    String selectedEmoji = '📍';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('הוספת מיקום חדש'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // בחירת אמוג'י
                    const Text('בחר אמוג\'י:', style: TextStyle(fontSize: kFontSizeTiny)),
                    const SizedBox(height: kSpacingSmall),
                    Wrap(
                      spacing: kSpacingSmall,
                      runSpacing: kSpacingSmall,
                      children: _availableEmojis.map((emoji) {
                        final isSelected = emoji == selectedEmoji;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedEmoji = emoji;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(kSpacingSmall),
                            decoration: BoxDecoration(
                              color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                              border: Border.all(
                                color: isSelected ? cs.primary : Colors.transparent,
                                width: kBorderWidthThick,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: kIconSize)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: kSpacingMedium),
                    // שם המיקום
                    TextField(
                      controller: newLocationController,
                      decoration: const InputDecoration(
                        labelText: 'שם המיקום',
                        hintText: 'לדוגמה: "מקרר קטן"',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ביטול')),
                  ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            final name = newLocationController.text.trim();
                            if (name.isEmpty) {
                              return;
                            }
                            setState(() => _isSaving = true);
                            unawaited(HapticFeedback.lightImpact());
                            final provider = context.read<LocationsProvider>();
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(dialogContext);

                            try {
                              final success = await provider.addLocation(name, emoji: selectedEmoji);

                              if (mounted) {
                                navigator.pop();

                                if (success) {
                                  messenger.showSnackBar(SnackBar(content: Text('נוסף מיקום חדש: $name')));
                                } else {
                                  messenger.showSnackBar(const SnackBar(content: Text('מיקום זה כבר קיים')));
                                }
                              }
                            } finally {
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    child: const Text('הוסף'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// עריכת מיקום אחסון מותאם (custom location)
  ///
  /// 🔒 מאפשר רק עריכת אמוג'י - שינוי שם יגרום לאיבוד קישור לפריטי מלאי
  /// (key נגזר מהשם, ולכן שינוי שם = key חדש = פריטים יתומים)
  ///
  /// [loc] - ה-CustomLocation לעריכה (מכיל key, name, emoji)
  void _showEditLocationDialog(CustomLocation loc) {
    final cs = Theme.of(context).colorScheme;
    String selectedEmoji = loc.emoji;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('עריכת אמוג\'י'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // הצגת שם המיקום (לא ניתן לעריכה)
                    Text(
                      loc.name,
                      style: TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: kSpacingMedium),
                    // בחירת אמוג'י
                    const Text('בחר אמוג\'י:', style: TextStyle(fontSize: kFontSizeTiny)),
                    const SizedBox(height: kSpacingSmall),
                    Wrap(
                      spacing: kSpacingSmall,
                      runSpacing: kSpacingSmall,
                      children: _availableEmojis.map((emoji) {
                        final isSelected = emoji == selectedEmoji;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedEmoji = emoji;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(kSpacingSmall),
                            decoration: BoxDecoration(
                              color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                              border: Border.all(
                                color: isSelected ? cs.primary : Colors.transparent,
                                width: kBorderWidthThick,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: kIconSize)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ביטול')),
                  ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            // רק אם האמוג'י השתנה
                            if (selectedEmoji == loc.emoji) {
                              Navigator.pop(dialogContext);
                              return;
                            }

                            setState(() => _isSaving = true);
                            unawaited(HapticFeedback.lightImpact());
                            final provider = context.read<LocationsProvider>();
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(dialogContext);

                            try {
                              // עדכון אמוג'י בלבד - שימוש באותו שם = אותו key = פריטים נשארים מקושרים
                              await provider.deleteLocation(loc.key);
                              await provider.addLocation(loc.name, emoji: selectedEmoji);

                              if (mounted) {
                                navigator.pop();
                                messenger.showSnackBar(const SnackBar(content: Text('האמוג\'י עודכן')));
                              }
                            } catch (e) {
                              if (mounted) {
                                messenger.showSnackBar(const SnackBar(content: Text('שגיאה בעדכון האמוג\'י')));
                              }
                            } finally {
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    child: const Text('שמור'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// מחיקת מיקום אחסון מותאם עם אישור + Undo
  ///
  /// תהליך:
  /// 1. AlertDialog עם אישור מחיקה
  /// 2. ElevatedButton אדום "מחק" כפתור פעולה
  /// 3. מחיקה מ-Firestore דרך LocationsProvider
  /// 4. SnackBar עם Undo action (משחזור)
  ///
  /// Undo:
  /// - משך: 5 שניות
  /// - פעולה: provider.addLocation() עם הנתונים המקוריים
  /// - RTL support (Directionality)
  ///
  /// [key] - ה-key של המיקום (unique identifier)
  /// [name] - שם המיקום (לעריכה בעת Undo)
  /// [emoji] - האמוג'י של המיקום (לעריכה בעת Undo)
  void _deleteCustomLocation(String key, String name, String emoji) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('מחיקת מיקום'),
            content: Text('האם למחוק את "$name"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ביטול')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        unawaited(HapticFeedback.mediumImpact());
                        final provider = context.read<LocationsProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(dialogContext);

                        try {
                          await provider.deleteLocation(key);

                          if (mounted) {
                            navigator.pop();

                            // הצג Snackbar עם Undo
                            messenger.showSnackBar(
                              SnackBar(
                                content: const Text('המיקום נמחק'),
                                action: SnackBarAction(
                                  label: 'בטל',
                                  onPressed: () async {
                                    await provider.addLocation(name, emoji: emoji);
                                  },
                                ),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
                child: const Text('מחק'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// עריכת פריט מלאי
  ///
  /// קריאה ל-onEditItem callback עם הפריט שנבחר
  /// משמש ליצור עדכון/פתיחת מסך עריכה בחוץ
  ///
  /// [item] - ה-InventoryItem לעריכה
  void _editItem(InventoryItem item) {
    if (widget.onEditItem != null) {
      widget.onEditItem!(item);
    }
  }

  /// מציג דיאלוג אישור מחיקה לפריט
  void _confirmDeleteItem(InventoryItem item) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('מחיקת פריט'),
          content: Text('האם למחוק את "${item.productName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onDeleteItem?.call(item);
              },
              child: const Text('מחק'),
            ),
          ],
        ),
      ),
    );
  }

  /// מציג דיאלוג מהיר לשינוי כמות
  void _showQuickQuantityDialog(InventoryItem item) {
    final cs = Theme.of(context).colorScheme;
    int quantity = item.quantity;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              item.productName,
              style: TextStyle(fontSize: kFontSizeMedium, color: cs.primary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('עדכון כמות:'),
                const SizedBox(height: kSpacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      icon: const Icon(Icons.remove),
                      onPressed: quantity > 0
                          ? () {
                              unawaited(HapticFeedback.selectionClick());
                              setDialogState(() => quantity--);
                            }
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge),
                      child: Text(
                        '$quantity',
                        style: TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: quantity <= item.minQuantity ? cs.error : cs.onSurface,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.add),
                      onPressed: quantity < 99
                          ? () {
                              unawaited(HapticFeedback.selectionClick());
                              setDialogState(() => quantity++);
                            }
                          : null,
                    ),
                  ],
                ),
                if (quantity <= item.minQuantity)
                  Padding(
                    padding: const EdgeInsets.only(top: kSpacingSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: cs.error, size: kIconSizeSmall),
                        const SizedBox(width: kSpacingTiny),
                        Text('מלאי נמוך (מינימום: ${item.minQuantity})', style: TextStyle(color: cs.error, fontSize: kFontSizeTiny)),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('ביטול'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (quantity != item.quantity) {
                    widget.onUpdateQuantity?.call(item, quantity);
                  }
                },
                child: const Text('שמור'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// מציג תפריט 3 נקודות עבור פריט
  void _showItemMenu(InventoryItem item) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // כותרת
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Text(
                  item.productName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: kFontSizeMedium, color: cs.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 1),
              // עריכה מלאה
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('עריכה מלאה'),
                subtitle: const Text('שם, קטגוריה, מיקום, מינימום'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editItem(item);
                },
              ),
              // מחיקה
              ListTile(
                leading: Icon(Icons.delete_outline, color: cs.error),
                title: Text('מחק פריט', style: TextStyle(color: cs.error)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDeleteItem(item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// בנייה של כרטיס מיקום אחסון עם סטטיסטיקה
  ///
  /// תכונות:
  /// - תצוגה: אמוג'י + שם + מספר פריטים
  /// - ניווט: onTap לשינוי selectedLocation
  /// - עריכה: long press למחיקה (רק custom locations)
  /// - אינדיקטור: low stock warning (⚠️ אם quantity ≤ 2)
  /// - Styling: כרטיס גבוה יותר כשנבחר (elevation + color)
  /// - Tooltip: "לחץ לעריכה, לחץ ארוכה למחיקה" (custom only)
  ///
  /// [key] - unique identifier של המיקום ("all", "refrigerator", וכו')
  /// [name] - שם המיקום ("הכל", "מקרר", וכו')
  /// [emoji] - אמוג'י של המיקום
  /// [count] - מספר הפריטים במיקום
  /// [customLocations] - רשימת מיקומים מותאמים (לעריכה)
  /// [isCustom] - האם זה custom location (default: false)
  /// Returns: Card widget עם כרטיס מיקום interactivo
  Widget _buildLocationCard({
    required String key,
    required String name,
    required String emoji,
    required int count,
    required List<CustomLocation> customLocations,
    bool isCustom = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = selectedLocation == key;
    final lowStockCount = widget.inventory.where((i) => i.location == key && i.isLowStock).length;

    final isEmpty = count == 0;

    final semanticLabel = isEmpty
        ? '$name - ריק'
        : '$name - $count פריטים${lowStockCount > 0 ? ', $lowStockCount במלאי נמוך' : ''}';

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      hint: isCustom ? 'לחץ לבחירה, לחיצה ארוכה למחיקה' : 'לחץ לבחירה',
      child: GestureDetector(
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          setState(() {
            selectedLocation = key;
            _lastCacheKey = ''; // נקה cache
          });
        },
        onLongPress: isCustom
            ? () {
                unawaited(HapticFeedback.mediumImpact());
                _deleteCustomLocation(key, name, emoji);
              }
            : null,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: isSelected ? kCardElevationHigh : kCardElevationLow,
          color: isSelected
              ? cs.primaryContainer
              : isEmpty
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                  : null,
          child: Padding(
            padding: const EdgeInsets.all(kSpacingXTiny),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // אמוג'י + כפתור עריכה
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      emoji,
                      style: TextStyle(
                        fontSize: kFontSizeLarge,
                        color: isEmpty ? cs.onSurfaceVariant : null,
                      ),
                    ),
                    // הצג כפתור עריכה רק כשנבחר
                    if (isCustom && isSelected)
                      GestureDetector(
                        onTap: () {
                          final loc = customLocations.firstWhere(
                            (l) => l.key == key,
                            orElse: () => CustomLocation(key: key, name: name, emoji: emoji),
                          );
                          _showEditLocationDialog(loc);
                        },
                        child: Icon(Icons.edit, size: 12, color: cs.onSurfaceVariant),
                      ),
                  ],
                ),
                // שם המיקום
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? cs.primary
                        : isEmpty
                            ? cs.onSurfaceVariant
                            : null,
                    fontSize: kFontSizeTiny, // 12
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                // מספר פריטים + אזהרה
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEmpty ? 'ריק' : '$count',
                      style: TextStyle(
                        fontSize: kFontSizeTiny, // 12
                        fontWeight: FontWeight.bold,
                        color: isEmpty ? cs.onSurfaceVariant.withValues(alpha: 0.6) : cs.primary,
                      ),
                    ),
                    if (lowStockCount > 0)
                      Icon(Icons.warning_amber_rounded, size: kIconSizeSmall, color: cs.error),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // יצירת עותק modifiable של הרשימה
    final customLocations = List<CustomLocation>.from(context.watch<LocationsProvider>().customLocations);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          /// 🔝 סרגל כלים קומפקטי
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingTiny),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // מיון
                Semantics(
                  label: 'מיון לפי $sortBy',
                  button: true,
                  child: IconButton(
                    icon: Icon(Icons.sort, color: cs.onSurfaceVariant),
                    tooltip: 'מיון',
                    onPressed: () => _showSortMenu(context),
                  ),
                ),
                // תצוגה
                Semantics(
                  label: gridMode ? 'עבור לתצוגת רשימה' : 'עבור לתצוגת רשת',
                  button: true,
                  child: IconButton(
                    icon: Icon(gridMode ? Icons.view_list : Icons.grid_view),
                    tooltip: gridMode ? 'רשימה' : 'רשת',
                    onPressed: () {
                      unawaited(HapticFeedback.selectionClick());
                      setState(() => gridMode = !gridMode);
                      _saveGridMode(gridMode);
                    },
                  ),
                ),
                // הוספת מיקום אחסון
                Semantics(
                  label: 'הוסף מיקום אחסון חדש',
                  button: true,
                  child: IconButton(
                    icon: Icon(Icons.create_new_folder_outlined, color: cs.primary),
                    tooltip: 'הוסף מיקום אחסון',
                    onPressed: _showAddLocationDialog,
                  ),
                ),
              ],
            ),
          ),

          /// תוכן מרכזי
          Expanded(
            child: Column(
              children: [
                /// 📦 רשימת מיקומים
                SizedBox(
                  height: gridMode ? (kChipHeight * 4) : (kChipHeight * 2.5),
                  child: gridMode
                    ? GridView.count(
                        crossAxisCount: 3,
                        childAspectRatio: 1.3,
                        mainAxisSpacing: kSpacingTiny,
                        crossAxisSpacing: kSpacingTiny,
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                        children: [
                      // כרטיס "הכל"
                      _buildLocationCard(
                        key: 'all',
                        name: 'הכל',
                        emoji: '🏪',
                        count: widget.inventory.length,
                        customLocations: customLocations,
                      ),

                      // מיקומי ברירת מחדל
                      ...StorageLocationsConfig.getAllLocationInfo().map((info) {
                        final count = widget.inventory.where((i) => i.location == info.id).length;
                        return _buildLocationCard(
                          key: info.id,
                          name: info.name,
                          emoji: info.emoji,
                          count: count,
                          customLocations: customLocations,
                        );
                      }),

                      // מיקומים מותאמים
                      ...customLocations.map((loc) {
                        final count = widget.inventory.where((i) => i.location == loc.key).length;
                        return _buildLocationCard(
                          key: loc.key,
                          name: loc.name,
                          emoji: loc.emoji,
                          count: count,
                          customLocations: customLocations,
                          isCustom: true,
                        );
                      }),
                        ],
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                        child: Row(
                          children: [
                            // כרטיס "הכל"
                            _buildLocationCard(
                              key: 'all',
                              name: 'הכל',
                              emoji: '🏪',
                              count: widget.inventory.length,
                              customLocations: customLocations,
                            ),

                            // מיקומי ברירת מחדל
                            ...StorageLocationsConfig.getAllLocationInfo().map((info) {
                              final count = widget.inventory.where((i) => i.location == info.id).length;
                              return _buildLocationCard(
                                key: info.id,
                                name: info.name,
                                emoji: info.emoji,
                                count: count,
                                customLocations: customLocations,
                              );
                            }),

                            // מיקומים מותאמים
                            ...customLocations.map((loc) {
                              final count = widget.inventory.where((i) => i.location == loc.key).length;
                              return _buildLocationCard(
                                key: loc.key,
                                name: loc.name,
                                emoji: loc.emoji,
                                count: count,
                                customLocations: customLocations,
                                isCustom: true,
                              );
                            }),
                          ],
                        ),
                      ),
                ),

                const SizedBox(height: kSpacingMedium),

                /// 📋 כותרת פריטים - עם רקע מרקר צהוב
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingTiny),
                  decoration: BoxDecoration(
                    color: kStickyYellow.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2, color: kStickyYellowDark, size: kIconSize),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        _getLocationTitle(customLocations),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kStickyYellowDark,
                          fontSize: kFontSizeBody,
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        '(${filteredInventory.length})',
                        style: TextStyle(color: kStickyYellowDark.withValues(alpha: 0.7), fontSize: kFontSizeTiny),
                      ),
                    ],
                  ),
                ),

                /// 📋 פריטים - רקע שקוף כדי לראות את קווי המחברת
                Expanded(
                  child: filteredInventory.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined,
                                size: kIconSizeXLarge,
                                color: cs.surfaceContainerHighest,
                              ),
                              const SizedBox(height: kSpacingMedium),
                              Text(
                                widget.searchQuery.isNotEmpty ? 'לא נמצאו פריטים' : 'אין פריטים במיקום זה',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          // padding למעלה כדי להתחיל מהשורה הבאה
                          padding: const EdgeInsets.only(top: kNotebookLineSpacing),
                          itemCount: filteredInventory.length,
                          itemBuilder: (_, index) {
                            final item = filteredInventory[index];
                            final itemSemanticLabel =
                                '${item.productName}, כמות: ${item.quantity} ${item.unit}'
                                '${item.isLowStock ? ', מלאי נמוך' : ''}'
                                '${item.isExpired ? ', פג תוקף' : item.isExpiringSoon ? ', קרוב לתפוגה' : ''}';
                            // כל פריט בגובה 48px = שורה אחת במחברת
                            return Semantics(
                              label: itemSemanticLabel,
                              button: widget.onUpdateQuantity != null,
                              hint: widget.onUpdateQuantity != null ? 'לחץ לעדכון כמות' : null,
                              child: GestureDetector(
                                onTap: widget.onUpdateQuantity != null
                                    ? () {
                                        unawaited(HapticFeedback.selectionClick());
                                        _showQuickQuantityDialog(item);
                                      }
                                    : null,
                                child: Container(
                                height: kNotebookLineSpacing,
                                padding: const EdgeInsets.only(
                                  left: kSpacingMedium,
                                  right: kSpacingMedium,
                                  bottom: kSpacingTiny, // רווח קטן מעל הקו
                                ),
                                child: Row(
                                  children: [
                                    // אמוג'י קטגוריה
                                    Text(
                                      _getProductEmoji(item.category),
                                      style: const TextStyle(fontSize: kFontSizeMedium),
                                    ),
                                    const SizedBox(width: kSpacingSmall),
                                    // אייקון מוצר קבוע (כוכב)
                                    if (item.isRecurring)
                                      const Padding(
                                        padding: EdgeInsets.only(left: kSpacingTiny),
                                        child: Text('⭐', style: TextStyle(fontSize: kFontSizeSmall)),
                                      ),
                                    // שם המוצר
                                    Expanded(
                                      child: Text(
                                        item.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: kFontSizeLarge, // גדול יותר - 20
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    // תאריך תפוגה (אם קיים)
                                    if (item.expiryDate != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: kSpacingSmall),
                                        child: _buildExpiryBadge(item, cs),
                                      ),
                                    // כפתור הוסף לרשימה (מלאי נמוך)
                                    if (item.isLowStock && widget.onAddToList != null)
                                      IconButton(
                                        icon: Icon(Icons.add_shopping_cart, color: cs.primary, size: kIconSize),
                                        tooltip: 'הוסף לרשימה',
                                        onPressed: () => widget.onAddToList!(item),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    // כמות - עיצוב משופר, גודל זהה לשם המוצר
                                    Container(
                                      margin: const EdgeInsets.only(left: kSpacingSmall), // רווח ימינה
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: kSpacingSmall,
                                        vertical: kSpacingXTiny,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.isLowStock
                                            ? cs.errorContainer.withValues(alpha: 0.3)
                                            : cs.primaryContainer.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${item.quantity}',
                                            style: TextStyle(
                                              color: item.isLowStock ? cs.error : cs.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: kFontSizeLarge, // כמו שם המוצר - 20
                                            ),
                                          ),
                                          const SizedBox(width: kSpacingXTiny),
                                          Text(
                                            item.unit,
                                            style: TextStyle(
                                              color: item.isLowStock ? cs.error : cs.onSurfaceVariant,
                                              fontSize: kFontSizeSmall, // קטן יותר - 12
                                            ),
                                          ),
                                          if (item.isLowStock) ...[
                                            const SizedBox(width: kSpacingTiny),
                                            Icon(Icons.warning, color: cs.error, size: kIconSize),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // כפתור תפריט
                                    IconButton(
                                      icon: const Icon(Icons.more_vert, size: kIconSize),
                                      onPressed: () => _showItemMenu(item),
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// בניית תג תאריך תפוגה עם צבע לפי קרבה (theme-aware)
  Widget _buildExpiryBadge(InventoryItem item, ColorScheme cs) {
    final isExpired = item.isExpired;
    final isExpiringSoon = item.isExpiringSoon;

    // ✅ קביעת צבע לפי מצב - theme-aware
    final Color bgColor;
    final Color textColor;
    final String icon;

    if (isExpired) {
      bgColor = StatusColors.getStatusContainer('error', context);
      textColor = StatusColors.getStatusColor('error', context);
      icon = '⚠️';
    } else if (isExpiringSoon) {
      bgColor = StatusColors.getStatusContainer('warning', context);
      textColor = StatusColors.getStatusColor('warning', context);
      icon = '⏰';
    } else {
      bgColor = StatusColors.getStatusContainer('success', context);
      textColor = StatusColors.getStatusColor('success', context);
      icon = '✓';
    }

    // פורמט תאריך קצר
    final dateStr = DateFormat('dd/MM').format(item.expiryDate!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingTiny, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Text(
            dateStr,
            style: TextStyle(
              color: textColor,
              fontSize: kFontSizeTiny,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// קבלת כותרת מיקום עבור כותרת הפריטים
  ///
  /// לוגיקה:
  /// - אם selectedLocation == "all" → "כל הפריטים"
  /// - אם selectedLocation במיקומי ברירת מחדל → שם מ-StorageLocationsConfig
  /// - אם selectedLocation במיקומים מותאמים → שם מ-customLocations
  /// - אחרת → selectedLocation כ-fallback
  ///
  /// [customLocations] - רשימת מיקומים מותאמים
  /// Returns: String כותרת בעברית
  String _getLocationTitle(List<CustomLocation> customLocations) {
    if (selectedLocation == 'all') return 'כל הפריטים';

    if (StorageLocationsConfig.isValidLocation(selectedLocation)) {
      return StorageLocationsConfig.getName(selectedLocation);
    }

    try {
      final custom = customLocations.firstWhere((loc) => loc.key == selectedLocation);
      return custom.name;
    } catch (e) {
      return selectedLocation;
    }
  }
}
