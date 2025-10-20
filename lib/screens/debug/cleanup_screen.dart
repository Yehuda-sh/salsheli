// 📄 File: lib/screens/debug/cleanup_screen.dart
// 
// Purpose: מסך Debug לניקוי נתונים פגומים
//
// Usage: נגיש רק בדבאג או למשתמש Admin

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/ui_constants.dart';

class CleanupScreen extends StatefulWidget {
  final String householdId;

  const CleanupScreen({
    super.key,
    required this.householdId,
  });

  @override
  State<CleanupScreen> createState() => _CleanupScreenState();
}

class _CleanupScreenState extends State<CleanupScreen> {
  bool _isScanning = false;
  bool _isDeleting = false;
  List<String> _corruptedIds = [];
  String _status = '';

  /// סריקת פריטים פגומים
  Future<void> _scanCorruptedItems() async {
    setState(() {
      _isScanning = true;
      _status = 'סורק פריטים...';
      _corruptedIds = [];
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('inventory')
          .where('household_id', isEqualTo: widget.householdId)
          .limit(1000)
          .get();

      debugPrint('📊 נמצאו ${snapshot.docs.length} פריטים במלאי');

      final corruptedIds = <String>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final productName = data['productName'];

        if (productName == null) {
          corruptedIds.add(doc.id);
          debugPrint('❌ פריט פגום: ${doc.id}');
        }
      }

      setState(() {
        _corruptedIds = corruptedIds;
        _status = 'נמצאו ${corruptedIds.length} פריטים פגומים';
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _status = 'שגיאה: $e';
        _isScanning = false;
      });
    }
  }

  /// מחיקת פריטים פגומים
  Future<void> _deleteCorruptedItems() async {
    if (_corruptedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('אין פריטים למחיקה')),
      );
      return;
    }

    // אישור
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ אזהרה'),
        content: Text(
          'האם למחוק ${_corruptedIds.length} פריטים פגומים?\n\nפעולה זו בלתי הפיכה!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('מחק'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
      _status = 'מוחק פריטים...';
    });

    int deleted = 0;

    try {
      // מחיקה ב-batches (500 לכל batch)
      const batchSize = 500;
      for (int i = 0; i < _corruptedIds.length; i += batchSize) {
        final batch = FirebaseFirestore.instance.batch();
        final end = (i + batchSize < _corruptedIds.length) ? i + batchSize : _corruptedIds.length;
        
        for (int j = i; j < end; j++) {
          final docRef = FirebaseFirestore.instance.collection('inventory').doc(_corruptedIds[j]);
          batch.delete(docRef);
        }
        
        await batch.commit();
        deleted = end;
        
        setState(() {
          _status = 'נמחקו $deleted/${_corruptedIds.length} פריטים...';
        });
      }

      setState(() {
        _status = '✅ הושלם! נמחקו $deleted פריטים';
        _corruptedIds = [];
        _isDeleting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ נמחקו $deleted פריטים בהצלחה'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'שגיאה במחיקה: $e';
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧹 ניקוי נתונים'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // כרטיס מידע
            Card(
              child: Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: kSpacingSmall),
                        Text(
                          'מידע',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpacingSmall),
                    Text(
                      'כלי זה סורק ומוחק פריטי מלאי פגומים (ללא שם מוצר) מ-Firestore.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: kSpacingSmall),
                    Text(
                      'Household: ${widget.householdId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: kSpacingLarge),

            // כפתור סריקה
            ElevatedButton.icon(
              onPressed: _isScanning || _isDeleting ? null : _scanCorruptedItems,
              icon: _isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isScanning ? 'סורק...' : 'סרוק פריטים פגומים'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(kSpacingMedium),
              ),
            ),

            const SizedBox(height: kSpacingMedium),

            // כפתור מחיקה
            if (_corruptedIds.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _isDeleting ? null : _deleteCorruptedItems,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_forever),
                label: Text(
                  _isDeleting
                      ? 'מוחק...'
                      : 'מחק ${_corruptedIds.length} פריטים',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),

            const SizedBox(height: kSpacingLarge),

            // סטטוס
            if (_status.isNotEmpty)
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Text(
                    _status,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),

            // רשימת פריטים פגומים
            if (_corruptedIds.isNotEmpty) ...[
              const SizedBox(height: kSpacingMedium),
              Text(
                'פריטים פגומים שנמצאו:',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: kSpacingSmall),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    itemCount: _corruptedIds.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.warning_amber, size: 16),
                        title: Text(
                          _corruptedIds[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
