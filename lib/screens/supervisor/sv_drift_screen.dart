import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import '../../services/api_service.dart';
import 'sv_alert_screen.dart';
import 'sv_history_screen.dart';
import 'sv_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SvDriftScreen extends StatefulWidget {
  const SvDriftScreen({super.key});
  @override
  State<SvDriftScreen> createState() => _SvDriftScreenState();
}

class _SvDriftScreenState extends State<SvDriftScreen> {
  Map<String, dynamic>? _drift;
  bool _loading = true;
  String _period = 'live';

  @override
  void initState() {
    super.initState();
    _loadDrift();
  }

  Future<void> _loadDrift() async {
    setState(() => _loading = true);
    try {
      final headers = await ApiService.authHeaders();
      final res = await http.get(
        Uri.parse("${ApiService.baseUrl}/drift/status?period=$_period"),
        headers: headers,
      );
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _drift = jsonDecode(res.body);
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final variables = (_drift?['variables'] as List?) ?? [];
    final totalHigh = _drift?['total_high'] ?? 4;
    final totalMed = _drift?['total_medium'] ?? 9;
    final totalNorm = _drift?['total_normal'] ?? 39;
    final retrain =
        _drift?['retraining_recommended'] == true ? 'Disarankan' : 'Monitor';
    final retrainColor = _drift?['retraining_recommended'] == true
        ? AppColors.red
        : AppColors.yellow;
    final lastRetrain = _drift?['last_retrain_days_ago'];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
          child: Column(children: [
        _header(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDrift,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              // Period chips
              Row(children: [
                _chip('Live', 'live'),
                const SizedBox(width: 8),
                _chip('1 Jam', '1h'),
                const SizedBox(width: 8),
                _chip('24 Jam', '24h'),
              ]),
              const SizedBox(height: 12),

              // Variable list
              const SectionLabel('Status drift per variabel (top anomali)'),
              const SizedBox(height: 6),
              _loading
                  ? const Center(
                      child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator()))
                  : variables.isEmpty
                      ? AppCard(
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                              child: Text(
                            'Belum ada data drift tersedia',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          )))
                      : AppCard(
                          child: Column(
                          children: variables.asMap().entries.map((e) {
                            final i = e.key;
                            final v = e.value;
                            final ks = (v['ks_statistic'] ?? 0.0).toDouble();
                            final psi = (v['psi_score'] ?? 0.0).toDouble();
                            final pval = (v['ks_pvalue'] ?? 0.0).toDouble();
                            final level = v['drift_level'] ?? 'none';

                            Widget badge;
                            Color barColor;
                            if (level == 'high') {
                              badge = StatusBadge.red('High drift');
                              barColor = AppColors.red;
                            } else if (level == 'medium') {
                              badge = StatusBadge.yellow('Med drift');
                              barColor = AppColors.yellow;
                            } else {
                              badge = StatusBadge.green('No drift');
                              barColor = AppColors.green;
                            }

                            return Column(children: [
                              if (i > 0)
                                const Divider(
                                    height: 1, color: AppColors.border),
                              _driftRow(
                                v['variable_name'] ?? '-',
                                badge,
                                ks,
                                barColor,
                                'KS: ${ks.toStringAsFixed(2)} '
                                    '(p=${pval.toStringAsFixed(3)})',
                                'PSI: ${psi.toStringAsFixed(2)}',
                              ),
                            ]);
                          }).toList(),
                        )),
              const SizedBox(height: 12),

              // Summary card
              AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Ringkasan 52 variabel'),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                            child: _summaryBox('$totalHigh', 'High drift',
                                AppColors.red, const Color(0xFF2D1414))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _summaryBox('$totalMed', 'Med drift',
                                AppColors.yellow, const Color(0xFF292010))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _summaryBox('$totalNorm', 'Normal',
                                AppColors.green, const Color(0xFF0F2A1A))),
                      ]),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Model retraining recommended?',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                Text(retrain,
                                    style: TextStyle(
                                        color: retrainColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ]),
                          const SizedBox(height: 6),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Last retrain',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                Text(
                                  lastRetrain != null
                                      ? '$lastRetrain hari lalu'
                                      : 'Belum ada data',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12),
                                ),
                              ]),
                        ]),
                      ),
                    ],
                  )),
            ]),
          ),
        ),
        _bottomNav(context),
      ])),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('Data Drift Monitor',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 3),
        Text('Input vs baseline training distribution',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _chip(String label, String period) {
    final active = _period == period;
    return GestureDetector(
      onTap: () {
        if (_period == period) return;
        setState(() => _period = period);
        _loadDrift();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A3A6A) : AppColors.surface,
          border: Border.all(color: active ? AppColors.blue : AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? AppColors.blue : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _driftRow(String label, Widget badge, double val, Color barColor,
      String ks, String psi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 12))),
          badge,
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: val.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
              width: 30,
              child: Text(val.toStringAsFixed(2),
                  style: TextStyle(color: barColor, fontSize: 10))),
        ]),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(ks,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
          Text(psi,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ]),
      ]),
    );
  }

  Widget _summaryBox(String val, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: Column(children: [
        Text(val,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w500)),
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
        BottomNavItem(
            icon: Icons.grid_view_rounded,
            label: 'Beranda',
            onTap: () => Navigator.pop(context)),
        BottomNavItem(
            icon: Icons.notifications_outlined,
            label: 'Alert',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SvAlertScreen()))),
        BottomNavItem(
            icon: Icons.show_chart,
            label: 'Data Drift',
            active: true,
            onTap: () {}),
        BottomNavItem(
            icon: Icons.history,
            label: 'Riwayat',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SvHistoryScreen()))),
        BottomNavItem(
            icon: Icons.person_outline,
            label: 'Profil',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SvProfileScreen()))),
      ]),
    );
  }
}
