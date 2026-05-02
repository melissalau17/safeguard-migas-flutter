import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import 'op_alert_screen.dart';
import 'op_history_screen.dart';
import 'op_profile_screen.dart';

class OpHomeScreen extends StatelessWidget {
  const OpHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('OPERATOR', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 0.5)),
                  SizedBox(height: 2),
                  Text('Budi Santoso', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
                ]),
                const UserAvatar(initials: 'BS', bg: Color(0xFF1A3A6A), fg: AppColors.blue),
              ]),
              const SizedBox(height: 8),
              Row(children: const [
                CircleAvatar(radius: 3.5, backgroundColor: AppColors.green),
                SizedBox(width: 5),
                Text('Shift Pagi — R-201 Reaktor', style: TextStyle(color: AppColors.green, fontSize: 11)),
              ]),
            ]),
          ),
          // Scrollable body
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              // Critical card
              AppCard(
                borderColor: AppColors.criticalBorder,
                backgroundColor: AppColors.criticalBg,
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('STATUS RISIKO GLOBAL', style: TextStyle(color: AppColors.red, fontSize: 10, letterSpacing: 0.6)),
                      SizedBox(height: 4),
                      Text('CRITICAL', style: TextStyle(color: AppColors.redLight, fontSize: 26, fontWeight: FontWeight.w500)),
                    ]),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.criticalBorder, borderRadius: BorderRadius.circular(10)),
                      child: Column(children: const [
                        Text('87%', style: TextStyle(color: AppColors.redLight, fontSize: 20, fontWeight: FontWeight.w500)),
                        Text('confidence', style: TextStyle(color: AppColors.red, fontSize: 10)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.criticalInner, borderRadius: BorderRadius.circular(8)),
                    child: const Text('3 anomaly aktif • Terdeteksi 14 mnt lalu',
                        style: TextStyle(color: AppColors.redLight, fontSize: 12)),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              // Top anomaly
              const SectionLabel('Top anomaly class'),
              const SizedBox(height: 6),
              AppCard(child: Column(children: [
                _anomalyRow('Fault 4 — Reactor Cooling', 0.87, AppColors.red, StatusBadge.red('87%')),
                const Divider(height: 1, color: AppColors.border),
                _anomalyRow('Fault 11 — Feed Loss', 0.61, AppColors.yellow, StatusBadge.yellow('61%')),
                const Divider(height: 1, color: AppColors.border),
                _anomalyRow('Fault 2 — B Comp. Ratio', 0.48, AppColors.yellow, StatusBadge.yellow('48%')),
              ])),
              const SizedBox(height: 12),
              // Causal variables
              const SectionLabel('Variabel penyebab global (top 5)'),
              const SizedBox(height: 6),
              AppCard(child: Column(children: [
                _causalRow('XMEAS(9) — Reactor Temp', '+3.4σ', AppColors.red, 0.92, '153.2 °C', 'Normal: 120–140'),
                const Divider(height: 1, color: AppColors.border),
                _causalRow('XMEAS(7) — Reactor Press', '+2.1σ', AppColors.yellow, 0.65, '2847 kPa', 'Normal: 2600–2800'),
                const Divider(height: 1, color: AppColors.border),
                _causalRow('XMEAS(12) — Cooling Water', '+1.8σ', AppColors.yellow, 0.52, '18.4 m³/h', 'Normal: 22–28'),
                const Divider(height: 1, color: AppColors.border),
                _causalRow('XMEAS(1) — A Feed Flow', '+0.9σ', AppColors.green, 0.28, '0.255 kscmh', 'Normal: 0.20–0.26'),
                const Divider(height: 1, color: AppColors.border),
                _causalRow('XMEAS(22) — Sep Level', '+0.7σ', AppColors.green, 0.20, '52.1%', 'Normal: 45–55'),
              ])),
            ]),
          ),
          // Bottom nav
          _bottomNav(context, 'home'),
        ]),
      ),
    );
  }

  Widget _anomalyRow(String label, double val, Color barColor, Widget badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          badge,
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: val, minHeight: 5,
              backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(barColor)),
        ),
      ]),
    );
  }

  Widget _causalRow(String label, String sigma, Color sigmaColor, double val, String current, String normal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
          Text(sigma, style: TextStyle(color: sigmaColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: val, minHeight: 5,
              backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(sigmaColor)),
        ),
        const SizedBox(height: 3),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(current, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          Text(normal, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ]),
      ]),
    );
  }

  Widget _bottomNav(BuildContext context, String active) {
    return Container(
      color: AppColors.navBg,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Beranda', active: active == 'home', onTap: () {}),
        BottomNavItem(icon: Icons.notifications_outlined, label: 'Alert', active: active == 'alert', showDot: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OpAlertScreen()))),
        BottomNavItem(icon: Icons.history, label: 'Riwayat', active: active == 'history',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OpHistoryScreen()))),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil', active: active == 'profile',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OpProfileScreen()))),
      ]),
    );
  }
}