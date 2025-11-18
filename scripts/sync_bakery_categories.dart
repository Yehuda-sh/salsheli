// 📄 File: scripts/sync_bakery_categories.dart
//
// 🔄 סקריפט לסנכרון קבצי bakery.json
//     - לוקח את כל המוצרים מ-list_types/bakery.json
//     - מסנן רק מוצרים בקטגוריית "מאפים"
//     - מעתיק אותם ל-by_category/bakery.json
//     - מתקן קטגוריות שגויות
//
// 🚀 הרצה:
//     dart scripts/sync_bakery_categories.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔄 סנכרון קבצי bakery.json');
  print('=' * 50);

  // 1. קרא את list_types/bakery.json
  final sourceFile = File('assets/data/list_types/bakery.json');
  if (!sourceFile.existsSync()) {
    print('❌ קובץ המקור לא נמצא: ${sourceFile.path}');
    exit(1);
  }

  final sourceContent = await sourceFile.readAsString();
  final sourceProducts = (jsonDecode(sourceContent) as List)
      .cast<Map<String, dynamic>>();

  print('📦 נמצאו ${sourceProducts.length} מוצרים ב-list_types/bakery.json');

  // 2. תקן קטגוריות שגויות + סנן רק מאפים
  var fixedCount = 0;
  final bakeryProducts = <Map<String, dynamic>>[];

  for (var product in sourceProducts) {
    final name = product['name'] as String? ?? '';
    var category = product['category'] as String?;

    // תיקון קטגוריות שגויות
    if (name.contains('לחם') && category == 'מוצרי חלב') {
      print('🔧 מתקן: "$name" מ-"$category" ל-"מאפים"');
      product['category'] = 'מאפים';
      category = 'מאפים';
      fixedCount++;
    }

    // זעתר זה תבלין, לא מאפה - נשאיר אותו בירקות או נשנה לתבלינים
    if (name.contains('זעתר') && category == 'ירקות') {
      print('ℹ️  "$name" נשאר בקטגוריה "$category" (לא מאפה)');
      continue; // דלג על זעתר
    }

    // רק מוצרים בקטגוריית "מאפים"
    if (category == 'מאפים') {
      bakeryProducts.add(product);
    }
  }

  print('✅ תוקנו $fixedCount קטגוריות');
  print('🍞 נמצאו ${bakeryProducts.length} מוצרי מאפים');

  // 3. שמור ל-by_category/bakery.json
  final targetFile = File('assets/data/by_category/bakery.json');

  // גיבוי
  if (targetFile.existsSync()) {
    final backupPath = '${targetFile.path}.backup';
    await targetFile.copy(backupPath);
    print('💾 גיבוי נשמר: $backupPath');
  }

  // שמירה
  const encoder = JsonEncoder.withIndent('  ');
  final targetContent = encoder.convert(bakeryProducts);
  await targetFile.writeAsString(targetContent);
  print('💾 נשמר ב-by_category/bakery.json');

  // 4. עדכן גם את list_types/bakery.json עם התיקונים
  if (fixedCount > 0) {
    final sourceBackupPath = '${sourceFile.path}.backup';
    await sourceFile.copy(sourceBackupPath);
    print('💾 גיבוי של list_types/bakery.json נשמר');

    final updatedContent = encoder.convert(sourceProducts);
    await sourceFile.writeAsString(updatedContent);
    print('💾 list_types/bakery.json עודכן עם התיקונים');
  }

  print('');
  print('=' * 50);
  print('✅ הסנכרון הושלם בהצלחה!');
  print('📊 סיכום:');
  print('   - $fixedCount קטגוריות תוקנו');
  print('   - ${bakeryProducts.length} מוצרי מאפים ב-by_category/bakery.json');
}
