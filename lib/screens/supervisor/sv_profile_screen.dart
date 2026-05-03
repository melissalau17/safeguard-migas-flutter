import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import '../../services/api_service.dart';
import '../login_screen.dart';
import 'sv_alert_screen.dart';
import 'sv_drift_screen.dart';
import 'sv_history_screen.dart';

class SvProfileScreen extends StatefulWidget {
  const SvProfileScreen({super.key});
  @override
  State<SvProfileScreen> createState() => _SvProfileScreenState();
}

class _SvProfileScreenState extends State<SvProfileScreen> {
  bool _semuaAlert   = true;
  bool _dataDrift    = true;
  bool _modelRetrain = true;

  String _name       = '';
  String _employeeId = '';
  String _initials   = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name  = prefs.getString('name') ?? 'Supervisor';
    setState(() {
      _name       = name;
      _employeeId = prefs.getString('employee_id') ?? '-';
      _initials   = name.trim().split(' ').take(2)
          .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
      _semuaAlert   = prefs.getBool('sv_notif_semua') ?? true;
      _dataDrift    = prefs.getBool('sv_notif_drift') ?? true;
      _modelRetrain = prefs.getBool('sv_notif_retrain') ?? true;
    });
  }

  Future<void> _setToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
      body: SafeArea(child: Column(children: [
        _header(),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          AppCard(padding: const EdgeInsets.all(16), child: Column(children: [
            Row(children: [
              UserAvatar(
                initials: _initials.isNotEmpty ? _initials : 'SV',
                bg: const Color(0xFF2A1A5A),
                fg: AppColors.purple,
                size: 52,
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_name.isNotEmpty ? _name : 'Supervisor',
                    style: const TextStyle(color: AppColors.textPrimary,
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                const Text('Supervisor / Engineer',
                    style: TextStyle(color: AppColors.textSecondary,
                        fontSize: 12)),
                const SizedBox(height: 2),
                Text('ID: $_employeeId',
                    style: const TextStyle(color: AppColors.purple,
                        fontSize: 11)),
              ])),
            ]),
            const SizedBox(height: 14),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            _infoRow('Cakupan unit', 'Semua unit'),
            const SizedBox(height: 8),
            _infoRow('Shift aktif', 'Pagi (06:00–14:00)',
                valueColor: AppColors.green),
          ])),
          const SizedBox(height: 12),
          AppCard(padding: const EdgeInsets.all(14), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionLabel('Akses & notifikasi'),
            const SizedBox(height: 10),
            _toggleRow('Semua alert', _semuaAlert, (v) {
              _setToggle('sv_notif_semua', v);
              setState(() => _semuaAlert = v);
            }),
            const Divider(color: AppColors.border, height: 1),
            _toggleRow('Data drift alert', _dataDrift, (v) {
              _setToggle('sv_notif_drift', v);
              setState(() => _dataDrift = v);
            }),
            const Divider(color: AppColors.border, height: 1),
            _toggleRow('Model retraining notif', _modelRetrain, (v) {
              _setToggle('sv_notif_retrain', v);
              setState(() => _modelRetrain = v);
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
      child: const Text('Profil', style: TextStyle(
          color: AppColors.textPrimary, fontSize: 16,
          fontWeight: FontWeight.w500)),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(
          color: AppColors.textSecondary, fontSize: 13)),
      Text(value, style: TextStyle(
          color: valueColor ?? AppColors.textPrimary, fontSize: 13)),
    ]);
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 13)),
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
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Beranda',
            onTap: () => Navigator.pop(context)),
        BottomNavItem(icon: Icons.notifications_outlined, label: 'Alert',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SvAlertScreen()))),
        BottomNavItem(icon: Icons.show_chart, label: 'Data Drift',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SvDriftScreen()))),
        BottomNavItem(icon: Icons.history, label: 'Riwayat',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SvHistoryScreen()))),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil',
            active: true, onTap: () {}),
      ]),
    );
  }
}