import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import 'op_alert_screen.dart';
import 'op_profile_screen.dart';

class OpHistoryScreen extends StatelessWidget {
  const OpHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        _header(),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          // Filter chips
          Row(children: [
            _chip('Hari ini', active: true),
            const SizedBox(width: 8),
            _chip('7 hari'),
            const SizedBox(width: 8),
            _chip('30 hari'),
          ]),
          const SizedBox(height: 12),
          // Fault list
          AppCard(child: Column(children: [
            _faultRow('Fault 4 — Reactor Cooling', 'Mulai: 07:21 • Durasi: 14 mnt (ongoing)',
                AppColors.redLight, StatusBadge.red('Aktif'), true),
            const Divider(height: 1, color: AppColors.border),
            _faultRow('Fault 7 — Header Pressure', '05:10 – 06:02 • Durasi: 52 mnt',
                AppColors.yellowLight, StatusBadge.green('Resolved'), false),
            const Divider(height: 1, color: AppColors.border),
            _faultRow('Fault 3 — D Feed Temp', '03:44 – 04:11 • Durasi: 27 mnt',
                AppColors.yellowLight, StatusBadge.green('Resolved'), false),
            const Divider(height: 1, color: AppColors.border),
            _faultRow('Fault 14 — Reactor Cooling', '01:05 – 01:59 • Durasi: 54 mnt',
                AppColors.textMuted, StatusBadge.green('Resolved'), false),
          ])),
          const SizedBox(height: 12),
          // Summary
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionLabel('Ringkasan shift ini'),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.8,
                children: [
                  _statBox('4', 'Total anomaly', AppColors.red),
                  _statBox('3', 'Resolved', AppColors.green),
                  _statBox('44m', 'Avg durasi', AppColors.textPrimary),
                  _statBox('2.1m', 'Avg deteksi', AppColors.blue),
                ],
              ),
            ]),
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
        Text('Riwayat Anomaly', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 3),
        Text('Shift ini • 15 Apr 2026', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
      child: Text(label,
          style: TextStyle(color: active ? AppColors.blue : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Widget _faultRow(String title, String meta, Color titleColor, Widget badge, bool divider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.w500)),
          badge,
        ]),
        const SizedBox(height: 4),
        Text(meta, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ]),
    );
  }

  Widget _statBox(String value, String label, Color valueColor) {
    return Container(
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
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
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OpAlertScreen()))),
        BottomNavItem(icon: Icons.history, label: 'Riwayat', active: true, onTap: () {}),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OpProfileScreen()))),
      ]),
    );
  }
}