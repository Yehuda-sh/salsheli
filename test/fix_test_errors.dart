// Script to find and print exact lines from test file
import 'dart:io';

void main() async {
  final file = File('C:/projects/salsheli/test/providers/user_context_test.dart');
  final lines = await file.readAsLines();
  
  // Find lines 690-710
  print('Lines 690-710:');
  for (int i = 689; i < 710 && i < lines.length; i++) {
    print('Line ${i + 1}: "${lines[i]}"');
  }
  
  print('\n\nLines 1270-1285:');
  for (int i = 1269; i < 1285 && i < lines.length; i++) {
    print('Line ${i + 1}: "${lines[i]}"');
  }
}
