// 📄 File: lib/screens/receipts/receipt_import_screen.dart
//
// 🎯 Purpose: מסך ניהול קבלות - Receipt Management Screen
//
// 📋 Features:
// ✅ רשימת כל הקבלות
// ✅ הוספת קבלה חדשה
// ✅ צפייה בקבלה
// ✅ ייבוא קבלות למלאי
// ✅ מיון דינמי (4 אפשרויות)
// ✅ סטטיסטיקה מלאה
// ✅ 4 Empty States: Loading, Error, Empty, Data
// ✅ Pull-to-Refresh
// ✅ Skeleton Screen ל-Loading
// ✅ Error Recovery עם retry
// ✅ Logging מפורט
//
// 🔗 Dependencies:
// - ReceiptProvider - ניהול קבלות
// - ReceiptToInventoryDialog - דיאלוג העברה למלאי
// - ReceiptViewScreen - תצוגת קבלה מפורטת
//
// 📊 Flow:
// 1. טעינת קבלות מה-Provider
// 2. הצגת רשימה + סטטיסטיקה + מיון
// 3. לחיצה על קבלה → ReceiptViewScreen
// 4. לחיצה על "למלאי" → דיאלוג ייבוא
// 5. FAB → יצירת קבלה חדשה
//
// Version: 3.0 - Complete Receipt Manager
// Last Updated: 17/10/2025

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/receipt.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/receipt_to_inventory_dialog.dart';
import '../../widgets/add_receipt_dialog.dart';
import '../../core/ui_constants.dart';
import 'receipt_view_screen.dart';

class ReceiptImportScreen extends StatefulWidget {
  const ReceiptImportScreen({super.key});

  @override
  State<ReceiptImportScreen> createState() => _ReceiptImportScreenState();
}

// 📊 סוג מיון
enum SortType {
  dateNewest,
  dateOldest,
  storeName,
  totalAmount,
}

class _ReceiptImportScreenState extends State<ReceiptImportScreen> {
  SortType _sortType = SortType.dateNewest;

  @override
  void initState() {
    super.initState();
    debugPrint('🧾 ReceiptImportScreen: initState');
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
        title: const Text('הקבלות שלי'),
        backgroundColor: cs.surfaceContainer,
        actions: [
          // כפתור מיון
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            tooltip: 'מיון',
            onSelected: (type) {
              debugPrint('📊 ReceiptImportScreen: שינוי מיון ל-$type');
              setState(() => _sortType = type);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortType.dateNewest,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18),
                    SizedBox(width: 8),
                    Text('חדש ← ישן'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortType.dateOldest,
                child: Row(
                  children: [
                    Icon(Icons.history, size: 18),
                    SizedBox(width: 8),
                    Text('ישן ← חדש'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortType.storeName,
                child: Row(
                  children: [
                    Icon(Icons.store, size: 18),
                    SizedBox(width: 8),
                    Text('שם חנות'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortType.totalAmount,
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 18),
                    SizedBox(width: 8),
                    Text('סכום (גבוה ← נמוך)'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(receiptProvider, cs),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addReceipt(),
        icon: const Icon(Icons.add),
        label: const Text('קבלה חדשה'),
        tooltip: 'הוסף קבלה',
      ),
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
            'אין קבלות עדיין',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'התחל להוסיף קבלות כדי לעקוב אחר ההוצאות שלך!',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: kSpacingXLarge),
          Center(
            child: FilledButton.icon(
              onPressed: () => _addReceipt(),
              icon: const Icon(Icons.add),
              label: const Text('הוסף קבלה ראשונה'),
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
    // 📊 מיון הרשימה
    final sortedReceipts = _sortReceipts(receipts);

    return RefreshIndicator(
      onRefresh: context.read<ReceiptProvider>().loadReceipts,
      child: ListView.builder(
        padding: const EdgeInsets.all(kSpacingMedium),
        itemCount: sortedReceipts.length + 1, // +1 לכרטיס סטטיסטיקה
        itemBuilder: (context, index) {
          // 📊 כרטיס סטטיסטיקה ראשון
          if (index == 0) {
            return _buildStatisticsCard(receipts, cs);
          }

          final receipt = sortedReceipts[index - 1];
          final dateStr = DateFormat('dd/MM/yyyy').format(receipt.date);
          
          return Card(
            color: cs.surfaceContainer,
            margin: const EdgeInsets.only(bottom: kSpacingMedium),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.orange,
                ),
              ),
              title: Text(
                receipt.storeName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('$dateStr • ${receipt.items.length} פריטים'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₪${receipt.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: kFontSizeBody,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'view') {
                        _viewReceipt(receipt);
                      } else if (value == 'import') {
                        _showImportDialog(receipt);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 8),
                            Text('צפה'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'import',
                        child: Row(
                          children: [
                            Icon(Icons.move_to_inbox, size: 18),
                            SizedBox(width: 8),
                            Text('ייבא למלאי'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () => _viewReceipt(receipt),
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

  /// מציג את הקבלה במסך צפייה.
  void _viewReceipt(Receipt receipt) {
    debugPrint('👁️ ReceiptImportScreen: צפייה בקבלה "${receipt.storeName}"');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptViewScreen(receipt: receipt),
      ),
    );
  }

  /// פותח Dialog לבחירת שיטת הוספת קבלה.
  /// 
  /// 2 אופציות:
  /// - 📷 צילום קבלה
  /// - 📱 קישור מ-SMS
  Future<void> _addReceipt() async {
    debugPrint('➕ ReceiptImportScreen: פותח Dialog לבחירת שיטה...');
    
    await showDialog(
      context: context,
      builder: (_) => const AddReceiptDialog(),
    );
    
    // רענון הרשימה אחרי שהמשתמש חוזר
    if (mounted) {
      debugPrint('🔄 ReceiptImportScreen: מרענן רשימת קבלות...');
      context.read<ReceiptProvider>().loadReceipts();
    }
  }

  /// ממיין רשימת קבלות לפי סוג המיון שנבחר.
  List<Receipt> _sortReceipts(List<Receipt> receipts) {
    final sorted = List<Receipt>.from(receipts);

    switch (_sortType) {
      case SortType.dateNewest:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortType.dateOldest:
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortType.storeName:
        sorted.sort((a, b) => a.storeName.compareTo(b.storeName));
        break;
      case SortType.totalAmount:
        sorted.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
    }

    return sorted;
  }

  /// בונה כרטיס סטטיסטיקה.
  Widget _buildStatisticsCard(List<Receipt> receipts, ColorScheme cs) {
    final totalReceipts = receipts.length;
    final totalItems = receipts.fold<int>(0, (sum, r) => sum + r.items.length);
    final totalAmount = receipts.fold<double>(0, (sum, r) => sum + r.totalAmount);

    return Card(
      color: cs.primaryContainer,
      margin: const EdgeInsets.only(bottom: kSpacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: cs.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'סטטיסטיקה',
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatisticItem(
                  icon: Icons.receipt_long,
                  label: 'קבלות',
                  value: totalReceipts.toString(),
                  color: cs.onPrimaryContainer,
                ),
                _StatisticItem(
                  icon: Icons.shopping_bag,
                  label: 'פריטים',
                  value: totalItems.toString(),
                  color: cs.onPrimaryContainer,
                ),
                _StatisticItem(
                  icon: Icons.attach_money,
                  label: 'סה"כ',
                  value: '₪${totalAmount.toStringAsFixed(0)}',
                  color: cs.onPrimaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 📊 Widget עזר - פריט סטטיסטיקה
class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: kFontSizeLarge,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: kFontSizeSmall,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
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