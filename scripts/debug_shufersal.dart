// Debug script to see what Shufersal returns

import 'package:http/http.dart' as http;

void main() async {
  print('🔍 מבדק את אתר שופרסל...\n');

  const url = 'https://prices.shufersal.co.il/';

  try {
    print('📡 שולח בקשה ל-$url');
    final response = await http.get(Uri.parse(url));

    print('📊 סטטוס: ${response.statusCode}');
    print('📏 גודל תגובה: ${response.body.length} תווים');
    print('\n${"=" * 60}');
    print('📄 תוכן (200 תווים ראשונים):');
    print('${"=" * 60}');
    print(response.body.substring(0, response.body.length > 200 ? 200 : response.body.length));
    print('${"=" * 60}\n');

    // חפש קישורים
    print('🔍 מחפש קישורים לקבצי XML...');

    final patterns = [
      r'href="([^"]*\.xml\.gz)"',
      r'href="([^"]*\.xml)"',
      r'href="([^"]*\.gz)"',
      r'<a[^>]*href="([^"]*)"',
    ];

    for (var pattern in patterns) {
      final regex = RegExp(pattern);
      final matches = regex.allMatches(response.body);
      print('\n📋 תבנית: $pattern');
      print('   מצא: ${matches.length} התאמות');

      if (matches.isNotEmpty) {
        print('   דוגמאות (5 ראשונות):');
        for (var match in matches.take(5)) {
          print('      - ${match.group(1)}');
        }
      }
    }

  } catch (e) {
    print('❌ שגיאה: $e');
  }
}
