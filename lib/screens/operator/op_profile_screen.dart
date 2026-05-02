import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        _header(),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          AppCard(padding: const EdgeInsets.all(16), child: Column(children: [
            Row(children: const [
              UserAvatar(initials: 'BS', bg: Color(0xFF1A3A6A), fg: AppColors.blue, size: 52),
              SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Budi Santoso', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 2),
                Text('Operator Lapangan', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                SizedBox(height: 2),
                Text('ID: OP-20241', style: TextStyle(color: AppColors.blue, fontSize: 11)),
              ]),
            ]),
            const SizedBox(height: 14),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            _infoRow('Unit penugasan', 'R-201 Reaktor'),
            const SizedBox(height: 8),
            _infoRow('Shift aktif', 'Pagi (06:00–14:00)', valueColor: AppColors.green),
            const SizedBox(height: 8),
            _infoRow('Supervisor', 'Andi Wijaya'),
          ])),
          const SizedBox(height: 12),
          AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionLabel('Notifikasi'),
            const SizedBox(height: 10),
            _toggleRow('Alert Critical', _alertCritical, (v) => setState(() => _alertCritical = v)),
            const Divider(color: AppColors.border, height: 1),
            _toggleRow('Alert Warning', _alertWarning, (v) => setState(() => _alertWarning = v)),
            const Divider(color: AppColors.border, height: 1),
            _toggleRow('Getaran (vibrate)', _vibrate, (v) => setState(() => _vibrate = v)),
          ])),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.border, foregroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Keluar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: const Text('Profil', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Text(value, style: TextStyle(color: valueColor ?? AppColors.textPrimary, fontSize: 13)),
    ]);
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
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
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Beranda', onTap: () => Navigator.pop(context)),
        BottomNavItem(icon: Icons.notifications_outlined, label: 'Alert',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OpAlertScreen()))),
        BottomNavItem(icon: Icons.history, label: 'Riwayat',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OpHistoryScreen()))),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil', active: true, onTap: () {}),
      ]),
    );
  }
}