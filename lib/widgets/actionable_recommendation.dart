// 📄 File: lib/widgets/actionable_recommendation.dart
// ignore_for_file: unnecessary_const

/// Widget for displaying a single recommendation with action buttons
/// 
/// Features:
/// - Add to shopping list with animation
/// - Remove recommendation
/// - Optional pantry button
/// - Animated entrance (slide + fade)
/// - Priority-based coloring
/// - Full accessibility support (semanticLabel)
/// 
/// Usage:
/// ```dart
/// ActionableRecommendation(
///   suggestion: mySuggestion,
///   onAddToList: () => addToList(mySuggestion),
///   onRemove: () => removeSuggestion(mySuggestion.id),
///   showPantryButton: true,
/// )
/// ```
/// 
/// Dependencies:
/// - Suggestion model
/// - Material 3 design
/// - ui_constants.dart
/// 
/// Version: 2.0 - Constants Integration (10/10/2025)

library;

import 'package:flutter/material.dart';
import '../models/suggestion.dart';
import '../core/ui_constants.dart';
import '../theme/app_theme.dart';

class ActionableRecommendation extends StatefulWidget {
  final Suggestion suggestion;
  final VoidCallback? onAddToList;
  final VoidCallback? onRemove;
  final bool showPantryButton;

  const ActionableRecommendation({
    super.key,
    required this.suggestion,
    this.onAddToList,
    this.onRemove,
    this.showPantryButton = false,
  });

  @override
  State<ActionableRecommendation> createState() =>
      _ActionableRecommendationState();
}

class _ActionableRecommendationState extends State<ActionableRecommendation>
    with SingleTickerProviderStateMixin {
  bool _isAdding = false;
  bool _isRemoved = false;

  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('🎨 ActionableRecommendation.initState: ${widget.suggestion.productName}');
    
    _controller = AnimationController(
      vsync: this,
      duration: kAnimationDurationMedium,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    debugPrint('🗑️ ActionableRecommendation.dispose: ${widget.suggestion.productName}');
    _controller.dispose();
    super.dispose();
  }

  String _getQuantityLabel() {
    final qty = widget.suggestion.suggestedQuantity;
    final unit = widget.suggestion.unit;
    return '$qty $unit';
  }

  Future<void> _handleAddToList() async {
    if (_isAdding || widget.onAddToList == null) return;

    setState(() => _isAdding = true);

    try {
      widget.onAddToList!();

      if (!mounted) return;
      
      final brand = Theme.of(context).extension<AppBrand>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.suggestion.productName} נוסף לרשימה ✅'),
          backgroundColor: brand?.success ?? Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: kSnackBarDuration,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('שגיאה בהוספה, נסה שוב'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: kSnackBarDuration,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _handleRemove() {
    setState(() => _isRemoved = true);
    widget.onRemove?.call();

    final brand = Theme.of(context).extension<AppBrand>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.suggestion.productName} הוסר מההמלצות'),
        backgroundColor: brand?.warning ?? Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        duration: kSnackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isRemoved) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final suggestion = widget.suggestion;

    // צבע לפי עדיפות
    final priorityColor = Color(suggestion.priorityColor);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          margin: const EdgeInsets.only(bottom: kSpacingSmallPlus),
          elevation: kCardElevation,
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // כותרת + סיבה
                Row(
                  children: [
                    // אייקון עדיפות
                    Container(
                      padding: const EdgeInsets.all(kSpacingSmall),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                      child: Icon(
                        _getPriorityIcon(suggestion.priority),
                        color: priorityColor,
                        size: kIconSizeMedium,
                        semanticLabel: 'עדיפות ${suggestion.priority}',
                      ),
                    ),
                    const SizedBox(width: kSpacingSmallPlus),

                    // שם המוצר
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.productName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: kSpacingTiny),
                          Text(
                            suggestion.reasonText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: kSpacingSmallPlus),

                // כמות + קטגוריה
                Wrap(
                  spacing: kSpacingSmall,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.shopping_bag, size: kIconSizeSmall),
                      label: Text(_getQuantityLabel()),
                      backgroundColor: cs.surfaceContainerHighest,
                      labelStyle: theme.textTheme.bodySmall,
                    ),
                    Chip(
                      avatar: const Icon(Icons.category, size: kIconSizeSmall),
                      label: Text(suggestion.category),
                      backgroundColor: cs.surfaceContainerHighest,
                      labelStyle: theme.textTheme.bodySmall,
                    ),
                  ],
                ),

                const SizedBox(height: kSpacingSmallPlus),

                // כפתורי פעולה
                Row(
                  children: [
                    // כפתור הוספה
                    if (widget.onAddToList != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isAdding ? null : _handleAddToList,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            minimumSize: const Size(0, kMinTouchTarget),
                          ),
                          icon: _isAdding
                              ? const SizedBox(
                                  width: kIconSizeSmall,
                                  height: kIconSizeSmall,
                                  child: CircularProgressIndicator(
                                    strokeWidth: kBorderWidthThick,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add, 
                                  size: 18.0, // Medium-small
                                  semanticLabel: 'הוסף', // ✅ accessibility
                                ),
                          label: Text(_isAdding ? 'מוסיף...' : 'הוסף לרשימה'),
                        ),
                      ),

                    if (widget.onAddToList != null && widget.showPantryButton)
                      const SizedBox(width: kSpacingSmall),

                    // כפתור מזווה (אופציונלי)
                    if (widget.showPantryButton)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/pantry');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: cs.primary.withValues(alpha: 0.4),
                            ),
                            minimumSize: const Size(0, kMinTouchTarget),
                            foregroundColor: cs.primary,
                          ),
                          icon: const Icon(Icons.kitchen, 
                            size: 18.0, // Medium-small
                            semanticLabel: 'מזווה', // ✅ accessibility
                          ),
                          label: const Text('למזווה'),
                        ),
                      ),

                    const SizedBox(width: kSpacingSmall),

                    // כפתור הסרה
                    IconButton(
                      tooltip: 'הסר המלצה',
                      onPressed: _handleRemove,
                      icon: Icon(Icons.close, 
                        color: Theme.of(context).colorScheme.error,
                        semanticLabel: 'הסר המלצה', // ✅ accessibility
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.arrow_upward;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.info_outline;
    }
  }
}
