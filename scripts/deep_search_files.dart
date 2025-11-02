// scripts/deep_search_files.dart
// חיפוש מעמיק של כל הקבצים באתר

import 'package:http/http.dart' as http;

const String _baseUrl = 'https://prices.shufersal.co.il/';

void main() async {
  print('🔎 חיפוש מעמיק של כל הקבצים...\n');
  
  try {
    print('🌐 מתחבר לאתר...');
    final response = await http.get(Uri.parse(_baseUrl))
        .timeout(const Duration(seconds: 30));
    
    if (response.statusCode != 200) {
      print('❌ שגיאה: ${response.statusCode}');
      return;
    }
    
    print('✓ קיבל תגובה (${response.body.length} תווים)\n');
    
    // 1. חיפוש כל הקישורים לקבצים
    print('🔍 מחפש כל הקישורים...\n');
    
    // Regex מורחב - כל קישור ל-.gz
    final allGzRegex = RegExp(
      r'https://[^\s"<>]+\.gz[^\s"<>]*',
      caseSensitive: false,
    );
    
    final allUrls = <String>{};
    for (final match in allGzRegex.allMatches(response.body)) {
      final url = match.group(0);
      if (url != null) {
        allUrls.add(url.replaceAll('&amp;', '&'));
      }
    }
    
    print('📦 נמצאו ${allUrls.length} קבצי GZ סה"כ\n');
    
    // 2. ניתוח לפי סוג
    final byType = <String, List<String>>{};
    final byDate = <String, Set<String>>{};
    
    for (final url in allUrls) {
      final parts = url.split('/');
      if (parts.length < 2) continue;
      
      final folder = parts[parts.length - 2]; // price, stores, promo, etc.
      final fileName = parts.last.split('?').first;
      
      byType.putIfAbsent(folder, () => []);
      byType[folder]!.add(fileName);
      
      // נסה לחלץ תאריך
      final dateMatch = RegExp(r'(\d{8})').firstMatch(fileName);
      if (dateMatch != null) {
        final dateStr = dateMatch.group(1)!;
        // YYYYMMDD
        final formatted = '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}';
        
        byDate.putIfAbsent(formatted, () => {});
        byDate[formatted]!.add(folder);
      }
    }
    
    // 3. הצגת תוצאות לפי סוג
    print('━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 קבצים לפי סוג:\n');
    
    for (final entry in byType.entries) {
      final folder = entry.key;
      final files = entry.value;
      
      print('📁 $folder/:');
      print('   סה"כ: ${files.length} קבצים');
      
      // הצג 3 דוגמאות
      print('   דוגמאות:');
      for (var i = 0; i < files.length && i < 3; i++) {
        print('      - ${files[i]}');
      }
      print('');
    }
    
    // 4. הצגת תאריכים
    print('━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📅 תאריכים שנמצאו:\n');
    
    if (byDate.isEmpty) {
      print('   ❌ לא נמצאו תאריכים');
    } else {
      final sortedDates = byDate.keys.toList()..sort();
      
      for (final date in sortedDates) {
        final folders = byDate[date]!.toList()..sort();
        print('   📅 $date:');
        print('      תיקיות: ${folders.join(", ")}');
      }
      
      print('\n   תאריך ראשון: ${sortedDates.first}');
      print('   תאריך אחרון: ${sortedDates.last}');
      print('   סה"כ תאריכים: ${sortedDates.length}');
    }
    
    // 5. חיפוש דפים נוספים - פשוט יותר
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 מחפש קישורים לדפים נוספים...\n');
    
    // חיפוש פשוט - כל href
    final simpleHrefRegex = RegExp(r'href="([^"]+)"', caseSensitive: false);
    
    final pageLinks = <String>{};
    for (final match in simpleHrefRegex.allMatches(response.body)) {
      final link = match.group(1);
      if (link != null && 
          (link.contains('page') || 
           link.contains('archive') || 
           link.contains('history') ||
           link.contains('date'))) {
        pageLinks.add(link);
      }
    }
    
    if (pageLinks.isEmpty) {
      print('   ❌ לא נמצאו קישורים לארכיון או דפדוף');
    } else {
      print('   ✅ נמצאו ${pageLinks.length} קישורים:');
      for (final link in pageLinks.take(5)) {
        print('      - $link');
      }
    }
    
    // 6. בדיקת metadata בתוך ה-HTML
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 מידע נוסף מה-HTML:\n');
    
    // חפש כותרות
    final titleRegex = RegExp(r'<title>([^<]+)</title>', caseSensitive: false);
    final titleMatch = titleRegex.firstMatch(response.body);
    if (titleMatch != null) {
      print('   📌 כותרת: ${titleMatch.group(1)}');
    }
    
    // חפש description - פשוט יותר
    final descRegex = RegExp(
      r'name="description"[^>]+content="([^"]+)"',
      caseSensitive: false,
    );
    final descMatch = descRegex.firstMatch(response.body);
    if (descMatch != null) {
      print('   📝 תיאור: ${descMatch.group(1)}');
    }
    
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ חיפוש הסתיים');
    
    // המלצות
    if (byType.length == 1 && byDate.length == 1) {
      print('\n💡 מסקנה:');
      print('   האתר מציג רק קבצים מהיום');
      print('   אין ארכיון או דפדוף');
      print('   המלצה: הרץ את הסקריפט מדי יום לצבירה');
    } else if (byDate.length > 1) {
      print('\n🎉 מצוין! נמצאו ${byDate.length} תאריכים שונים!');
      print('   אפשר להוריד מכולם');
    }
    
  } catch (e, stack) {
    print('❌ שגיאה: $e');
    print('\nStack trace:\n$stack');
  }
}
