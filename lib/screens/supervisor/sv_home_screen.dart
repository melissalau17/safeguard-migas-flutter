import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import 'sv_alert_screen.dart';
import 'sv_drift_screen.dart';
import 'sv_history_screen.dart';
import 'sv_profile_screen.dart';

class SvHomeScreen extends StatelessWidget {
  const SvHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        _header(),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          // Global status
          AppCard(
            borderColor: AppColors.criticalBorder,
            backgroundColor: AppColors.criticalBg,
            padding: const EdgeInsets.all(14),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('STATUS GLOBAL', style: TextStyle(color: AppColors.red, fontSize: 10, letterSpacing: 0.6)),
                SizedBox(height: 4),
                Text('CRITICAL', style: TextStyle(color: AppColors.redLight, fontSize: 22, fontWeight: FontWeight.w500)),
              ]),
              Row(children: [
                _miniStatBox('3', 'critical', AppColors.red, const Color(0xFF2D1414)),
                const SizedBox(width: 8),
                _miniStatBox('2', 'warning', AppColors.yellow, const Color(0xFF292010)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          // Model performance
          const SectionLabel('Model performance (live sim)'),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.6,
            children: [
              _perfBox('94.2%', 'Accuracy (test set)', AppColors.green),
              _perfBox('91.8%', 'Precision avg', AppColors.blue),
              _perfBox('89.5%', 'Recall avg', AppColors.purple),
              _perfBox('38ms', 'Inference latency', AppColors.textPrimary),
            ],
          ),
          const SizedBox(height: 8),
          AppCard(padding: const EdgeInsets.all(12), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
              Text('Model uncertainty (avg)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('Sedang', style: TextStyle(color: AppColors.yellow, fontSize: 12, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
              Text('Fault class terendah recall', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('Fault 19 — 71%', style: TextStyle(color: AppColors.red, fontSize: 12)),
            ]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
              Text('Avg detection latency', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('2.1 menit', style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
            ]),
          ])),
          const SizedBox(height: 12),
          // Workers
          const SectionLabel('Pekerja on-place (shift pagi)'),
          const SizedBox(height: 6),
          AppCard(child: Column(children: [
            _workerRow('BS', 'Budi Santoso', 'R-201 Reaktor • OP-20241', StatusBadge.red('Alert aktif'), true),
            const Divider(height: 1, color: AppColors.border),
            _workerRow('RH', 'Rina Hartati', 'SEP-102 Separator • OP-20198', StatusBadge.yellow('Warning'), true),
            const Divider(height: 1, color: AppColors.border),
            _workerRow('DK', 'Dodi Kurniawan', 'COMP-301 Kompresor • OP-20205', StatusBadge.green('Normal'), true),
            const Divider(height: 1, color: AppColors.border),
            _workerRow('SP', 'Sari Puspita', 'STR-401 Stripper • OP-20217', StatusBadge.green('Normal'), false),
          ])),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A6A), foregroundColor: AppColors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Broadcast Alert ke Semua Operator ↗',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ),
        ])),
        _bottomNav(context, 'home'),
      ])),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('SUPERVISOR', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 0.5)),
            SizedBox(height: 2),
            Text('Andi Wijaya', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
          ]),
          const UserAvatar(initials: 'AW', bg: Color(0xFF2A1A5A), fg: AppColors.purple),
        ]),
        const SizedBox(height: 8),
        Row(children: const [
          CircleAvatar(radius: 3.5, backgroundColor: AppColors.green),
          SizedBox(width: 5),
          Text('Semua unit • Shift Pagi', style: TextStyle(color: AppColors.green, fontSize: 11)),
        ]),
      ]),
    );
  }

  Widget _miniStatBox(String val, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(val, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500)),
        Text(label, style: TextStyle(color: color, fontSize: 9)),
      ]),
    );
  }

  Widget _perfBox(String val, String label, Color color) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ]),
    );
  }

  Widget _workerRow(String initials, String name, String meta, Widget badge, bool divider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        UserAvatar(initials: initials, bg: const Color(0xFF1A3A6A), fg: AppColors.blue),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            badge,
          ]),
          const SizedBox(height: 2),
          Text(meta, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ])),
      ]),
    );
  }

  Widget _bottomNav(BuildContext context, String active) {
    return Container(
      color: AppColors.navBg,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Beranda', active: active == 'home', onTap: () {}),
        BottomNavItem(icon: Icons.notifications_outlined, label: 'Alert', showDot: true,
            active: active == 'alert',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SvAlertScreen()))),
        BottomNavItem(icon: Icons.show_chart, label: 'Data Drift', active: active == 'drift',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SvDriftScreen()))),
        BottomNavItem(icon: Icons.history, label: 'Riwayat', active: active == 'history',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SvHistoryScreen()))),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil', active: active == 'profile',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SvProfileScreen()))),
      ]),
    );
  }
}