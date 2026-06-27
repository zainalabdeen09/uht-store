import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class OrdersScreen extends StatefulWidget {
  final int? userId;
  final bool admin;

  const OrdersScreen({super.key, this.userId, this.admin = false});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    List<Map<String, dynamic>> data;
    if (widget.admin) {
      data = await db.getAllOrders();
    } else if (widget.userId != null) {
      data = await db.getOrdersByUser(widget.userId!);
    } else {
      data = [];
    }
    setState(() => orders = data);
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

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return const Color(0xFF22c55e);
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.admin ? 'جميع الطلبات' : 'طلباتي'),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                'لا توجد طلبات',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                itemBuilder: (_, i) {
                  final o = orders[i];
                  final items = jsonDecode(o['items'] ?? '[]') as List;
                  return Card(
                    color: theme.colorScheme.surfaceVariant,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o['orderNumber'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('d/M/yyyy HH:mm').format(DateTime.parse(o['createdAt'])),
                                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${o['total']} د.ع',
                                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _statusColor(o['status']).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _statusText(o['status']),
                                  style: TextStyle(fontSize: 11, color: _statusColor(o['status'])),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['productName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(
                                      '${item['printing']} | ${item['color']} | ${item['size']}',
                                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                    ),
                                  ],
                                ),
                              ),
                              Text('x${item['quantity']}'),
                              const SizedBox(width: 12),
                              Text('${item['price'] * item['quantity']} د.ع', style: TextStyle(color: theme.colorScheme.primary)),
                            ],
                          ),
                        )),
                        if (widget.admin)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _statusButton(o['id'] as int, 'confirmed', 'تأكيد', Colors.blue),
                                const SizedBox(width: 8),
                                _statusButton(o['id'] as int, 'shipped', 'شحن', Colors.purple),
                                const SizedBox(width: 8),
                                _statusButton(o['id'] as int, 'delivered', 'توصيل', const Color(0xFF22c55e)),
                                const SizedBox(width: 8),
                                _statusButton(o['id'] as int, 'cancelled', 'إلغاء', Colors.red),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _statusButton(int orderId, String status, String label, Color color) {
    return GestureDetector(
      onTap: () async {
        await db.updateOrderStatus(orderId, status);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: color)),
      ),
    );
  }
}
