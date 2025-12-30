// Script to clean empty/meaningless brand values from list_types JSON files
// Run with: dart scripts/clean_empty_brands.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  final listTypesDir = Directory('assets/data/list_types');

  if (!await listTypesDir.exists()) {
    print('❌ Directory not found: ${listTypesDir.path}');
    exit(1);
  }

  final jsonFiles = await listTypesDir
      .list()
      .where((f) => f.path.endsWith('.json'))
      .toList();

  print('🔍 Found ${jsonFiles.length} JSON files to process\n');

  int totalCleaned = 0;

  for (final file in jsonFiles) {
    final jsonFile = File(file.path);
    final fileName = jsonFile.path.split(Platform.pathSeparator).last;

    try {
      final content = await jsonFile.readAsString();
      final List<dynamic> items = json.decode(content);

      int cleanedInFile = 0;

      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final brand = item['brand'];
          // Remove empty, "---", or whitespace-only brands
          if (brand != null &&
              (brand == '' ||
               brand == '---' ||
               brand == '-' ||
               brand == 'כללי' ||
               brand.toString().trim().isEmpty)) {
            item.remove('brand');
            cleanedInFile++;
          }
        }
      }

      if (cleanedInFile > 0) {
        // Write back with pretty formatting
        final encoder = JsonEncoder.withIndent('  ');
        await jsonFile.writeAsString(encoder.convert(items) + '\n');
        print('✅ $fileName: removed $cleanedInFile empty brand values');
        totalCleaned += cleanedInFile;
      } else {
        print('⏭️  $fileName: no empty brands found');
      }
    } catch (e) {
      print('❌ $fileName: Error - $e');
    }
  }

  print('\n📊 Total: cleaned $totalCleaned empty brand values');
}
