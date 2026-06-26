import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/customer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> customers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    final c = await db.getCustomerWithTotalSpent();
    setState(() => customers = c);
  }

  Future _add() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('زبون جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await db.addCustomer(Customer(name: nameCtrl.text, phone: phoneCtrl.text, notes: notesCtrl.text));
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (saved == true) _load();
  }

  Future _delete(int id) async {
    await db.deleteCustomer(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الزبائن')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: customers.isEmpty
            ? const Center(child: Text('لا يوجد زبائن', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: customers.length,
                itemBuilder: (_, i) {
                  final c = customers[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: Text((c['name'] as String)[0], style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${c['phone']} · ${c['orderCount']} طلبات'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${((c['totalSpent'] is int ? (c['totalSpent'] as int).toDouble() : c['totalSpent'] as double)).toStringAsFixed(0)} د.ع', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          if (c['notes'] != null && (c['notes'] as String).isNotEmpty)
                            Text(c['notes'], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                        ],
                      ),
                      onLongPress: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('حذف الزبون؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                            TextButton(onPressed: () { _delete(c['id']); Navigator.pop(context); }, child: const Text('حذف', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: _add,
      ),
    );
  }
}


