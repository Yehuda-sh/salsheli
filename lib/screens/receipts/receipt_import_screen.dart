// 📄 File: lib/screens/receipts/receipt_import_screen.dart
//
// 🎯 Purpose: מסך ייבוא קבלות למלאי - Receipt Import Screen
//
// 📋 Features:
// ✅ רשימת קבלות זמינות לייבוא
// ✅ בחירת קבלה והעברה למלאי
// ✅ 4 Empty States: Loading, Error, Empty, Data
// ✅ Pull-to-Refresh
// ✅ Skeleton Screen ל-Loading
// ✅ Error Recovery עם retry
// ✅ Logging מפורט
//
// 🔗 Dependencies:
// - ReceiptProvider - ניהול קבלות
// - ReceiptToInventoryDialog - דיאלוג העברה למלאי
//
// 📊 Flow:
// 1. טעינת קבלות מה-Provider
// 2. הצגת רשימה עם סטטוס כל קבלה
// 3. לחיצה על "למלאי" → פותח דיאלוג
// 4. בחירת פריטים + מיקומים → העברה למלאי
//
// Version: 2.0 - Full Refactor with 4 States
// Last Updated: 17/10/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/receipt.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/receipt_to_inventory_dialog.dart';
import '../../core/ui_constants.dart';

class ReceiptImportScreen extends StatefulWidget {
  const ReceiptImportScreen({super.key});

  @override
  State<ReceiptImportScreen> createState() => _ReceiptImportScreenState();
}

class _ReceiptImportScreenState extends State<ReceiptImportScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('📥 ReceiptImportScreen: initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugPrint('🔄 ReceiptImportScreen: טוען קבלות ראשוניות...');
      context.read<ReceiptProvider>().loadReceipts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final receiptProvider = context.watch<ReceiptProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ייבוא קבלה למלאי'),
        backgroundColor: cs.surfaceContainer,
      ),
      body: _buildBody(receiptProvider, cs),
    );
  }

  /// בונה את גוף המסך לפי מצב ה-Provider.
  /// מטפל ב-4 מצבים: Loading, Error, Empty, Data.
  Widget _buildBody(ReceiptProvider provider, ColorScheme cs) {
    // 🔄 Loading State - Skeleton Screen
    if (provider.isLoading && provider.isEmpty) {
      debugPrint('🔄 ReceiptImportScreen: מציג Loading State');
      return _buildLoadingSkeleton(cs);
    }

    // ❌ Error State
    if (provider.hasError) {
      debugPrint('❌ ReceiptImportScreen: מציג Error State');
      return _buildErrorState(provider, cs);
    }

    // 📭 Empty State
    if (provider.isEmpty) {
      debugPrint('📭 ReceiptImportScreen: מציג Empty State');
      return _buildEmptyState(cs);
    }

    // 📜 Data State - רשימת קבלות
    final receipts = provider.receipts;
    debugPrint('📜 ReceiptImportScreen: מציג ${receipts.length} קבלות');
    return _buildReceiptsList(receipts, cs);
  }

  /// בונה Skeleton Screen ל-Loading State.
  Widget _buildLoadingSkeleton(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.all(kSpacingMedium),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        color: cs.surfaceContainer,
        margin: const EdgeInsets.only(bottom: kSpacingMedium),
        child: ListTile(
          leading: _SkeletonBox(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(20),
          ),
          title: const _SkeletonBox(width: double.infinity, height: 16),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 4),
              _SkeletonBox(width: 100, height: 12),
              SizedBox(height: 4),
              _SkeletonBox(width: 150, height: 12),
            ],
          ),
          trailing: const _SkeletonBox(width: 80, height: 32),
        ),
      ),
    );
  }

  /// בונה Error State עם retry.
  Widget _buildErrorState(ReceiptProvider provider, ColorScheme cs) {
    return RefreshIndicator(
      onRefresh: provider.loadReceipts,
      child: ListView(
        padding: const EdgeInsets.all(kSpacingLarge),
        children: [
          const SizedBox(height: kSpacingXXLarge),
          const Icon(
            Icons.error_outline,
            size: kIconSizeXLarge,
            color: Colors.red,
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            'אופס! משהו השתבש',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            provider.errorMessage ?? 'שגיאה לא ידועה',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: kSpacingXLarge),
          Center(
            child: FilledButton.icon(
              onPressed: () {
                debugPrint('🔄 ReceiptImportScreen: משתמש לחץ retry');
                provider.retry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('נסה שוב'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingXLarge,
                  vertical: kSpacingMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// בונה Empty State.
  Widget _buildEmptyState(ColorScheme cs) {
    return RefreshIndicator(
      onRefresh: context.read<ReceiptProvider>().loadReceipts,
      child: ListView(
        padding: const EdgeInsets.all(kSpacingLarge),
        children: [
          const SizedBox(height: kSpacingXXLarge),
          const Icon(
            Icons.receipt_long,
            size: kIconSizeXLarge,
            color: Colors.orange,
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            'אין קבלות זמינות',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'הוסף קבלות כדי לייבא אותן למלאי',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: kSpacingXLarge),
          Center(
            child: FilledButton.icon(
              onPressed: () {
                debugPrint('➕ ReceiptImportScreen: ניווט להוספת קבלה');
                Navigator.pushNamed(context, '/receipts');
              },
              icon: const Icon(Icons.add),
              label: const Text('עבור לקבלות'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingXLarge,
                  vertical: kSpacingMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// בונה רשימת קבלות.
  Widget _buildReceiptsList(List<Receipt> receipts, ColorScheme cs) {
    return RefreshIndicator(
      onRefresh: context.read<ReceiptProvider>().loadReceipts,
      child: ListView.builder(
        padding: const EdgeInsets.all(kSpacingMedium),
        itemCount: receipts.length,
        itemBuilder: (context, index) {
          final receipt = receipts[index];
          return Card(
            color: cs.surfaceContainer,
            margin: const EdgeInsets.only(bottom: kSpacingMedium),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.receipt,
                  color: Colors.orange,
                ),
              ),
              title: Text(
                receipt.storeName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${receipt.date.day}/${receipt.date.month}/${receipt.date.year}',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  Text(
                    '${receipt.items.length} פריטים • ₪${receipt.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: kFontSizeSmall,
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton.icon(
                onPressed: () => _showImportDialog(receipt),
                icon: const Icon(Icons.move_to_inbox, size: 16),
                label: const Text('למלאי'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// מציג דיאלוג ייבוא קבלה למלאי.
  /// 
  /// [receipt] - הקבלה לייבוא.
  /// מחזיר true אם הייבוא הצליח.
  Future<void> _showImportDialog(Receipt receipt) async {
    debugPrint('📥 ReceiptImportScreen: פותח דיאלוג ייבוא לקבלה "${receipt.storeName}"');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ReceiptToInventoryDialog(receipt: receipt),
    );

    if (!mounted) return;

    if (result == true) {
      debugPrint('✅ ReceiptImportScreen: ייבוא הצליח');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ הפריטים נוספו למלאי בהצלחה'),
          backgroundColor: Colors.green,
          duration: kSnackBarDuration,
        ),
      );
    } else {
      debugPrint('❌ ReceiptImportScreen: ייבוא בוטל או נכשל');
    }
  }
}

// 💀 Widget עזר - Skeleton Box ל-Loading State
class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const _SkeletonBox({this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(kBorderRadius),
      ),
    );
  }
}