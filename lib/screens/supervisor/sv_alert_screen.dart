import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import 'sv_drift_screen.dart';
import 'sv_history_screen.dart';
import 'sv_profile_screen.dart';

class SvAlertScreen extends StatelessWidget {
  const SvAlertScreen({super.key});

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
            borderColor: AppColors.criticalBorder,
            titleColor: AppColors.redLight,
            meta: 'R-201 • 07:21 WIB • Confidence: 87% • Uncertainty: rendah',
            assignLabel: 'Assign ke Budi',
            assignBg: const Color(0xFF1A3A6A), assignFg: AppColors.blue,
            actionLabel: 'Eskalasi',
            actionBg: const Color(0xFF2D1414), actionFg: AppColors.red,
          ),
          const SizedBox(height: 12),
          _alertCard(
            title: 'Fault 11 — Feed Stream Loss',
            badge: StatusBadge.yellow('Warning'),
            borderColor: const Color(0xFF3D3015),
            titleColor: AppColors.yellowLight,
            meta: 'SEP-102 • 06:49 WIB • Confidence: 61% • Uncertainty: sedang',
            assignLabel: 'Assign ke Rina',
            assignBg: const Color(0xFF1A3A6A), assignFg: AppColors.blue,
            actionLabel: 'Monitor',
            actionBg: const Color(0xFF292010), actionFg: AppColors.yellow,
          ),
          const SizedBox(height: 12),
          _alertCard(
            title: 'Fault 2 — B Comp. Ratio',
            badge: StatusBadge.yellow('Warning'),
            borderColor: const Color(0xFF3D3015),
            titleColor: AppColors.yellowLight,
            meta: 'COMP-301 • 06:23 WIB • Confidence: 48% • Uncertainty: tinggi',
            assignLabel: 'Assign ke Dodi',
            assignBg: const Color(0xFF1A3A6A), assignFg: AppColors.blue,
            actionLabel: 'Monitor',
            actionBg: const Color(0xFF292010), actionFg: AppColors.yellow,
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
        Text('Manajemen Alert', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 3),
        Text('3 critical • 2 warning • Semua unit', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _alertCard({
    required String title, required Widget badge, required Color borderColor,
    required Color titleColor, required String meta,
    required String assignLabel, required Color assignBg, required Color assignFg,
    required String actionLabel, required Color actionBg, required Color actionFg,
  }) {
    return AppCard(
      borderColor: borderColor,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(title, style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.w500))),
          badge,
        ]),
        const SizedBox(height: 6),
        Text(meta, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _actionBtn(assignLabel, assignBg, assignFg)),
          const SizedBox(width: 8),
          Expanded(child: _actionBtn(actionLabel, actionBg, actionFg)),
          const SizedBox(width: 8),
          Expanded(child: _actionBtn('Acknowledge', const Color(0xFF0F2A1A), AppColors.green)),
        ]),
      ]),
    );
  }

  Widget _actionBtn(String label, Color bg, Color fg) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: bg, foregroundColor: fg, elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      color: AppColors.navBg,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Beranda', onTap: () => Navigator.pop(context)),
        BottomNavItem(icon: Icons.notifications_outlined, label: 'Alert', active: true, onTap: () {}),
        BottomNavItem(icon: Icons.show_chart, label: 'Data Drift',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SvDriftScreen()))),
        BottomNavItem(icon: Icons.history, label: 'Riwayat',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SvHistoryScreen()))),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SvProfileScreen()))),
      ]),
    );
  }
}