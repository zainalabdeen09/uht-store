import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/sale.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});
  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final db = DatabaseHelper();
  final _form = GlobalKey<FormState>();
  final _productCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _customerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  String _status = 'paid';

  @override
  void dispose() {
    _productCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _customerCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future _save() async {
    if (!_form.currentState!.validate()) return;
    final price = double.parse(_priceCtrl.text);
    final qty = int.parse(_qtyCtrl.text);
    await db.addSale(Sale(
      productName: _productCtrl.text,
      price: price,
      quantity: qty,
      total: price * qty,
      customerName: _customerCtrl.text,
      customerPhone: _phoneCtrl.text,
      date: _date,
      status: _status,
    ));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة فاتورة')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _productCtrl,
              decoration: const InputDecoration(labelText: 'اسم المنتج', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: 'السعر (د.ع)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty == true || double.tryParse(v!) == null ? 'أدخل رقماً' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _qtyCtrl,
              decoration: const InputDecoration(labelText: 'الكمية', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty == true || int.tryParse(v!) == null ? 'أدخل رقماً' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customerCtrl,
              decoration: const InputDecoration(labelText: 'اسم الزبون', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text('التاريخ: ${DateFormat('d/M/yyyy').format(_date)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(context: context, firstDate: DateTime(2024), lastDate: DateTime.now());
                if (d != null) setState(() => _date = d);
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'الحالة', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'paid', child: Text('مدفوع')),
                DropdownMenuItem(value: 'pending', child: Text('معلق')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _save,
              child: const Text('حفظ الفاتورة', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
