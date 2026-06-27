import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import 'orders_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final db = DatabaseHelper();
  Map<String, dynamic> stats = {};
  List<Map<String, dynamic>> orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    setState(() => _loading = true);
    final s = await db.getOrderStats();
    final o = await db.getAllOrders();
    setState(() {
      stats = s;
      orders = o;
      _loading = false;
    });
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'confirmed': return 'تم التأكيد';
      case 'shipped': return 'تم الشحن';
      case 'delivered': return 'تم التوصيل';
      case 'cancelled': return 'ملغي';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _statCard('إجمالي الطلبات', '${stats['totalOrders']}', Icons.receipt, Colors.blue),
                    const SizedBox(width: 8),
                    _statCard('الإيرادات', '${(stats['totalRevenue'] as double).toStringAsFixed(0)} د.ع', Icons.attach_money, const Color(0xFF22c55e)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statCard('قيد الانتظار', '${stats['pendingOrders']}', Icons.pending, Colors.orange),
                    const SizedBox(width: 8),
                    _statCard('المنتجات', '${stats['productCount']}', Icons.inventory_2, theme.colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('الطلبات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen(admin: true))),
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...orders.take(10).map((o) => _orderCard(o, theme)),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _orderCard(Map<String, dynamic> o, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o['orderNumber'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        DateFormat('d/M/yyyy HH:mm').format(DateTime.parse(o['createdAt'])),
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
                Text('${o['total']} د.ع', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${o['name']} | ${o['phone']}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _statusBtn(o['id'] as int, 'confirmed', 'تأكيد', Colors.blue),
                const SizedBox(width: 4),
                _statusBtn(o['id'] as int, 'shipped', 'شحن', Colors.purple),
                const SizedBox(width: 4),
                _statusBtn(o['id'] as int, 'delivered', 'توصيل', const Color(0xFF22c55e)),
                const SizedBox(width: 4),
                _statusBtn(o['id'] as int, 'cancelled', 'إلغاء', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBtn(int id, String status, String label, Color color) {
    return GestureDetector(
      onTap: () async {
        await db.updateOrderStatus(id, status);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: color)),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        color: theme.colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
        ),
      ),
    );
  }
}
