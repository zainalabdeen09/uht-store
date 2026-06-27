import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'models/section.dart';
import 'app_state.dart';
import 'screens/home_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/admin_dashboard_screen.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const UhtredStoreApp(),
    ),
  );
}

class UhtredStoreApp extends StatelessWidget {
  const UhtredStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, tp, __) => MaterialApp(
        title: 'Uhtred Store',
        debugShowCheckedModeBanner: false,
        themeMode: tp.mode,
        theme: _lightTheme(),
        darkTheme: _darkTheme(),
        home: const MainShell(),
      ),
    );
  }

  ThemeData _darkTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0a0a0f),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8b5cf6),
      secondary: Color(0xFF7c3aed),
      surface: Color(0xFF0a0a0f),
      surfaceVariant: Color(0xFF0f0f1a),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFFFFFFFF),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0a0a0f),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF0f0f1a),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0f0f1a),
      indicatorColor: const Color(0xFF8b5cf6).withOpacity(0.3),
      labelTextStyle: WidgetStateProperty.resolveWith((_) => const TextStyle(fontSize: 11, color: Color(0xFFFFFFFF))),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF8b5cf6));
        }
        return const IconThemeData(color: Color(0x66FFFFFF));
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8b5cf6),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0f0f1a),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: const TextStyle(color: Color(0x66FFFFFF)),
    ),
    dividerTheme: const DividerThemeData(color: Color(0x1AFFFFFF)),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF8b5cf6).withOpacity(0.15),
      selectedColor: const Color(0xFF8b5cf6),
      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFFFFFFFF)),
      headlineMedium: TextStyle(color: Color(0xFFFFFFFF)),
      titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
      titleMedium: TextStyle(color: Color(0xFFFFFFFF)),
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
      bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
      labelLarge: TextStyle(color: Color(0xFFFFFFFF)),
    ),
  );

  ThemeData _lightTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8b5cf6),
      secondary: Color(0xFF7c3aed),
      surface: Color(0xFFF5F5F5),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1a1a2e),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _cartKey = GlobalKey<CartScreenState>();

  @override
  Widget build(BuildContext context) {
    final user = AppState.currentUser;
    final isAdmin = user?.username == 'za_c10';

    final screens = <Widget>[
      const HomeScreen(),
      const _SectionsGrid(),
      CartScreen(key: _cartKey),
      const ProfileScreen(),
      if (isAdmin) const AdminDashboardScreen(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
      const NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'المنتجات'),
      const NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'السلة'),
      const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
      if (isAdmin) const NavigationDestination(icon: Icon(Icons.admin_panel_settings), selectedIcon: Icon(Icons.admin_panel_settings), label: 'الإدارة'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          if (i == 2) _cartKey.currentState?.load();
        },
        destinations: destinations,
      ),
    );
  }
}

class _SectionsGrid extends StatefulWidget {
  const _SectionsGrid();

  @override
  State<_SectionsGrid> createState() => _SectionsGridState();
}

class _SectionsGridState extends State<_SectionsGrid> {
  final db = DatabaseHelper();
  List<Section> sections = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    final s = await db.getSections();
    setState(() => sections = s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: sections.length,
        itemBuilder: (_, i) {
          final s = sections[i];
          final icons = [
            Icons.checkroom,
            Icons.fitness_center,
            Icons.sports_gymnastics,
            Icons.bedtime,
            Icons.golf_course,
            Icons.style,
          ];
          final icon = s.id < icons.length ? icons[s.id - 1] : Icons.shopping_bag;
          final colors = [
            const Color(0xFF8b5cf6),
            const Color(0xFF22c55e),
            const Color(0xFFf59e0b),
            const Color(0xFFef4444),
            const Color(0xFF3b82f6),
            const Color(0xFFec4899),
          ];
          final color = s.id < colors.length ? colors[s.id - 1] : colors[0];
          return Card(
            color: theme.colorScheme.surfaceVariant,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductListScreen(section: s)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.productCount} منتجات',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
