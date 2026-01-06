// 📄 File: lib/widgets/inventory/pantry_product_selection_sheet.dart
//
// 🎯 מטרה: Bottom sheet לבחירת מוצרים להוספה למזווה
//
// 📋 כולל:
// - טעינת מוצרים מכל סוגי הרשימות (סופרמרקט, בית מרקחת, ירקן וכו')
// - חיפוש וסינון לפי קטגוריה
// - בחירת מיקום אחסון וכמות
// - הוספה ישירה למזווה
//
// 🔗 Dependencies:
// - LocalProductsRepository: טעינת מוצרים מ-assets
// - InventoryProvider: הוספה למזווה
// - StorageLocationsConfig: מיקומי אחסון
//
// Version: 1.0
// Last Updated: 30/11/2025

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/storage_locations_config.dart';
import '../../core/status_colors.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/custom_location.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/locations_provider.dart';
import '../../repositories/local_products_repository.dart';
import '../common/notebook_background.dart';

class PantryProductSelectionSheet extends StatefulWidget {
  const PantryProductSelectionSheet({super.key});

  /// מציג את ה-bottom sheet לבחירת מוצרים
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PantryProductSelectionSheet(),
    );
  }

  @override
  State<PantryProductSelectionSheet> createState() =>
      _PantryProductSelectionSheetState();
}

