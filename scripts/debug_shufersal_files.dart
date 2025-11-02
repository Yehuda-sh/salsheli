// scripts/debug_shufersal_files.dart
// בדיקת כל הקבצים הזמינים באתר שופרסל

import 'package:http/http.dart' as http;

const String _baseUrl = 'https://prices.shufersal.co.il/';

void main() async {
  print('🔍 בודק קבצים זמינים באתר שופרסל...\n');
  
  try {
    print('🌐 מתחבר ל-$_baseUrl');
    final response = await http.get(Uri.parse(_baseUrl))
        .timeout(const Duration(seconds: 30));
    
    if (response.statusCode != 200) {
      print('❌ שגיאה: ${response.statusCode}');
      return;
    }
    
    print('✓ קיבל תגובה (${response.body.length} תווים)\n');
    
    // חיפוש כל הקבצים
    final allUrls = <String>[];
    
    // 1. קבצי Price (מחירים)
    final priceRegex = RegExp(
      r'https://pricesprodpublic\.blob\.core\.windows\.net/price/Price[^\s"<>]+\.gz[^\s"<>]*',
      caseSensitive: false,
    );
    
    for (final match in priceRegex.allMatches(response.body)) {
      final url = match.group(0);
      if (url != null) {
        allUrls.add(url.replaceAll('&amp;', '&'));
      }
    }
    
    print('📂 נמצאו ${allUrls.length} קבצי Price\n');
    
    // ניתוח שמות קבצים
    print('📋 רשימת קבצים (10 ראשונים):');
    final fileNames = <String, int>{};
    
    for (var i = 0; i < allUrls.length && i < 10; i++) {
      final url = allUrls[i];
      final fileName = url.split('/').last.split('?').first;
      print('   ${i + 1}. $fileName');
      
      // ניתוח פורמט
      // Price7290027600007-001-202511021700.gz
      final parts = fileName.replaceAll('.gz', '').split('-');
      if (parts.length >= 3) {
        final chainCode = parts[0]; // Price7290027600007
        final storeCode = parts[1]; // 001
        final dateTime = parts[2]; // 202511021700
        
        // פירוק תאריך: YYYYMMDDHHMM
        if (dateTime.length >= 12) {
          final year = dateTime.substring(0, 4);
          final month = dateTime.substring(4, 6);
          final day = dateTime.substring(6, 8);
          final hour = dateTime.substring(8, 10);
          final minute = dateTime.substring(10, 12);
          
          final dateKey = '$year-$month-$day';
          fileNames[dateKey] = (fileNames[dateKey] ?? 0) + 1;
          
          if (i == 0) {
            print('      📅 תאריך: $year-$month-$day $hour:$minute');
            print('      🏪 סניף: $storeCode');
            print('      🏢 רשת: $chainCode');
          }
        }
      }
    }
    
    print('\n📊 סיכום תאריכים:');
    for (final entry in fileNames.entries) {
      print('   ${entry.key}: ${entry.value} קבצים');
    }
    
    // 2. חיפוש קבצי Stores (קטלוגים מלאים)
    print('\n🔍 מחפש קבצי Stores (קטלוגים מלאים)...');
    final storesRegex = RegExp(
      r'https://pricesprodpublic\.blob\.core\.windows\.net/stores/Stores[^\s"<>]+\.gz[^\s"<>]*',
      caseSensitive: false,
    );
    
    final storesUrls = <String>[];
    for (final match in storesRegex.allMatches(response.body)) {
      final url = match.group(0);
      if (url != null) {
        storesUrls.add(url.replaceAll('&amp;', '&'));
      }
    }
    
    if (storesUrls.isEmpty) {
      print('   ❌ לא נמצאו קבצי Stores');
    } else {
      print('   ✅ נמצאו ${storesUrls.length} קבצי Stores');
      print('\n📋 רשימת Stores (5 ראשונים):');
      for (var i = 0; i < storesUrls.length && i < 5; i++) {
        final fileName = storesUrls[i].split('/').last.split('?').first;
        print('      ${i + 1}. $fileName');
      }
    }
    
    // 3. חיפוש קבצי PromoFull (מבצעים)
    print('\n🔍 מחפש קבצי PromoFull (מבצעים)...');
    final promoRegex = RegExp(
      r'https://pricesprodpublic\.blob\.core\.windows\.net/promo/PromoFull[^\s"<>]+\.gz[^\s"<>]*',
      caseSensitive: false,
    );
    
    final promoUrls = <String>[];
    for (final match in promoRegex.allMatches(response.body)) {
      final url = match.group(0);
      if (url != null) {
        promoUrls.add(url.replaceAll('&amp;', '&'));
      }
    }
    
    if (promoUrls.isEmpty) {
      print('   ❌ לא נמצאו קבצי PromoFull');
    } else {
      print('   ✅ נמצאו ${promoUrls.length} קבצי PromoFull');
    }
    
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 סיכום סופי:');
    print('   Price (מחירים): ${allUrls.length} קבצים');
    print('   Stores (קטלוג): ${storesUrls.length} קבצים');
    print('   PromoFull (מבצעים): ${promoUrls.length} קבצים');
    print('━━━━━━━━━━━━━━━━━━━━━━━━');
    
    if (storesUrls.isNotEmpty) {
      print('\n💡 המלצה: קבצי Stores מכילים קטלוג מלא!');
      print('   לשימוש: שנה את fetch_shufersal_products.dart');
      print('   מ: /price/Price... → /stores/Stores...');
    }
    
  } catch (e, stack) {
    print('❌ שגיאה: $e');
    print('\nStack trace:\n$stack');
  }
}
