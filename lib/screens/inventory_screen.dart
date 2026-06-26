import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final db = DatabaseHelper();
  List<Product> products = [];
  bool showLowStock = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    final p = await db.getProducts();
    setState(() => products = p);
  }

  Future _addOrEdit({Product? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final catCtrl = TextEditingController(text: existing?.category ?? '');
    final buyCtrl = TextEditingController(text: existing?.buyPrice.toString() ?? '');
    final sellCtrl = TextEditingController(text: existing?.sellPrice.toString() ?? '');
    final stockCtrl = TextEditingController(text: existing?.stock.toString() ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'إضافة منتج' : 'تعديل المنتج'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: buyCtrl, decoration: const InputDecoration(labelText: 'سعر الشراء', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: sellCtrl, decoration: const InputDecoration(labelText: 'سعر البيع', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'المخزون', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              if (existing == null) {
                await db.addProduct(Product(
                  name: nameCtrl.text,
                  category: catCtrl.text,
                  buyPrice: double.tryParse(buyCtrl.text) ?? 0,
                  sellPrice: double.tryParse(sellCtrl.text) ?? 0,
                  stock: int.tryParse(stockCtrl.text) ?? 0,
                ));
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
    await db.deleteProduct(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final list = showLowStock ? products.where((p) => p.stock <= 3).toList() : products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المخزون'),
        actions: [
          IconButton(
            icon: Icon(showLowStock ? Icons.inventory_2 : Icons.warning_amber),
            onPressed: () => setState(() => showLowStock = !showLowStock),
            tooltip: 'المخزون المنخفض',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: products.isEmpty
            ? const Center(child: Text('لا توجد منتجات', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  return Card(
                    child: ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.category} | شراء: ${p.buyPrice.toStringAsFixed(0)} | بيع: ${p.sellPrice.toStringAsFixed(0)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${p.stock}', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: p.stock <= 3 ? Colors.red : Colors.green,
                          )),
                          const Text('قطعة', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                      onLongPress: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('حذف المنتج؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                            TextButton(onPressed: () { _delete(p.id!); Navigator.pop(context); }, child: const Text('حذف', style: TextStyle(color: Colors.red))),
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
        onPressed: () => _addOrEdit(),
      ),
    );
  }
}
