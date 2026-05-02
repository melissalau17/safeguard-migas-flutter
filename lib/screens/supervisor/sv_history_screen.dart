import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import 'sv_alert_screen.dart';
import 'sv_drift_screen.dart';
import 'sv_profile_screen.dart';

class SvHistoryScreen extends StatelessWidget {
  const SvHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        _header(),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            _chip('Hari ini', active: true),
            const SizedBox(width: 8),
            _chip('7 hari'),
            const SizedBox(width: 8),
            _chip('30 hari'),
          ]),
          const SizedBox(height: 12),
          AppCard(child: Column(children: [
            _faultRow('Fault 4 — Reactor Cooling', 'R-201 • Budi S. • 07:21–sekarang', AppColors.redLight, StatusBadge.red('Aktif'), true),
            const Divider(height: 1, color: AppColors.border),
            _faultRow('Fault 7 — Header Pressure', 'R-201 • Budi S. • 05:10–06:02', AppColors.textMuted, StatusBadge.green('Resolved'), true),
            const Divider(height: 1, color: AppColors.border),
            _faultRow('Fault 3 — D Feed Temp', 'SEP-102 • Rina H. • 03:44–04:11', AppColors.textMuted, StatusBadge.green('Resolved'), true),
            const Divider(height: 1, color: AppColors.border),
            _faultRow('Fault 14 — Reactor Cooling', 'R-201 • Budi S. • 01:05–01:59', AppColors.textMuted, StatusBadge.green('Resolved'), false),
          ])),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.8,
            children: [
              _statBox('7', 'Anomaly hari ini', AppColors.red),
              _statBox('6', 'Resolved', AppColors.green),
              _statBox('38m', 'Avg durasi', AppColors.textPrimary),
              _statBox('R-201', 'Unit tertinggi', AppColors.purple),
            ],
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('Riwayat — Semua Unit', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 3),
        Text('15 Apr 2026 • Shift Pagi', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _chip(String label, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1A3A6A) : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: active ? AppColors.blue : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Widget _faultRow(String title, String meta, Color titleColor, Widget badge, bool divider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(title, style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.w500))),
          badge,
        ]),
        const SizedBox(height: 2),
        Text(meta, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ]),
    );
  }

  Widget _statBox(String value, String label, Color valueColor) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
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
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SvAlertScreen()))),
        BottomNavItem(icon: Icons.show_chart, label: 'Data Drift',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SvDriftScreen()))),
        BottomNavItem(icon: Icons.history, label: 'Riwayat', active: true, onTap: () {}),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SvProfileScreen()))),
      ]),
    );
  }
}