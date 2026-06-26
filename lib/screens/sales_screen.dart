import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/sale.dart';
import 'add_sale_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final db = DatabaseHelper();
  List<Sale> sales = [];
  String filter = 'الكل';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    final s = await db.getSales();
    setState(() => sales = s);
  }

  Future _delete(int id) async {
    await db.deleteSale(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filter == 'الكل' ? sales : sales.where((s) => s.status == 'paid').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المبيعات'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => filter = v),
            itemBuilder: (_) => ['الكل', 'المدفوع'].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: sales.isEmpty
            ? const Center(child: Text('لا توجد مبيعات', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final s = filtered[i];
                  return Card(
                    child: ListTile(
                      title: Text(s.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${s.customerName} | ${s.quantity} قطعة | ${DateFormat('d/M/yyyy').format(s.date)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${s.total.toStringAsFixed(0)} د.ع', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          Text(s.status == 'paid' ? 'مدفوع' : 'معلق', style: TextStyle(fontSize: 11, color: s.status == 'paid' ? Colors.green : Colors.orange)),
                        ],
                      ),
                      onLongPress: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('حذف الفاتورة؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                            TextButton(onPressed: () { _delete(s.id!); Navigator.pop(context); }, child: const Text('حذف', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSaleScreen())).then((_) => _load()),
      ),
    );
  }
}
