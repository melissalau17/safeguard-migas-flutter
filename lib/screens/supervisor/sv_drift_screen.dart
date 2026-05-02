import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import 'sv_alert_screen.dart';
import 'sv_history_screen.dart';
import 'sv_profile_screen.dart';

class SvDriftScreen extends StatelessWidget {
  const SvDriftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        _header(),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          // Filter chips
          Row(children: [
            _chip('Live', active: true),
            const SizedBox(width: 8),
            _chip('1 jam'),
            const SizedBox(width: 8),
            _chip('24 jam'),
          ]),
          const SizedBox(height: 12),
          // Drift per variable
          const SectionLabel('Status drift per variabel (top anomali)'),
          const SizedBox(height: 6),
          AppCard(child: Column(children: [
            _driftRow('XMEAS(9) — Reactor Temp', StatusBadge.red('High drift'), 0.85, AppColors.red, 'KS stat: 0.85 (p<0.001)', 'PSI: 0.42', true),
            const Divider(height: 1, color: AppColors.border),
            _driftRow('XMEAS(7) — Reactor Press', StatusBadge.yellow('Med drift'), 0.58, AppColors.yellow, 'KS stat: 0.58 (p=0.01)', 'PSI: 0.18', true),
            const Divider(height: 1, color: AppColors.border),
            _driftRow('XMEAS(12) — Cooling Water', StatusBadge.yellow('Med drift'), 0.44, AppColors.yellow, 'KS stat: 0.44 (p=0.04)', 'PSI: 0.12', true),
            const Divider(height: 1, color: AppColors.border),
            _driftRow('XMEAS(1) — A Feed Flow', StatusBadge.green('No drift'), 0.12, AppColors.green, 'KS stat: 0.12 (p=0.61)', 'PSI: 0.03', false),
          ])),
          const SizedBox(height: 12),
          // Summary card
          AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionLabel('Ringkasan 52 variabel'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _summaryBox('4', 'High drift', AppColors.red, const Color(0xFF2D1414))),
              const SizedBox(width: 8),
              Expanded(child: _summaryBox('9', 'Med drift', AppColors.yellow, const Color(0xFF292010))),
              const SizedBox(width: 8),
              Expanded(child: _summaryBox('39', 'Normal', AppColors.green, const Color(0xFF0F2A1A))),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                  Text('Model retraining recommended?', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text('Monitor', style: TextStyle(color: AppColors.yellow, fontSize: 12, fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                  Text('Last retrain', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text('12 hari lalu', style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                ]),
              ]),
            ),
          ])),
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
        Text('Data Drift Monitor', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 3),
        Text('Input vs baseline training distribution', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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

  Widget _driftRow(String label, Widget badge, double val, Color barColor, String ks, String psi, bool divider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
          badge,
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: val, minHeight: 8,
                  backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(barColor)),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(width: 28, child: Text(val.toStringAsFixed(2), style: TextStyle(color: barColor, fontSize: 10))),
        ]),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(ks, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          Text(psi, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ]),
      ]),
    );
  }

  Widget _summaryBox(String val, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: Column(children: [
        Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: color, fontSize: 10)),
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
        BottomNavItem(icon: Icons.show_chart, label: 'Data Drift', active: true, onTap: () {}),
        BottomNavItem(icon: Icons.history, label: 'Riwayat',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SvHistoryScreen()))),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil',
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SvProfileScreen()))),
      ]),
    );
  }
}