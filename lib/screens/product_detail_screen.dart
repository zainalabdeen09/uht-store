import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final db = DatabaseHelper();
  String _selectedPrinting = '';
  String _selectedColor = '';
  String _selectedSize = 'L';
  int _quantity = 1;

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'لا اعرف'];

  @override
  void initState() {
    super.initState();
    _selectedPrinting = widget.product.prices.keys.first;
    _selectedColor = widget.product.colors.first;
  }

  int get _currentPrice => widget.product.prices[_selectedPrinting] ?? 0;
  int get _totalPrice => _currentPrice * _quantity;

  void _addToCart() async {
    await db.addToCart(CartItem(
      productKey: widget.product.id,
      productName: widget.product.name,
      printing: _selectedPrinting,
      price: _currentPrice,
      color: _selectedColor,
      size: _selectedSize,
      quantity: _quantity,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الإضافة إلى السلة'), backgroundColor: Color(0xFF22c55e)),
      );
    }
  }

  void _buyNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          items: [
            CartItem(
              productKey: widget.product.id,
              productName: widget.product.name,
              printing: _selectedPrinting,
              price: _currentPrice,
              color: _selectedColor,
              size: _selectedSize,
              quantity: _quantity,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Product icon placeholder
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.checkroom, color: theme.colorScheme.primary, size: 60),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.product.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Printing
          Text('نوع الطباعة', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPrinting,
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: widget.product.prices.keys.map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => setState(() => _selectedPrinting = v!),
          ),
          const SizedBox(height: 18),

          // Color
          Text('اللون', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.product.colors.map((c) {
              final selected = _selectedColor == c;
              return ChoiceChip(
                label: Text(c),
                selected: selected,
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(color: selected ? Colors.white : null),
                onSelected: (_) => setState(() => _selectedColor = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Size
          Text('المقاس', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _sizes.map((s) {
              final selected = _selectedSize == s;
              return ChoiceChip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                selected: selected,
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(color: selected ? Colors.white : null),
                onSelected: (_) => setState(() => _selectedSize = s),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Quantity
          Text('الكمية', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton.filled(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              const SizedBox(width: 16),
              Text('$_quantity', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              IconButton.filled(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Price
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي', style: TextStyle(fontSize: 16)),
                Text(
                  '$_totalPrice د.ع',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Add to cart button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('أضف إلى السلة', style: TextStyle(fontSize: 16)),
              onPressed: _addToCart,
            ),
          ),
          const SizedBox(height: 12),

          // Buy now button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: Icon(Icons.shopping_bag, color: theme.colorScheme.primary),
              label: Text('اشتري الآن', style: TextStyle(fontSize: 16, color: theme.colorScheme.primary)),
              onPressed: _buyNow,
            ),
          ),
        ],
      ),
    );
  }
}
