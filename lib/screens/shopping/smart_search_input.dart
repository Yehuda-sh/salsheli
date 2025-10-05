// 📄 File: lib/screens/shopping/smart_search_input.dart
// 
// 🎯 Purpose: שדה חיפוש חכם עם השלמה אוטומטית והצעות
//
// 📦 Dependencies:
// - None (standalone widget)
//
// 🎨 Features:
// - השלמה אוטומטית מהיסטוריית חיפושים
// - הצעות מוצרים פופולריים
// - ניווט במקלדת (חצים, Enter, Escape)
// - Clear button
// - Loading state
// - Empty state
//
// 💡 Usage:
// ```dart
// SmartSearchInput(
//   value: searchQuery,
//   onChange: (query) => setState(() => searchQuery = query),
//   onSearch: () => performSearch(),
//   searchHistory: pastSearches,
//   isLoading: isSearching,
// )
// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';

class SmartSearchInput extends StatefulWidget {
  final String value;
  final Function(String) onChange;
  final VoidCallback onSearch;
  final String placeholder;
  final List<Map<String, dynamic>> searchHistory;
  final bool isLoading;

  const SmartSearchInput({
    super.key,
    required this.value,
    required this.onChange,
    required this.onSearch,
    this.placeholder = "הקלידו שם מוצר לחיפוש...",
    this.searchHistory = const [],
    this.isLoading = false,
  });

  @override
  State<SmartSearchInput> createState() => _SmartSearchInputState();
}

