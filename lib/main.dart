import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/customers_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UhtStoreApp());
}

class UhtStoreApp extends StatelessWidget {
  const UhtStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UHT Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.purple,
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    SalesScreen(),
    InventoryScreen(),
    CustomersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.sell), label: 'المبيعات'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'المخزون'),
          NavigationDestination(icon: Icon(Icons.people), label: 'الزبائن'),
        ],
      ),
    );
  }
}