class _PantryProductSelectionSheetState
    extends State<PantryProductSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  final LocalProductsRepository _repository = LocalProductsRepository();

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  Set<String> _categories = {};
  String? _selectedCategory;
  String _searchQuery = '';

  /// 🆕 שמות מוצרים שכבר קיימים במזווה (לתצוגת "במזווה")
  Set<String> _existingProductNames = {};

  bool _isLoading = true;
  String? _errorMessage;
  String? _lastAddedProduct;
  String? _addingProductId;

  /// 🆕 מזהה מוצר שזה עתה נוסף (לאפקט הדגשה)
  String? _justAddedProductId;

  // ✅ Timers - ניתנים לביטול ב-dispose
  Timer? _debounceTimer;
  Timer? _feedbackTimer;
  Timer? _pulseTimer;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _feedbackTimer?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }

  /// ✅ Debounced search - מונע קריאות מיותרות בזמן הקלדה
  void _onSearchChangedDebounced(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = value;
        });
        _filterProducts();
      }
    });
  }

  /// 🆕 הוספת מוצר מותאם אישית (כשלא נמצא בקטלוג)
  Future<void> _addCustomProduct(String productName) async {
    // יצירת מוצר זמני עם השם שהמשתמש חיפש
    final customProduct = {
      'name': productName,
      'category': 'אחר',
      'icon': '📦',
      'source': 'custom',
      'barcode': 'custom_${productName.hashCode}',
    };
    await _addProductToPantry(customProduct);
  }

  /// ✅ הצגת פידבק עם Timer מבוטל
  void _showFeedback(String productName) {
    _feedbackTimer?.cancel();
    setState(() => _lastAddedProduct = productName);
    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _lastAddedProduct = null);
      }
    });
  }

  Future<void> _loadProducts() async {
    // 🆕 שמור הפניה ל-provider לפני async gap
    final inventoryProvider = context.read<InventoryProvider>();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _repository.getAllListTypesProducts();

      // חלץ קטגוריות ייחודיות
      final categories = <String>{};
      for (final product in products) {
        final category = product['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      // 🆕 קבל שמות מוצרים שכבר במזווה
      final existingNames = inventoryProvider.items
          .map((item) => item.productName.toLowerCase())
          .toSet();

      if (!mounted) return;

      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _categories = categories;
        _existingProductNames = existingNames;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'שגיאה בטעינת מוצרים: $e';
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        // סינון לפי קטגוריה
        if (_selectedCategory != null) {
          if (product['category'] != _selectedCategory) {
            return false;
          }
        }

        // סינון לפי חיפוש
        if (_searchQuery.isNotEmpty) {
          final name = (product['name'] as String?)?.toLowerCase() ?? '';
          final brand = (product['brand'] as String?)?.toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          if (!name.contains(query) && !brand.contains(query)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  Future<void> _addProductToPantry(Map<String, dynamic> product) async {
    final productId = product['barcode'] as String? ?? product['name'] as String;

    unawaited(HapticFeedback.lightImpact()); // ✅ Haptic feedback
    setState(() {
      _addingProductId = productId;
    });

    // הצג דיאלוג לבחירת כמות ומיקום
    final result = await _showAddDetailsDialog(product);

    if (result == null) {
      if (mounted) {
        setState(() {
          _addingProductId = null;
        });
      }
      return;
    }

    if (!mounted) return;

    final provider = context.read<InventoryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final name = product['name'] as String? ?? 'מוצר';
    final category = product['category'] as String? ?? 'אחר';
    try {
      // במזווה אנחנו סופרים יחידות של מוצרים (ברירת מחדל: יח')
      await provider.createItem(
        productName: name,
        category: category,
        location: result['location'] as String,
        quantity: result['quantity'] as int,
      );

      if (!mounted) return;

      setState(() {
        _addingProductId = null;
        // 🆕 עדכן את רשימת המוצרים הקיימים כדי שהתג יופיע מיד
        _existingProductNames.add(name.toLowerCase());
        // 🆕 אפקט הדגשה (pulse)
        _justAddedProductId = productId;
      });
      _showFeedback(name); // ✅ Timer מבוטל במקום Future.delayed

      // 🆕 הסר את אפקט ההדגשה אחרי חצי שנייה
      _pulseTimer?.cancel();
      _pulseTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _justAddedProductId = null);
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _addingProductId = null;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.inventory.addError),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _showAddDetailsDialog(
    Map<String, dynamic> product,
  ) async {
    final cs = Theme.of(context).colorScheme;
    final name = product['name'] as String? ?? 'מוצר';
    final locationsProvider = context.read<LocationsProvider>();

    int quantity = 1;
    String location = StorageLocationsConfig.mainPantry;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // איסוף כל המיקומים (ברירת מחדל + מותאמים)
            final customLocations = locationsProvider.customLocations;
            final allLocations = [
              ...StorageLocationsConfig.allLocations,
              ...customLocations.map((c) => c.key),
            ];

            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(
                  name,
                  style: TextStyle(fontSize: kFontSizeMedium, color: cs.primary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // כמות
                    Row(
                      children: [
                        Text(
                          AppStrings.inventory.quantityLabel,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: cs.error),
                          onPressed: quantity > 1
                              ? () {
                                  unawaited(HapticFeedback.selectionClick());
                                  setDialogState(() => quantity--);
                                }
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSpacingMedium,
                            vertical: kSpacingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                          child: Text(
                            '$quantity',
                            style: TextStyle(
                              fontSize: kFontSizeMedium,
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: cs.primary),
                          onPressed: quantity < 99
                              ? () {
                                  unawaited(HapticFeedback.selectionClick());
                                  setDialogState(() => quantity++);
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // מיקום עם כפתור הוספה
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: location,
                            dropdownColor: cs.surface,
                            style: TextStyle(color: cs.onSurface),
                            decoration: InputDecoration(
                              labelText: AppStrings.inventory.locationLabel,
                              labelStyle: TextStyle(color: cs.onSurfaceVariant),
                              border: const OutlineInputBorder(),
                            ),
                            items: allLocations.map((locId) {
                              // בדוק אם זה מיקום מותאם
                              final customLoc = customLocations.cast<CustomLocation?>().firstWhere(
                                (c) => c?.key == locId,
                                orElse: () => null,
                              );
                              if (customLoc != null) {
                                return DropdownMenuItem(
                                  value: locId,
                                  child: Row(
                                    children: [
                                      Text(customLoc.emoji),
                                      const SizedBox(width: kSpacingSmall),
                                      Text(customLoc.name),
                                    ],
                                  ),
                                );
                              }
                              // מיקום ברירת מחדל
                              final info = StorageLocationsConfig.getLocationInfo(locId);
                              return DropdownMenuItem(
                                value: locId,
                                child: Row(
                                  children: [
                                    Text(info.emoji),
                                    const SizedBox(width: kSpacingSmall),
                                    Text(info.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => location = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: kSpacingSmall),
                        // כפתור הוספת מיקום חדש
                        IconButton(
                          icon: Icon(Icons.add_location_alt, color: cs.primary),
                          tooltip: 'הוסף מיקום חדש',
                          onPressed: () async {
                            final newLocation = await _showAddLocationDialog(dialogContext);
                            if (newLocation != null) {
                              setDialogState(() {
                                location = newLocation;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(AppStrings.common.cancel),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: kIconSizeSmall),
                    label: Text(AppStrings.inventory.addButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext, {
                        'quantity': quantity,
                        'location': location,
                      });
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// רשימת אמוג'י לבחירה במיקום חדש
  static const List<String> _availableEmojis = [
    '📍', '🏠', '❄️', '🧊', '📦', '🛁', '🧺', '🚗', '🧼', '🧂',
    '🍹', '🍕', '🎁', '🎒', '🧰', '🎨', '📚', '🔧', '🏺', '🗄️',
  ];

  /// מציג דיאלוג להוספת מיקום חדש
  Future<String?> _showAddLocationDialog(BuildContext parentContext) async {
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController();
    String selectedEmoji = '📍';

    return showDialog<String>(
      context: parentContext,
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
                      controller: controller,
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
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('ביטול'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;

                      final provider = this.context.read<LocationsProvider>();
                      final navigator = Navigator.of(dialogContext);
                      final messenger = ScaffoldMessenger.of(this.context);

                      final success = await provider.addLocation(name, emoji: selectedEmoji);

                      if (success) {
                        // החזר את ה-key של המיקום החדש
                        final newLoc = provider.customLocations.lastOrNull;
                        navigator.pop(newLoc?.key);
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('מיקום זה כבר קיים')),
                        );
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(kBorderRadiusLarge),
        ),
      ),
      child: Stack(
        children: [
          // 🎨 רקע מחברת לעיצוב אחיד עם שאר האפליקציה
          const Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
              child: NotebookBackground(),
            ),
          ),

          // 📝 תוכן
          Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: kSpacingSmall),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
            ),

            // כותרת
            Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.inventory.addFromCatalogTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Semantics(
                    label: 'סגור',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'סגור',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // חיפוש
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.inventory.searchProductsHint,
                  prefixIcon: Icon(Icons.search, color: cs.primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            unawaited(HapticFeedback.lightImpact());
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _filterProducts();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                onChanged: _onSearchChangedDebounced, // ✅ Debounce
              ),
            ),
            const SizedBox(height: kSpacingSmall),

            // סינון קטגוריות
            SizedBox(
              height: kChipHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                children: [
                  // כל הקטגוריות
                  Padding(
                    padding: const EdgeInsets.only(left: kSpacingSmall),
                    child: FilterChip(
                      label: const Text('הכל'),
                      selected: _selectedCategory == null,
                      onSelected: (_) {
                        unawaited(HapticFeedback.selectionClick());
                        setState(() {
                          _selectedCategory = null;
                        });
                        _filterProducts();
                      },
                    ),
                  ),
                  // קטגוריות
                  ..._categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(left: kSpacingSmall),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (_) {
                          unawaited(HapticFeedback.selectionClick());
                          setState(() {
                            _selectedCategory =
                                _selectedCategory == category ? null : category;
                          });
                          _filterProducts();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: kSpacingSmall),

            // הודעת הצלחה
            if (_lastAddedProduct != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  color: StatusColors.getStatusColor('success', context),
                  borderRadius: BorderRadius.circular(kBorderRadius),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: cs.onPrimary),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        AppStrings.inventory.productAddedSuccess(_lastAddedProduct!),
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

                // רשימת מוצרים
                Expanded(
                  child: _buildProductsList(cs),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ColorScheme cs) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: kSpacingMedium),
            Text(AppStrings.inventory.loadingProducts),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            const SizedBox(height: kSpacingMedium),
            Text(_errorMessage!, style: TextStyle(color: cs.error)),
            const SizedBox(height: kSpacingMedium),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(AppStrings.common.retry),
              onPressed: _loadProducts,
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              _searchQuery.isNotEmpty
                  ? AppStrings.inventory.noProductsFound
                  : AppStrings.inventory.noProductsAvailable,
              style: const TextStyle(
                fontSize: kFontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            // 🆕 הוספת מוצר מותאם אישית
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: kSpacingSmall),
              Text(
                'לא מצאת? הוסף מוצר חדש',
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: kSpacingMedium),
              FilledButton.tonalIcon(
                onPressed: () => _addCustomProduct(_searchQuery),
                icon: const Icon(Icons.add_circle_outline),
                label: Text('הוסף "$_searchQuery"'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(kSpacingSmall),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product, cs);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ColorScheme cs) {
    final name = product['name'] as String? ?? 'מוצר';
    final category = product['category'] as String? ?? 'אחר';
    final brand = product['brand'] as String?;
    final icon = product['icon'] as String? ?? '📦';
    final source = product['source'] as String? ?? 'supermarket';
    final productId = product['barcode'] as String? ?? name;
    final isAdding = _addingProductId == productId;

    // 🆕 בדוק אם המוצר כבר במזווה
    final isInPantry = _existingProductNames.contains(name.toLowerCase());

    // 🆕 בדוק אם המוצר זה עתה נוסף (לאפקט pulse)
    final justAdded = _justAddedProductId == productId;

    // צבע לפי מקור
    final sourceColor = _getSourceColor(source, cs);

    return Semantics(
      label: '$name, $category. לחץ להוספה למזווה',
      button: true,
      enabled: !isAdding,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: kSpacingSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          // 🆕 אפקט הדגשה כשזה עתה נוסף
          boxShadow: justAdded
              ? [
                  BoxShadow(
                    color: StatusColors.getStatusColor('success', context)
                        .withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Card(
          margin: EdgeInsets.zero,
          color: justAdded
              ? StatusColors.getStatusColor('success', context)
                  .withValues(alpha: 0.1)
              : null,
          child: InkWell(
            onTap: isAdding ? null : () => _addProductToPantry(product),
            borderRadius: BorderRadius.circular(kBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(kSpacingSmall),
              child: Row(
                children: [
                  // אייקון
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: sourceColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),

                  // פרטים
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🆕 שם + תג "במזווה" אם קיים
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: kFontSizeBody,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isInPantry) ...[
                              const SizedBox(width: kSpacingSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: StatusColors.getStatusColor(
                                      'success', context),
                                  borderRadius:
                                      BorderRadius.circular(kBorderRadiusSmall),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      size: 12,
                                      color: cs.onPrimary,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'במזווה',
                                      style: TextStyle(
                                        fontSize: kFontSizeTiny,
                                        color: cs.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: kSpacingSmall,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: sourceColor.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(kBorderRadiusSmall),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: kFontSizeTiny,
                                  color: sourceColor,
                                ),
                              ),
                            ),
                            if (brand != null && brand != '---') ...[
                              const SizedBox(width: kSpacingSmall),
                              Text(
                                brand,
                                style: TextStyle(
                                  fontSize: kFontSizeTiny,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // כפתור הוספה - גדול יותר עם אזור לחיצה נוח
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isInPantry
                          ? StatusColors.getStatusColor('success', context)
                              .withValues(alpha: 0.1)
                          : cs.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: isAdding
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Icon(
                            isInPantry
                                ? Icons.add_circle_outline
                                : Icons.add_circle,
                            color: isInPantry
                                ? StatusColors.getStatusColor(
                                    'success', context)
                                : cs.primary,
                            size: 32,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// צבע לפי מקור - משתמש בצבעי sticky notes מהtheme
  Color _getSourceColor(String source, ColorScheme cs) {
    switch (source) {
      case 'pharmacy':
        return kStickyPink;
      case 'greengrocer':
        return kStickyGreen;
      case 'butcher':
        return kStickyYellow;
      case 'bakery':
        return kStickyYellow;
      case 'market':
        return kStickyCyan;
      case 'supermarket':
      default:
        return cs.primary;
    }
  }
}
