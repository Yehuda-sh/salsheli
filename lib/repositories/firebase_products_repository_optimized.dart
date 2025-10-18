// 📄 File: lib/repositories/firebase_products_repository_optimized.dart
// 🎯 Purpose: Firebase Products Repository עם אופטימיזציות ביצועים
// ✨ Features: Pagination, Batch Loading, Caching, Lazy Loading

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'products_repository.dart';

class FirebaseProductsRepositoryOptimized implements ProductsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ⚡ קבועים לביצועים
  static const int _pageSize = 50; // טען 50 מוצרים בכל פעם
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  // 📦 Cache
  List<Map<String, dynamic>>? _cachedProducts;
  DateTime? _cacheTimestamp;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  
  // 🎯 בודק אם ה-cache עדיין תקף
  bool get _isCacheValid {
    if (_cachedProducts == null || _cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheExpiry;
  }
  
  @override
  Future<List<Map<String, dynamic>>> getAllProducts({
    int? limit,
    int? offset,
  }) async {
    debugPrint('📥 FirebaseProductsRepositoryOptimized.getAllProducts(limit: $limit, offset: $offset)');
    
    // 🚀 אם יש limit/offset - טען באופן ספציפי
    if (limit != null || offset != null) {
      return await _loadProductsWithPagination(limit: limit, offset: offset);
    }
    
    // ⚡ החזר מ-cache אם תקף
    if (_isCacheValid && _cachedProducts != null) {
      debugPrint('✅ מחזיר ${_cachedProducts!.length} מוצרים מ-cache');
      return _cachedProducts!;
    }
    
    // 🔄 טען מחדש
    return await _loadAllProductsPaginated();
  }
  
  /// 📄 טעינה עם pagination ספציפי
  Future<List<Map<String, dynamic>>> _loadProductsWithPagination({
    int? limit,
    int? offset,
  }) async {
    debugPrint('📄 טוען מוצרים עם pagination...');
    
    try {
      // 🚀 אם יש cache מלא ותקף, נשתמש בו
      if (_isCacheValid && _cachedProducts != null) {
        final start = offset ?? 0;
        final end = limit != null ? start + limit : _cachedProducts!.length;
        final result = _cachedProducts!.sublist(
          start.clamp(0, _cachedProducts!.length),
          end.clamp(0, _cachedProducts!.length),
        );
        debugPrint('✅ מחזיר ${result.length} מוצרים מ-cache (pagination)');
        return result;
      }
      
      // אין cache - טען מ-Firestore
      Query query = _firestore
          .collection('products')
          .orderBy('name');
      
      // אם יש offset, נטען את כל המוצרים עד offset+limit
      if (offset != null && offset > 0) {
        final totalToLoad = limit != null ? offset + limit : offset + 100;
        query = query.limit(totalToLoad);
        
        final snapshot = await query.get();
        final allDocs = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return <String, dynamic>{
            ...data,
            'id': doc.id,
          };
        }).toList();
        
        final result = allDocs.skip(offset).take(limit ?? allDocs.length).toList();
        debugPrint('✅ נטענו ${result.length} מוצרים (pagination)');
        return result;
      }
      
      // אין offset - פשוט limit
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      final products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return <String, dynamic>{
          ...data,
          'id': doc.id,
        };
      }).toList();
      
      debugPrint('✅ נטענו ${products.length} מוצרים');
      return products;
      
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת מוצרים עם pagination: $e');
      return [];
    }
  }
  
  /// ⚡ טעינה בעמודים - לא טוען הכל בבת אחת
  Future<List<Map<String, dynamic>>> _loadAllProductsPaginated() async {
    debugPrint('🔄 טוען מוצרים בעמודים...');
    
    final List<Map<String, dynamic>> allProducts = [];
    QuerySnapshot? snapshot;
    DocumentSnapshot? lastDoc;
    int pagesLoaded = 0;
    
    try {
      // טען עמוד אחר עמוד
      do {
        Query query = _firestore
            .collection('products')
            .orderBy('name')
            .limit(_pageSize);
        
        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }
        
        snapshot = await query.get();
        
        if (snapshot.docs.isNotEmpty) {
          final products = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
          
          allProducts.addAll(products);
          lastDoc = snapshot.docs.last;
          pagesLoaded++;
          
          debugPrint('📄 עמוד $pagesLoaded: נטענו ${products.length} מוצרים (סה"כ: ${allProducts.length})');
          
          // ⚡ תן ל-UI להתעדכן כל כמה עמודים
          if (pagesLoaded % 3 == 0) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
      } while (snapshot.docs.length == _pageSize);
      
      // 💾 שמור ב-cache
      _cachedProducts = allProducts;
      _cacheTimestamp = DateTime.now();
      
      debugPrint('✅ סיימנו לטעון ${allProducts.length} מוצרים ב-$pagesLoaded עמודים');
      return allProducts;
      
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת מוצרים: $e');
      // החזר cache ישן אם יש
      if (_cachedProducts != null) {
        debugPrint('⚠️ מחזיר cache ישן עם ${_cachedProducts!.length} מוצרים');
        return _cachedProducts!;
      }
      throw Exception('Failed to load products: $e');
    }
  }
  
  /// ⚡ טען רק את הדף הבא (לא הכל)
  Future<List<Map<String, dynamic>>> loadNextPage() async {
    if (!_hasMore) {
      debugPrint('📭 אין עוד מוצרים לטעון');
      return [];
    }
    
    debugPrint('📥 טוען עמוד נוסף של מוצרים...');
    
    try {
      Query query = _firestore
          .collection('products')
          .orderBy('name')
          .limit(_pageSize);
      
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        _hasMore = false;
        debugPrint('📭 הגענו לסוף הרשימה');
        return [];
      }
      
      final products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      
      _lastDocument = snapshot.docs.last;
      _hasMore = snapshot.docs.length == _pageSize;
      
      // הוסף ל-cache
      if (_cachedProducts != null) {
        _cachedProducts!.addAll(products);
      } else {
        _cachedProducts = products;
      }
      _cacheTimestamp = DateTime.now();
      
      debugPrint('✅ נטענו ${products.length} מוצרים נוספים');
      return products;
      
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת עמוד: $e');
      throw Exception('Failed to load page: $e');
    }
  }
  
  @override
  Future<List<String>> getCategories() async {
    debugPrint('📂 טוען קטגוריות...');
    
    try {
      // ⚡ שאילתה מאופטמזת - רק קטגוריות ייחודיות
      final snapshot = await _firestore
          .collection('products')
          .limit(500) // מספיק כדי לקבל את כל הקטגוריות
          .get();
      
      final Set<String> categories = {};
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['category'] != null) {
          categories.add(data['category'] as String);
        }
      }
      
      final categoriesList = categories.toList()..sort();
      debugPrint('📂 נמצאו ${categoriesList.length} קטגוריות');
      
      return categoriesList;
      
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת קטגוריות: $e');
      return [];
    }
  }
  
  @override
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    debugPrint('🔍 מחפש מוצר עם ברקוד: $barcode');
    
    try {
      // ⚡ חיפוש מהיר ב-cache תחילה
      if (_cachedProducts != null) {
        final cachedProduct = _cachedProducts!.firstWhere(
          (p) => p['barcode'] == barcode,
          orElse: () => {},
        );
        
        if (cachedProduct.isNotEmpty) {
          debugPrint('✅ נמצא ב-cache: ${cachedProduct['name']}');
          return cachedProduct;
        }
      }
      
      // חיפוש ב-Firestore
      final snapshot = await _firestore
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        
        debugPrint('✅ נמצא ב-Firestore: ${data['name']}');
        return data;
      }
      
      debugPrint('❌ מוצר לא נמצא');
      return null;
      
    } catch (e) {
      debugPrint('❌ שגיאה בחיפוש ברקוד: $e');
      return null;
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    
    debugPrint('🔍 מחפש מוצרים: "$query"');
    final lowerQuery = query.toLowerCase();
    
    try {
      // ⚡ חיפוש מהיר ב-cache
      if (_cachedProducts != null && _cachedProducts!.isNotEmpty) {
        final results = _cachedProducts!.where((p) {
          final name = (p['name'] as String).toLowerCase();
          final category = (p['category'] as String? ?? '').toLowerCase();
          final brand = (p['brand'] as String? ?? '').toLowerCase();
          
          return name.contains(lowerQuery) ||
                 category.contains(lowerQuery) ||
                 brand.contains(lowerQuery);
        }).toList();
        
        debugPrint('✅ נמצאו ${results.length} תוצאות ב-cache');
        return results;
      }
      
      // חיפוש ב-Firestore אם אין cache
      final snapshot = await _firestore
          .collection('products')
          .orderBy('name')
          .get();
      
      final results = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final name = (data['name'] as String).toLowerCase();
            final category = (data['category'] as String? ?? '').toLowerCase();
            final brand = (data['brand'] as String? ?? '').toLowerCase();
            
            return name.contains(lowerQuery) ||
                   category.contains(lowerQuery) ||
                   brand.contains(lowerQuery);
          })
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .toList();
      
      debugPrint('✅ נמצאו ${results.length} תוצאות');
      return results;
      
    } catch (e) {
      debugPrint('❌ שגיאה בחיפוש: $e');
      return [];
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    debugPrint('🏷️ טוען מוצרים מקטגוריה: $category');
    
    try {
      // ⚡ בדוק cache קודם
      if (_cachedProducts != null && _cachedProducts!.isNotEmpty) {
        final results = _cachedProducts!
            .where((p) => p['category'] == category)
            .toList();
        
        if (results.isNotEmpty) {
          debugPrint('✅ נמצאו ${results.length} מוצרים ב-cache');
          return results;
        }
      }
      
      // טען מ-Firestore
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .orderBy('name')
          .get();
      
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      debugPrint('✅ נטענו ${products.length} מוצרים');
      return products;
      
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת קטגוריה: $e');
      return [];
    }
  }
  
  @override
  Future<void> refreshProducts({bool force = false}) async {
    debugPrint('🔄 מרענן מוצרים (force: $force)');
    
    if (!force && _isCacheValid) {
      debugPrint('⏭️ Cache עדיין תקף, מדלג על רענון');
      return;
    }
    
    // נקה cache וטען מחדש
    _cachedProducts = null;
    _cacheTimestamp = null;
    _lastDocument = null;
    _hasMore = true;
    
    await getAllProducts();
    debugPrint('✅ רענון הושלם');
  }
  
  /// 🧹 נקה את ה-cache
  void clearCache() {
    debugPrint('🧹 מנקה cache');
    _cachedProducts = null;
    _cacheTimestamp = null;
    _lastDocument = null;
    _hasMore = true;
  }
  
  /// 📊 מידע על ה-cache
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCache': _cachedProducts != null,
      'productCount': _cachedProducts?.length ?? 0,
      'isValid': _isCacheValid,
      'timestamp': _cacheTimestamp?.toIso8601String(),
      'hasMore': _hasMore,
    };
  }
}
