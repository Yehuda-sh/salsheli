// lib/components/shopping/smart_search_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final FocusNode _keyboardFocusNode = FocusNode(); // ✅ מאזין קבוע למקלדת

  bool isOpen = false;
  int selectedIndex = -1;
  List<Map<String, dynamic>> filteredSuggestions = [];

  final List<Map<String, dynamic>> popularProducts = const [
    {"name": "חלב", "icon": "🥛", "category": "מוצרי חלב"},
    {"name": "לחם", "icon": "🍞", "category": "מאפים"},
    {"name": "ביצים", "icon": "🥚", "category": "מזווה"},
    {"name": "עגבניות", "icon": "🍅", "category": "ירקות"},
    {"name": "מלפפונים", "icon": "🥒", "category": "ירקות"},
    {"name": "אורז", "icon": "🍚", "category": "מזווה"},
    {"name": "שמן זית", "icon": "🫒", "category": "מזווה"},
    {"name": "פסטה", "icon": "🍝", "category": "מזווה"},
  ];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value;
    _controller.addListener(_filterSuggestions);

    // כששדה החיפוש נכנס לפוקוס – נאזין גם למקלדת
    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant SmartSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // עדכון חיצוני של value (כשהורה משנה אותו)
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _filterSuggestions();
    }
  }

  void _filterSuggestions() {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) {
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

    final popularMatches = popularProducts
        .where((item) => item["name"]!.toString().toLowerCase().contains(query))
        .map((item) => {...item, "type": "popular"})
        .toList();

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
    _controller.text = safeTerm;
    widget.onChange(safeTerm);
    _closeSuggestions();
    widget.onSearch();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent || !isOpen || filteredSuggestions.isEmpty) {
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        selectedIndex = (selectedIndex + 1) % filteredSuggestions.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        selectedIndex =
            (selectedIndex - 1 + filteredSuggestions.length) %
            filteredSuggestions.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (selectedIndex >= 0) {
        _handleSuggestionClick(filteredSuggestions[selectedIndex]);
      } else {
        _closeSuggestions();
        widget.onSearch();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeSuggestions();
    }
  }

  void _handleQuickAdd(Map<String, dynamic> product) {
    final name = (product["name"] ?? '').toString();
    _controller.text = name;
    widget.onChange(name);
    _closeSuggestions();
    widget.onSearch();
  }

  void _closeSuggestions() {
    setState(() {
      isOpen = false;
      selectedIndex = -1;
    });
    _textFieldFocusNode.unfocus();
  }

  @override
  void dispose() {
    _controller.removeListener(_filterSuggestions);
    _controller.dispose();
    _textFieldFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return RawKeyboardListener(
      focusNode: _keyboardFocusNode, // ✅ קבוע, לא בכל build
      onKey: _handleKey,
      child: Column(
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
                      borderRadius: BorderRadius.circular(8),
                    ),
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
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: widget.isLoading || _controller.text.trim().isEmpty
                    ? null
                    : () {
                        _closeSuggestions();
                        widget.onSearch();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
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
                    : const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 12),

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
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final p in popularProducts)
                        OutlinedButton(
                          onPressed: () => _handleQuickAdd(p),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
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
              margin: const EdgeInsets.only(top: 8),
              elevation: 2,
              child: Column(
                children: [
                  for (final entry in filteredSuggestions.asMap().entries)
                    InkWell(
                      onTap: () => _handleSuggestionClick(entry.value),
                      child: Container(
                        padding: const EdgeInsets.all(12),
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
                            const SizedBox(width: 8),
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
              margin: const EdgeInsets.only(top: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(height: 8),
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
      ),
    );
  }
}
