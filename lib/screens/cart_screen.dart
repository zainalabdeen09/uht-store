import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/cart_item.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final db = DatabaseHelper();
  List<CartItem> items = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    final cartItems = await db.getCartItems();
    if (mounted) setState(() => items = cartItems);
  }

  int get _total => items.fold(0, (sum, item) => sum + item.total);

  void _checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutScreen(items: items)),
    ).then((_) => load());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        centerTitle: true,
        actions: items.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () async {
                    await db.clearCart();
                    load();
                  },
                ),
              ]
            : null,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('السلة فارغة', style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return Card(
                        color: theme.colorScheme.surfaceVariant,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(item.productName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 18, color: Colors.red[300]),
                                    onPressed: () async {
                                      await db.removeCartItem(items[i].id ?? 0);
                                      load();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.printing} | ${item.color} | ${item.size}',
                                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                                        onPressed: item.quantity > 1
                                            ? () async {
                                                await db.updateCartItemQty(items[i].id ?? 0, item.quantity - 1);
                                                load();
                                              }
                                            : null,
                                      ),
                                      Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 20),
                                        onPressed: () async {
                                          await db.updateCartItemQty(items[i].id ?? 0, item.quantity + 1);
                                          load();
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${item.total} د.ع',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الإجمالي', style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                            Text('$_total د.ع', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _checkout,
                            child: const Text('إتمام الطلب', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
