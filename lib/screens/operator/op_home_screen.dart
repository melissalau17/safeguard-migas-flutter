import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import '../../services/api_service.dart';
import 'op_alert_screen.dart';
import 'op_history_screen.dart';
import 'op_profile_screen.dart';

class OpHomeScreen extends StatefulWidget {
  const OpHomeScreen({super.key});
  @override
  State<OpHomeScreen> createState() => _OpHomeScreenState();
}

class _OpHomeScreenState extends State<OpHomeScreen> {
  Map<String, dynamic>? _dashboard;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await ApiService.getDashboard();
      if (mounted) setState(() { _dashboard = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
    // Polling setiap 10 detik
    await Future.delayed(const Duration(seconds: 10));
    if (mounted) _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dari API, fallback ke dummy kalau null
    final risk      = _dashboard?['global_risk'];
    final status    = risk?['status'] ?? 'CRITICAL';
    final confidence = ((risk?['confidence'] ?? 0.87) * 100).toStringAsFixed(0);
    final faults    = (_dashboard?['top_faults'] as List?) ?? _dummyFaults;
    final variables = (_dashboard?['top_variables'] as List?) ?? _dummyVars;

    // Warna berdasarkan status
    Color statusColor;
    Color statusBg;
    Color statusBorder;
    switch (status.toString().toUpperCase()) {
      case 'NORMAL':
        statusColor = AppColors.green;
        statusBg    = const Color(0xFF0D2010);
        statusBorder = const Color(0xFF1A4020);
        break;
      case 'WARNING':
        statusColor = AppColors.yellow;
        statusBg    = const Color(0xFF201A00);
        statusBorder = const Color(0xFF403200);
        break;
      default:
        statusColor = AppColors.redLight;
        statusBg    = AppColors.criticalBg;
        statusBorder = AppColors.criticalBorder;
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('OPERATOR',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(_dashboard?['operator_name'] ?? 'Operator',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
                ]),
                const UserAvatar(initials: 'OP', bg: Color(0xFF1A3A6A), fg: AppColors.blue),
              ]),
              const SizedBox(height: 8),
              Row(children: const [
                CircleAvatar(radius: 3.5, backgroundColor: AppColors.green),
                SizedBox(width: 5),
                Text('Shift Pagi — R-201 Reaktor',
                    style: TextStyle(color: AppColors.green, fontSize: 11)),
              ]),
            ]),
          ),
          // Body
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => _loadDashboard(),
                    child: ListView(padding: const EdgeInsets.all(16), children: [
                      // Risk card
                      AppCard(
                        borderColor: statusBorder,
                        backgroundColor: statusBg,
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('STATUS RISIKO GLOBAL',
                                  style: TextStyle(color: statusColor, fontSize: 10, letterSpacing: 0.6)),
                              const SizedBox(height: 4),
                              Text(status.toString().toUpperCase(),
                                  style: TextStyle(color: statusColor, fontSize: 26, fontWeight: FontWeight.w500)),
                            ]),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: statusBorder, borderRadius: BorderRadius.circular(10)),
                              child: Column(children: [
                                Text('$confidence%',
                                    style: TextStyle(color: statusColor, fontSize: 20, fontWeight: FontWeight.w500)),
                                Text('confidence',
                                    style: TextStyle(color: statusColor.withValues(alpha: 0.7), fontSize: 10)),
                              ]),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                                color: statusBorder.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              '${faults.length} anomaly aktif',
                              style: TextStyle(color: statusColor, fontSize: 12),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      // Top anomaly
                      const SectionLabel('Top anomaly class'),
                      const SizedBox(height: 6),
                      AppCard(
                        child: Column(
                          children: faults.asMap().entries.map((e) {
                            final i = e.key;
                            final f = e.value;
                            final prob = (f['probability'] ?? f['confidence'] ?? 0.0).toDouble();
                            final color = prob >= 0.7 ? AppColors.red : AppColors.yellow;
                            final badge = prob >= 0.7
                                ? StatusBadge.red('${(prob * 100).toStringAsFixed(0)}%')
                                : StatusBadge.yellow('${(prob * 100).toStringAsFixed(0)}%');
                            return Column(children: [
                              if (i > 0) const Divider(height: 1, color: AppColors.border),
                              _anomalyRow(
                                f['fault_label'] ?? f['predicted_label'] ?? 'Unknown',
                                prob, color, badge,
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Causal variables
                      const SectionLabel('Variabel penyebab global (top 5)'),
                      const SizedBox(height: 6),
                      AppCard(
                        child: Column(
                          children: variables.asMap().entries.map((e) {
                            final i = e.key;
                            final v = e.value;
                            final sigma = (v['sigma_deviation'] ?? 0.0).toDouble();
                            final color = sigma.abs() >= 2.0
                                ? AppColors.red
                                : sigma.abs() >= 1.0
                                    ? AppColors.yellow
                                    : AppColors.green;
                            return Column(children: [
                              if (i > 0) const Divider(height: 1, color: AppColors.border),
                              _causalRow(
                                '${v['code'] ?? ''} — ${v['name'] ?? ''}',
                                '${sigma >= 0 ? '+' : ''}${sigma.toStringAsFixed(1)}σ',
                                color,
                                (sigma.abs() / 4).clamp(0.0, 1.0),
                                '${v['value'] ?? ''} ${v['unit'] ?? ''}',
                                'Normal: ${v['normal_range'] ?? ''}',
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ]),
                  ),
          ),
          _bottomNav(context, 'home'),
        ]),
      ),
    );
  }

  // Dummy fallback data
  final _dummyFaults = [
    {'fault_label': 'Fault 4 — Reactor Cooling', 'probability': 0.87},
    {'fault_label': 'Fault 11 — Feed Loss',       'probability': 0.61},
    {'fault_label': 'Fault 2 — B Comp. Ratio',    'probability': 0.48},
  ];

  final _dummyVars = [
    {'code': 'XMEAS(9)',  'name': 'Reactor Temp',    'sigma_deviation': 3.4, 'value': '153.2', 'unit': '°C',    'normal_range': '120–140'},
    {'code': 'XMEAS(7)',  'name': 'Reactor Press',   'sigma_deviation': 2.1, 'value': '2847',  'unit': 'kPa',   'normal_range': '2600–2800'},
    {'code': 'XMEAS(12)', 'name': 'Cooling Water',   'sigma_deviation': 1.8, 'value': '18.4',  'unit': 'm³/h',  'normal_range': '22–28'},
    {'code': 'XMEAS(1)',  'name': 'A Feed Flow',     'sigma_deviation': 0.9, 'value': '0.255', 'unit': 'kscmh', 'normal_range': '0.20–0.26'},
    {'code': 'XMEAS(22)', 'name': 'Sep Level',       'sigma_deviation': 0.7, 'value': '52.1',  'unit': '%',     'normal_range': '45–55'},
  ];

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
          child: LinearProgressIndicator(
            value: val, minHeight: 5,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
      ]),
    );
  }

  Widget _causalRow(String label, String sigma, Color sigmaColor,
      double val, String current, String normal) {
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
          child: LinearProgressIndicator(
            value: val, minHeight: 5,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(sigmaColor),
          ),
        ),
        const SizedBox(height: 3),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(current, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          Text(normal,  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
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