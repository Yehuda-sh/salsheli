// 📄 File: lib/screens/settings/settings_screen.dart
// תיאור: מסך הגדרות ופרופיל משולב - ניהול פרופיל אישי, הגדרות קבוצה, והעדפות
//
// תכונות:
// ✅ פרופיל אישי מחובר ל-UserContext (שם, אימייל, תמונה)
// ✅ סטטיסטיקות בזמן אמת (רשימות, קבלות, פריטים במזווה)
// ✅ ניהול קבוצה/משק בית (תמיכה במשפחה, ועד בית, ועד גן)
// ✅ הכנה לניהול חברים עתידי
// ✅ הגדרות אישיות עם שמירה ב-SharedPreferences
// ✅ קישורים מהירים למסכים נוספים
// ✅ התנתקות בטוחה

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salsheli/providers/user_context.dart';
import 'package:salsheli/providers/shopping_lists_provider.dart';
import 'package:salsheli/providers/receipt_provider.dart';
import 'package:salsheli/providers/inventory_provider.dart';
import 'package:salsheli/providers/products_provider.dart';
import 'package:salsheli/models/shopping_list.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Keys לשמירה מקומית
  static const _kHouseholdName = 'settings.householdName';
  static const _kHouseholdType = 'settings.householdType';
  static const _kPreferredStores = 'settings.preferredStores';
  static const _kFamilySize = 'settings.familySize';
  static const _kWeeklyReminders = 'settings.weeklyReminders';
  static const _kHabitsAnalysis = 'settings.habitsAnalysis';

  // מצב UI
  String householdName = "הקבוצה שלי";
  String householdType = "משפחה"; // משפחה, ועד בית, ועד גן, אחר
  bool isEditingHouseholdName = false;
  final TextEditingController householdNameController = TextEditingController();

  // חברים (דמה - בעתיד מה-Provider)
  final List<Map<String, String>> members = [
    {"name": "יוסי כהן", "role": "בעלים"},
    {"name": "דנה לוי", "role": "עורך"},
    {"name": "נועם", "role": "צופה"},
  ];

  // חנויות מועדפות
  final List<String> preferredStores = ["שופרסל", "רמי לוי"];
  final TextEditingController storeController = TextEditingController();

  // הגדרות
  int familySize = 3;
  late final TextEditingController familySizeController;
  bool weeklyReminders = true;
  bool habitsAnalysis = true;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    householdNameController.text = householdName;
    familySizeController = TextEditingController(text: familySize.toString());
    _loadSettings();
  }

  @override
  void dispose() {
    householdNameController.dispose();
    storeController.dispose();
    familySizeController.dispose();
    super.dispose();
  }

  // טעינת הגדרות מ-SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        householdName = prefs.getString(_kHouseholdName) ?? householdName;
        householdType = prefs.getString(_kHouseholdType) ?? householdType;
        familySize = prefs.getInt(_kFamilySize) ?? familySize;
        weeklyReminders = prefs.getBool(_kWeeklyReminders) ?? true;
        habitsAnalysis = prefs.getBool(_kHabitsAnalysis) ?? true;

        final storesJson = prefs.getString(_kPreferredStores);
        if (storesJson != null && storesJson.isNotEmpty) {
          final List<String> decoded = storesJson.split(',');
          preferredStores.clear();
          preferredStores.addAll(decoded);
        }

        householdNameController.text = householdName;
        familySizeController.text = familySize.toString();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() => _loading = false);
    }
  }

  // שמירת הגדרות ב-SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kHouseholdName, householdName);
      await prefs.setString(_kHouseholdType, householdType);
      await prefs.setInt(_kFamilySize, familySize);
      await prefs.setBool(_kWeeklyReminders, weeklyReminders);
      await prefs.setBool(_kHabitsAnalysis, habitsAnalysis);
      await prefs.setString(_kPreferredStores, preferredStores.join(','));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // עריכת שם הקבוצה
  void _toggleEditHousehold() {
    if (isEditingHouseholdName) {
      setState(() {
        householdName = householdNameController.text.trim();
        isEditingHouseholdName = false;
      });
      _saveSettings();
    } else {
      setState(() => isEditingHouseholdName = true);
    }
  }

  // הוספת חנות מועדפת
  void _addStore() {
    final text = storeController.text.trim();
    if (text.isNotEmpty && !preferredStores.contains(text)) {
      setState(() {
        preferredStores.add(text);
        storeController.clear();
      });
      _saveSettings();
    }
  }

  // הסרת חנות
  void _removeStore(int index) {
    setState(() => preferredStores.removeAt(index));
    _saveSettings();
  }

  // שינוי סוג הקבוצה
  void _changeHouseholdType(String? newType) {
    if (newType != null) {
      setState(() => householdType = newType);
      _saveSettings();
    }
  }

  // עדכון גודל משפחה
  void _updateFamilySize() {
    final newSize = int.tryParse(familySizeController.text);
    if (newSize != null && newSize > 0 && newSize <= 20) {
      setState(() => familySize = newSize);
      _saveSettings();
    }
  }

  // עדכון מחירים ידני
  Future<void> _updatePrices(BuildContext context) async {
    final productsProvider = context.read<ProductsProvider>();
    
    // הצגת SnackBar עם loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text('💰 מעדכן מחירים מ-API...'),
          ],
        ),
        duration: const Duration(minutes: 5), // זמן ארוך לעדכון
      ),
    );

    try {
      // קריאה ל-refreshProducts עם force=true
      await productsProvider.refreshProducts(force: true);

      // סגירת SnackBar הקודם
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // הצגת תוצאה
        final withPrice = productsProvider.productsWithPrice;
        final total = productsProvider.totalProducts;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ התעדכנו $withPrice מחירים מתוך $total מוצרים!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // שגיאה
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ שגיאה בעדכון מחירים: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // התנתקות
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('התנתקות'),
        content: const Text('האם אתה בטוח שברצונך להתנתק?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('התנתק', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // ניקוי UserContext
      await context.read<UserContext>().logout();

      // ניקוי SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // חזרה למסך התחברות
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userContext = context.watch<UserContext>();
    final listsProvider = context.watch<ShoppingListsProvider>();
    final receiptsProvider = context.watch<ReceiptProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    // חישוב סטטיסטיקות בזמן אמת
    final activeLists = listsProvider.lists.where((l) => l.status != ShoppingList.statusCompleted).length;
    final totalReceipts = receiptsProvider.receipts.length;
    final pantryItems = inventoryProvider.items.length;

    // פרטי משתמש
    final userName = userContext.user?.name ?? "משתמש";
    final userEmail = userContext.user?.email ?? "email@example.com";

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text("הגדרות ופרופיל"),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 פרופיל אישי
          Card(
            color: cs.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // תמונת פרופיל
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: cs.primary.withValues(alpha: 0.15),
                    child: Icon(Icons.person, color: cs.primary, size: 36),
                  ),
                  const SizedBox(width: 16),

                  // פרטים
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // כפתור עריכה
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("עריכת פרופיל - בקרוב!")),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("עריכה"),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 סטטיסטיקות מהירות
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  color: Colors.amber,
                  icon: Icons.shopping_cart_outlined,
                  label: "רשימות פעילות",
                  value: "$activeLists",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  color: Colors.green,
                  icon: Icons.receipt_long_outlined,
                  label: "קבלות",
                  value: "$totalReceipts",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  color: Colors.blue,
                  icon: Icons.inventory_2_outlined,
                  label: "פריטים במזווה",
                  value: "$pantryItems",
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 🔹 ניהול קבוצה
          Card(
            color: cs.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ניהול קבוצה",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // שם הקבוצה
                  Row(
                    children: [
                      Expanded(
                        child: isEditingHouseholdName
                            ? TextField(
                                controller: householdNameController,
                                decoration: const InputDecoration(
                                  hintText: "שם הקבוצה",
                                  isDense: true,
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _toggleEditHousehold(),
                              )
                            : Text(
                                householdName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      IconButton(
                        onPressed: _toggleEditHousehold,
                        icon: Icon(
                          isEditingHouseholdName ? Icons.check : Icons.edit,
                          color: cs.primary,
                        ),
                        tooltip: isEditingHouseholdName ? 'שמור' : 'ערוך שם',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // סוג הקבוצה
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "סוג הקבוצה:",
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      DropdownButton<String>(
                        value: householdType,
                        items: const [
                          DropdownMenuItem(
                            value: "משפחה",
                            child: Text("משפחה"),
                          ),
                          DropdownMenuItem(
                            value: "ועד בית",
                            child: Text("ועד בית"),
                          ),
                          DropdownMenuItem(
                            value: "ועד גן",
                            child: Text("ועד גן"),
                          ),
                          DropdownMenuItem(
                            value: "שותפים",
                            child: Text("שותפים"),
                          ),
                          DropdownMenuItem(value: "אחר", child: Text("אחר")),
                        ],
                        onChanged: _changeHouseholdType,
                        underline: Container(),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // חברי הקבוצה
                  Text(
                    "חברי הקבוצה (${members.length})",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // רשימת חברים
                  ...members.map(
                    (member) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.primary.withValues(alpha: 0.15),
                        child: Icon(Icons.person, color: cs.primary, size: 20),
                      ),
                      title: Text(member['name']!),
                      subtitle: Text(
                        member['role']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // כפתור ניהול חברים (עתידי)
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("ניהול חברים מלא - בקרוב! 🚧"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.group_add, size: 20),
                    label: const Text("ניהול חברים - בקרוב!"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 42),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 חנויות מועדפות
          Card(
            color: cs.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "חנויות מועדפות",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // רשימת חנויות
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      preferredStores.length,
                      (index) => Chip(
                        label: Text(preferredStores[index]),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeStore(index),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // הוספת חנות
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: storeController,
                          decoration: const InputDecoration(
                            hintText: "הוסף חנות...",
                            isDense: true,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addStore(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addStore,
                        icon: Icon(Icons.add, color: cs.primary),
                        tooltip: 'הוסף חנות',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 הגדרות אישיות
          Card(
            color: cs.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "הגדרות אישיות",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // גודל קבוצה
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("גודל הקבוצה (מספר אנשים)"),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: familySizeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _updateFamilySize(),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // תזכורות שבועיות
                  SwitchListTile(
                    title: const Text("תזכורות שבועיות"),
                    subtitle: const Text("קבל תזכורת לתכנן קניות"),
                    value: weeklyReminders,
                    onChanged: (val) {
                      setState(() => weeklyReminders = val);
                      _saveSettings();
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // ניתוח הרגלים
                  SwitchListTile(
                    title: const Text("ניתוח הרגלי קנייה"),
                    subtitle: const Text("קבל המלצות מבוססות נתונים"),
                    value: habitsAnalysis,
                    onChanged: (val) {
                      setState(() => habitsAnalysis = val);
                      _saveSettings();
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 קישורים מהירים
          Card(
            color: cs.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.receipt_long, color: cs.primary),
                  title: const Text("הקבלות שלי"),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.pushNamed(context, '/receipts'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.inventory_2_outlined, color: cs.primary),
                  title: const Text("המזווה שלי"),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.pushNamed(context, '/inventory'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.price_change_outlined, color: cs.primary),
                  title: const Text("השוואת מחירים"),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.pushNamed(context, '/price-compare'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.sync, color: cs.primary),
                  title: const Text("עדכן מחירים מ-API"),
                  subtitle: const Text("טעינת מחירים עדכניים מהרשת"),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => _updatePrices(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 התנתקות
          Card(
            color: cs.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("התנתק", style: TextStyle(color: Colors.red)),
              subtitle: const Text("יציאה מהחשבון"),
              onTap: _logout,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// 🎨 Widget עזר - כרטיס סטטיסטיקה
class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
