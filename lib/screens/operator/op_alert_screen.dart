import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import 'op_history_screen.dart';
import 'op_profile_screen.dart';

class OpAlertScreen extends StatelessWidget {
  const OpAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        _header(),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          _alertCard(
            title: 'Fault 4 — Reactor Cooling High',
            badge: StatusBadge.red('Critical'),
            dotColor: AppColors.red,
            titleColor: AppColors.redLight,
            borderColor: AppColors.criticalBorder,
            meta: 'R-201 • 07:21 WIB • 14 mnt lalu',
            desc: 'Suhu reaktor melebihi batas atas. Cooling water flow turun drastis. Segera periksa valve cooling.',
            confidence: 'Confidence: 87%',
            confColor: AppColors.red,
            uncertainty: 'Uncertainty: rendah',
          ),
          const SizedBox(height: 12),
          _alertCard(
            title: 'Fault 11 — Feed Stream Loss',
            badge: StatusBadge.yellow('Warning'),
            dotColor: AppColors.yellow,
            titleColor: AppColors.yellowLight,
            borderColor: const Color(0xFF3D3015),
            meta: 'SEP-102 • 06:49 WIB • 46 mnt lalu',
            desc: 'Aliran feed stream B menunjukkan penurunan gradual. Monitor tekanan separator.',
            confidence: 'Confidence: 61%',
            confColor: AppColors.yellow,
            uncertainty: 'Uncertainty: sedang',
          ),
          const SizedBox(height: 12),
          _alertCard(
            title: 'Fault 2 — B Comp. Ratio',
            badge: StatusBadge.yellow('Warning'),
            dotColor: AppColors.yellow,
            titleColor: AppColors.yellowLight,
            borderColor: const Color(0xFF3D3015),
            meta: 'COMP-301 • 06:23 WIB • 1 jam lalu',
            desc: 'Rasio komposisi B di feed bergeser dari baseline. Pantau kondisi kompresor.',
            confidence: 'Confidence: 48%',
            confColor: AppColors.yellow,
            uncertainty: 'Uncertainty: tinggi',
          ),
          const SizedBox(height: 12),
          _alertCard(
            title: 'Fault 1 — A/C Feed Ratio',
            badge: StatusBadge.red('Critical'),
            dotColor: AppColors.red,
            titleColor: AppColors.redLight,
            borderColor: AppColors.border,
            meta: 'R-201 • 05:55 WIB • 1.8 jam lalu',
            desc: 'Rasio feed A/C menyimpang. Berkaitan dengan Fault 4 yang aktif.',
            confidence: 'Confidence: 79%',
            confColor: AppColors.red,
            uncertainty: 'Uncertainty: rendah',
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
        Text('Alert Aktif', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 3),
        Text('3 critical • 2 warning', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _alertCard({
    required String title, required Widget badge, required Color dotColor,
    required Color titleColor, required Color borderColor, required String meta,
    required String desc, required String confidence, required Color confColor, required String uncertainty,
  }) {
    return AppCard(
      borderColor: borderColor,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 3.5, backgroundColor: dotColor),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.w500))),
          badge,
        ]),
        const SizedBox(height: 8),
        Text(meta, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(confidence, style: TextStyle(color: confColor, fontSize: 11)),
          Text(uncertainty, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ]),
      ]),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      color: AppColors.navBg,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Beranda', onTap: () => Navigator.pop(context)),
        BottomNavItem(icon: Icons.notifications_outlined, label: 'Alert', active: true, onTap: () {}),
        BottomNavItem(icon: Icons.history, label: 'Riwayat',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OpHistoryScreen()))),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OpProfileScreen()))),
      ]),
    );
  }
}