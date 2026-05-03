import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import '../../services/api_service.dart';
import '../login_screen.dart';
import 'op_alert_screen.dart';
import 'op_history_screen.dart';

class OpProfileScreen extends StatefulWidget {
  const OpProfileScreen({super.key});
  @override
  State<OpProfileScreen> createState() => _OpProfileScreenState();
}

class _OpProfileScreenState extends State<OpProfileScreen> {
  bool _alertCritical = true;
  bool _alertWarning = true;
  bool _vibrate = false;

  String _name = '';
  String _unit = '';
  String _employeeId = '';
  String _initials = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final allKeys = prefs.getKeys();
      debugPrint('SharedPrefs keys: $allKeys');
    for (final k in allKeys) {
      debugPrint('  $k = ${prefs.get(k)}');
    }
    final name = prefs.getString('name') ?? 'Operator';
    setState(() {
      _name = name;
      _unit = prefs.getString('unit') ?? '-';
      _employeeId = prefs.getString('employee_id') ?? '-';
      _initials = name
          .trim()
          .split(' ')
          .take(2)
          .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
          .join();
      // Load toggle state dari prefs
      _alertCritical = prefs.getBool('notif_critical') ?? true;
      _alertWarning = prefs.getBool('notif_warning') ?? true;
      _vibrate = prefs.getBool('notif_vibrate') ?? false;
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
          child: Column(children: [
        _header(),
        Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
          AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  UserAvatar(
                    initials: _initials.isNotEmpty ? _initials : 'OP',
                    bg: const Color(0xFF1A3A6A),
                    fg: AppColors.blue,
                    size: 52,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(_name.isNotEmpty ? _name : 'Operator',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        const Text('Operator Lapangan',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('ID: $_employeeId',
                            style: const TextStyle(
                                color: AppColors.blue, fontSize: 11)),
                      ])),
                ]),
                const SizedBox(height: 14),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                _infoRow('Unit penugasan', _unit.isNotEmpty ? _unit : '-'),
                const SizedBox(height: 8),
                _infoRow('Shift aktif', 'Pagi (06:00–14:00)',
                    valueColor: AppColors.green),
              ])),
          const SizedBox(height: 12),
          AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Notifikasi'),
                    const SizedBox(height: 10),
                    _toggleRow('Alert Critical', _alertCritical, (v) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('notif_critical', v);
                      setState(() => _alertCritical = v);
                    }),
                    const Divider(color: AppColors.border, height: 1),
                    _toggleRow('Alert Warning', _alertWarning, (v) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('notif_warning', v);
                      setState(() => _alertWarning = v);
                    }),
                    const Divider(color: AppColors.border, height: 1),
                    _toggleRow('Getaran (vibrate)', _vibrate, (v) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('notif_vibrate', v);
                      setState(() => _vibrate = v);
                    }),
                  ])),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.border,
                foregroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Keluar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ),
        ])),
        _bottomNav(context),
      ])),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: const Text('Profil',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Text(value,
          style: TextStyle(
              color: valueColor ?? AppColors.textPrimary, fontSize: 13)),
    ]);
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: ToggleOn(on: value),
        ),
      ]),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      color: AppColors.navBg,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        BottomNavItem(
            icon: Icons.grid_view_rounded,
            label: 'Beranda',
            onTap: () => Navigator.pop(context)),
        BottomNavItem(
            icon: Icons.notifications_outlined,
            label: 'Alert',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const OpAlertScreen()))),
        BottomNavItem(
            icon: Icons.history,
            label: 'Riwayat',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const OpHistoryScreen()))),
        BottomNavItem(
            icon: Icons.person_outline,
            label: 'Profil',
            active: true,
            onTap: () {}),
      ]),
    );
  }
}
