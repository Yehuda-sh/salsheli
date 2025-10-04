// 📄 File: lib/models/suggestion.dart
// תיאור: מודל להמלצות חכמות על מוצרים שכדאי להוסיף לרשימת הקניות

class Suggestion {
  final String id;
  final String productName;
  final String reason; // "running_low" | "frequently_bought" | "both"
  final String category;
  final int suggestedQuantity;
  final String unit;
  final String priority; // "high" | "medium" | "low"
  final String source; // "inventory" | "history" | "both"
  final DateTime createdAt;

  const Suggestion({
    required this.id,
    required this.productName,
    required this.reason,
    required this.category,
    required this.suggestedQuantity,
    required this.unit,
    required this.priority,
    required this.source,
    required this.createdAt,
  });

  // המרה מ-JSON
  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'] as String,
      productName: json['product_name'] as String,
      reason: json['reason'] as String? ?? 'frequently_bought',
      category: json['category'] as String? ?? 'כללי',
      suggestedQuantity: json['suggested_quantity'] as int? ?? 1,
      unit: json['unit'] as String? ?? 'יחידות',
      priority: json['priority'] as String? ?? 'medium',
      source: json['source'] as String? ?? 'inventory',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  // המרה ל-JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'reason': reason,
      'category': category,
      'suggested_quantity': suggestedQuantity,
      'unit': unit,
      'priority': priority,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // העתקה עם שינויים
  Suggestion copyWith({
    String? id,
    String? productName,
    String? reason,
    String? category,
    int? suggestedQuantity,
    String? unit,
    String? priority,
    String? source,
    DateTime? createdAt,
  }) {
    return Suggestion(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      reason: reason ?? this.reason,
      category: category ?? this.category,
      suggestedQuantity: suggestedQuantity ?? this.suggestedQuantity,
      unit: unit ?? this.unit,
      priority: priority ?? this.priority,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // טקסט תיאור הסיבה
  String get reasonText {
    switch (reason) {
      case 'running_low':
        return 'נגמר במזווה';
      case 'frequently_bought':
        return 'נקנה לעיתים קרובות';
      case 'both':
        return 'נגמר במזווה ונקנה לעיתים קרובות';
      default:
        return 'מומלץ';
    }
  }

  // צבע לפי עדיפות
  int get priorityColor {
    switch (priority) {
      case 'high':
        return 0xFFEF5350; // אדום
      case 'medium':
        return 0xFFFF9800; // כתום
      case 'low':
        return 0xFF66BB6A; // ירוק
      default:
        return 0xFF9E9E9E; // אפור
    }
  }

  @override
  String toString() {
    return 'Suggestion(id: $id, productName: $productName, reason: $reason, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Suggestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
