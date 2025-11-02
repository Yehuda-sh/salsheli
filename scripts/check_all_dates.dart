// scripts/check_all_dates.dart
// בדיקת כל התאריכים הזמינים באתר

import 'package:http/http.dart' as http;

const String _baseUrl = 'https://prices.shufersal.co.il/';

void main() async {
  print('📅 בודק כל התאריכים הזמינים...\n');
  
  try {
    print('🌐 מתחבר לאתר...');
    final response = await http.get(Uri.parse(_baseUrl))
        .timeout(const Duration(seconds: 30));
    
    if (response.statusCode != 200) {
      print('❌ שגיאה: ${response.statusCode}');
      return;
    }
    
    print('✓ קיבל תגובה (${response.body.length} תווים)\n');
    
    // חיפוש כל הקבצים
    final priceRegex = RegExp(
      r'Price7290027600007-\d+-(\d{12})\.gz',
      caseSensitive: false,
    );
    
    final dates = <String>{};
    final filesByDate = <String, List<String>>{};
    
    for (final match in priceRegex.allMatches(response.body)) {
      final dateTime = match.group(1);
      if (dateTime != null && dateTime.length == 12) {
        // YYYYMMDDHHMM
        final year = dateTime.substring(0, 4);
        final month = dateTime.substring(4, 6);
        final day = dateTime.substring(6, 8);
        final hour = dateTime.substring(8, 10);
        final minute = dateTime.substring(10, 12);
        
        final dateKey = '$year-$month-$day';
        final timeKey = '$hour:$minute';
        
        dates.add(dateKey);
        
        filesByDate.putIfAbsent(dateKey, () => []);
        filesByDate[dateKey]!.add(timeKey);
      }
    }
    
    print('📊 תאריכים זמינים:\n');
    
    if (dates.isEmpty) {
      print('   ❌ לא נמצאו תאריכים');
      return;
    }
    
    final sortedDates = dates.toList()..sort();
    
    for (final date in sortedDates) {
      final times = filesByDate[date]!.toSet().toList()..sort();
      print('   📅 $date:');
      print('      שעות: ${times.join(", ")}');
      print('      סה"כ: ${filesByDate[date]!.length} קבצים');
      print('');
    }
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 סיכום:');
    print('   ${sortedDates.length} תאריכים שונים');
    print('   תאריך ראשון: ${sortedDates.first}');
    print('   תאריך אחרון: ${sortedDates.last}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━');
    
    // המלצה
    if (sortedDates.length > 1) {
      print('\n💡 נמצאו ${sortedDates.length} תאריכים!');
      print('   אפשר להוריד מכל התאריכים לקבלת מוצרים נוספים');
    } else {
      print('\n⚠️  נמצא רק תאריך אחד');
      print('   האתר מציג רק עדכונים מהיום');
      print('   צריך להריץ את הסקריפט מדי יום לצבירת מוצרים');
    }
    
  } catch (e, stack) {
    print('❌ שגיאה: $e');
    print('\nStack trace:\n$stack');
  }
}
