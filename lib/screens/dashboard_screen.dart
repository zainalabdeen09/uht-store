import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/sale.dart';
import '../models/product.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final db = DatabaseHelper();
  double todaySales = 0, weekSales = 0, monthSales = 0, totalSales = 0;
  int todayCount = 0, totalSalesCount = 0, lowStock = 0;
  List<Map<String, dynamic>> chartData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future _loadData() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    todaySales = await db.getTotalSales(start: todayStart, end: now);
    weekSales = await db.getTotalSales(start: weekStart, end: now);
    monthSales = await db.getTotalSales(start: monthStart, end: now);
    totalSales = await db.getTotalSales();
    todayCount = await db.getSalesCount(start: todayStart, end: now);
    totalSalesCount = await db.getSalesCount();

    final products = await db.getProducts();
    lowStock = products.where((p) => p.stock <= 3).length;

    chartData = await db.getDailySales(14);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('@uht.store'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // ─── TOP CARDS ───
            SizedBox(
              height: 110,
              child: Row(
                children: [
                  _statCard('اليوم', '${todaySales.toStringAsFixed(0)} د.ع', todayCount.toString(), Colors.purple, Icons.today),
                  const SizedBox(width: 8),
                  _statCard('هذا الأسبوع', '${weekSales.toStringAsFixed(0)} د.ع', '', Colors.green, Icons.weekend),
                  const SizedBox(width: 8),
                  _statCard('هذا الشهر', '${monthSales.toStringAsFixed(0)} د.ع', '', Colors.orange, Icons.date_range),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: Row(
                children: [
                  _miniCard('إجمالي المبيعات', '${totalSales.toStringAsFixed(0)} د.ع', Colors.indigo),
                  const SizedBox(width: 8),
                  _miniCard('عدد الطلبات', '$totalSalesCount', Colors.teal),
                  const SizedBox(width: 8),
                  _miniCard('مخزون منخفض', '$lowStock', lowStock > 0 ? Colors.red : Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ─── CHART ───
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text('آخر 14 يوم', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: chartData.isEmpty
                          ? const Center(child: Text('لا توجد بيانات'))
                          : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: chartData.fold<double>(0, (p, e) => e['total'] > p ? e['total'] : p) * 1.2,
                                barGroups: chartData.asMap().entries.map((e) =>
                                  BarChartGroupData(x: e.key, barRods: [
                                    BarChartRodData(
                                      toY: (e.value['total'] as double),
                                      color: Colors.purple,
                                      width: 10,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    )
                                  ])
                                ).toList(),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) => Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        DateFormat('d/M').format(DateTime.now().subtract(Duration(days: 13 - v.toInt()))),
                                        style: const TextStyle(fontSize: 8),
                                      ),
                                    ),
                                  )),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: const FlGridData(show: false),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String amount, String sub, Color color, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.05)], begin: Alignment.topLeft),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 16, color: color),
                const Spacer(),
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ]),
              const Spacer(),
              Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              if (sub.isNotEmpty) Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              const Spacer(),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