class _SmartSearchInputState extends State<SmartSearchInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  bool isOpen = false;
  int selectedIndex = -1;
  List<Map<String, dynamic>> filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 SmartSearchInput.initState()');
    debugPrint('   📝 initial value: "${widget.value}"');
    
    _controller.text = widget.value;
    _controller.addListener(_filterSuggestions);

    // Keyboard listener
    _textFieldFocusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void didUpdateWidget(covariant SmartSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('🔄 SmartSearchInput.didUpdateWidget()');
    
    // עדכון חיצוני של value (כשהורה משנה אותו)
    if (widget.value != _controller.text) {
      debugPrint('   ✏️ עדכון value: "${widget.value}"');
      _controller.text = widget.value;
      _filterSuggestions();
    }
  }

  void _filterSuggestions() {
    final query = _controller.text.trim().toLowerCase();
    
    if (query.isEmpty) {
      debugPrint('🔍 SmartSearchInput._filterSuggestions: ריק - סוגר הצעות');
      setState(() {
        filteredSuggestions = [];
        isOpen = false;
        selectedIndex = -1;
      });
      return;
    }

    final historyMatches = widget.searchHistory
        .where(
          (item) =>
              (item["term"] ?? "").toString().toLowerCase().contains(query),
        )
        .map((item) => {...item, "type": "history"})
        .toList();

    final popularMatches = kPopularSearches
        .where((item) => item["name"]!.toString().toLowerCase().contains(query))
        .map((item) => {...item, "type": "popular"})
        .toList();

    debugPrint('🔍 SmartSearchInput._filterSuggestions()');
    debugPrint('   📝 query: "$query"');
    debugPrint('   🕒 history: ${historyMatches.length}');
    debugPrint('   ⭐ popular: ${popularMatches.length}');

    setState(() {
      filteredSuggestions = [...historyMatches, ...popularMatches];
      isOpen = filteredSuggestions.isNotEmpty;
      selectedIndex = -1;
    });
  }

  void _handleSuggestionClick(Map<String, dynamic> suggestion) {
    final term = suggestion["type"] == "history"
        ? suggestion["term"]
        : suggestion["name"];
    final safeTerm = (term ?? '').toString();
    
    debugPrint('✅ SmartSearchInput._handleSuggestionClick()');
    debugPrint('   📦 term: "$safeTerm"');
    debugPrint('   🏷️ type: ${suggestion["type"]}');
    
    _controller.text = safeTerm;
    widget.onChange(safeTerm);
    _closeSuggestions();
    widget.onSearch();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !isOpen || filteredSuggestions.isEmpty) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      debugPrint('⬇️ Arrow Down');
      setState(() {
        selectedIndex = (selectedIndex + 1) % filteredSuggestions.length;
      });
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      debugPrint('⬆️ Arrow Up');
      setState(() {
        selectedIndex =
            (selectedIndex - 1 + filteredSuggestions.length) %
            filteredSuggestions.length;
      });
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      debugPrint('↩️ Enter');
      if (selectedIndex >= 0) {
        _handleSuggestionClick(filteredSuggestions[selectedIndex]);
      } else {
        _closeSuggestions();
        widget.onSearch();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      debugPrint('🚫 Escape - סוגר הצעות');
      _closeSuggestions();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleQuickAdd(Map<String, dynamic> product) {
    final name = (product["name"] ?? '').toString();
    
    debugPrint('⚡ SmartSearchInput._handleQuickAdd()');
    debugPrint('   📦 product: "$name"');
    
    _controller.text = name;
    widget.onChange(name);
    _closeSuggestions();
    widget.onSearch();
  }

  void _clearSearch() {
    debugPrint('🗑️ SmartSearchInput._clearSearch()');
    
    _controller.clear();
    widget.onChange('');
    _closeSuggestions();
  }

  void _closeSuggestions() {
    debugPrint('❌ SmartSearchInput._closeSuggestions()');
    
    setState(() {
      isOpen = false;
      selectedIndex = -1;
    });
    _textFieldFocusNode.unfocus();
  }

  @override
  void dispose() {
    debugPrint('🧹 SmartSearchInput.dispose()');
    
    _controller.removeListener(_filterSuggestions);
    _controller.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _textFieldFocusNode,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: widget.placeholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  // Clear button
                  suffixIcon: _controller.text.isNotEmpty
                      ? SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            tooltip: 'נקה חיפוש',
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: _clearSearch,
                          ),
                        )
                      : null,
                ),
                onChanged: widget.onChange,
                onSubmitted: (_) {
                  _closeSuggestions();
                  widget.onSearch();
                },
                textInputAction: TextInputAction.search,
                enabled: !widget.isLoading,
              ),
            ),
            SizedBox(width: kSpacingSmall),
            SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                onPressed: widget.isLoading || _controller.text.trim().isEmpty
                    ? null
                    : () {
                        debugPrint('🔍 לחיצה על כפתור חיפוש');
                        _closeSuggestions();
                        widget.onSearch();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: EdgeInsets.zero,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search, size: 24),
              ),
            ),
          ],
        ),
        SizedBox(height: kSpacingSmall),

        // 🔥 פופולריים
        if (_controller.text.isEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "חיפושים פופולריים",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                SizedBox(height: kSpacingSmall),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final p in kPopularSearches)
                      OutlinedButton(
                        onPressed: () => _handleQuickAdd(p),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          minimumSize: const Size(48, 48),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(p["icon"]!.toString()),
                            const SizedBox(width: 4),
                            Text(
                              p["name"]!.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

        // 🧠 הצעות אוטומטיות
        if (isOpen && filteredSuggestions.isNotEmpty)
          Card(
            margin: EdgeInsets.only(top: kSpacingSmall),
            elevation: 2,
            child: Column(
              children: [
                for (final entry in filteredSuggestions.asMap().entries)
                  InkWell(
                    onTap: () => _handleSuggestionClick(entry.value),
                    child: Container(
                      padding: EdgeInsets.all(kSpacingSmall),
                      constraints: const BoxConstraints(minHeight: 48),
                      color: selectedIndex == entry.key
                          ? cs.primary.withValues(alpha: 0.06)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Icon(
                            entry.value["type"] == "history"
                                ? Icons.history
                                : Icons.trending_up,
                            size: 18,
                            color: Colors.grey,
                          ),
                          SizedBox(width: kSpacingSmall),
                          Expanded(
                            child: Text(
                              entry.value["type"] == "history"
                                  ? (entry.value["term"] ?? '').toString()
                                  : (entry.value["name"] ?? '').toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (entry.value["type"] == "history")
                            Text(
                              "${entry.value["resultsCount"] ?? 0} תוצאות",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            )
                          else
                            Text(
                              (entry.value["category"] ?? '').toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // ❌ אין תוצאות
        if (isOpen &&
            _controller.text.isNotEmpty &&
            filteredSuggestions.isEmpty)
          Card(
            margin: EdgeInsets.only(top: kSpacingSmall),
            child: Padding(
              padding: EdgeInsets.all(kSpacingMedium),
              child: Column(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  SizedBox(height: kSpacingSmall),
                  Text(
                    'אין הצעות עבור "${_controller.text}"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Text(
                    'לחצו על חיפוש לתוצאות מהאינטרנט',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
