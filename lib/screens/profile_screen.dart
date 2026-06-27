import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../app_state.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final db = DatabaseHelper();
  AppUser? _user;

  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _gender = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future _loadUser() async {
    final user = AppState.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        _emailCtrl.text = user.email;
        _phoneCtrl.text = user.phone;
        _addressCtrl.text = user.address;
        _gender = user.gender;
      });
    }
  }

  void setUser(AppUser user) {
    AppState.currentUser = user;
    setState(() {
      _user = user;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phone;
      _addressCtrl.text = user.address;
      _gender = user.gender;
    });
  }

  Future _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && _user != null) {
      _user!.avatarPath = file.path;
      await db.updateUser(_user!);
      setState(() {});
    }
  }

  Future _saveProfile() async {
    if (_user == null) return;
    setState(() => _loading = true);
    _user!.email = _emailCtrl.text;
    _user!.phone = _phoneCtrl.text;
    _user!.address = _addressCtrl.text;
    _user!.gender = _gender;
    await db.updateUser(_user!);
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الملف الشخصي'), backgroundColor: Color(0xFF22c55e)),
      );
    }
  }

  void _logout() {
    AppState.currentUser = null;
    setState(() => _user = null);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text('يرجى تسجيل الدخول', style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface.withOpacity(0.5))),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final user = await Navigator.push<AppUser>(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                  if (user != null) setUser(user);
                },
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    final isAdmin = _user!.username == 'za_c10';

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          // Avatar
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    backgroundImage: _user!.avatarPath.isNotEmpty
                        ? FileImage(File(_user!.avatarPath))
                        : null,
                    child: _user!.avatarPath.isEmpty
                        ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _user!.username,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // Fields
          TextField(
            controller: _emailCtrl,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: const Icon(Icons.email),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: const Icon(Icons.phone),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressCtrl,
            decoration: InputDecoration(
              labelText: 'العنوان',
              prefixIcon: const Icon(Icons.location_on),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _gender.isEmpty ? null : _gender,
            decoration: InputDecoration(
              labelText: 'الجنس',
              prefixIcon: const Icon(Icons.wc),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const [
              DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
              DropdownMenuItem(value: 'انثى', child: Text('انثى')),
            ],
            onChanged: (v) => setState(() => _gender = v!),
          ),
          const SizedBox(height: 24),

          // Save
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _loading ? null : _saveProfile,
              child: _loading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('حفظ التعديلات', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),

          // My Orders
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(Icons.receipt_long, color: theme.colorScheme.primary),
            label: Text('طلباتي', style: TextStyle(color: theme.colorScheme.primary)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrdersScreen(userId: _user!.id))),
          ),
          const SizedBox(height: 12),

          // Admin dashboard (za_c10 only)
          if (isAdmin)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.amber),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: Icon(Icons.admin_panel_settings, color: Colors.amber),
              label: Text('لوحة التحكم', style: TextStyle(color: Colors.amber)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
            ),
          if (isAdmin) const SizedBox(height: 12),

          // Instagram / TikTok
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.pink.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.camera_alt, color: Colors.pink.shade300),
                label: Text('Instagram', style: TextStyle(color: Colors.pink.shade300)),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.cyan.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.music_note, color: Colors.cyan.shade300),
                label: Text('TikTok', style: TextStyle(color: Colors.cyan.shade300)),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Logout
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red[300]),
              onPressed: _logout,
              child: const Text('تسجيل الخروج'),
            ),
          ),
        ],
      ),
    );
  }
}
