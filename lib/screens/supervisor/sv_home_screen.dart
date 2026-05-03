import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import '../../services/api_service.dart';
import 'sv_alert_screen.dart';
import 'sv_drift_screen.dart';
import 'sv_history_screen.dart';
import 'sv_profile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SvHomeScreen extends StatefulWidget {
  const SvHomeScreen({super.key});
  @override
  State<SvHomeScreen> createState() => _SvHomeScreenState();
}

class _SvHomeScreenState extends State<SvHomeScreen> {
  Map<String, dynamic>? _dashboard;
  Map<String, dynamic>? _metrics;
  bool _loading = true;
  String _supervisorName = '';
  String _initials = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadDashboard(), _loadProfile(), _loadMetrics()]);
  }

  Future<void> _loadProfile() async {
    final prefs = await ApiService.getPrefs();
    final name = prefs.getString('name') ?? 'Supervisor';
    if (mounted) setState(() {
      _supervisorName = name;
      _initials = name.trim().split(' ').take(2)
          .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
    });
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await ApiService.getDashboard();
      if (mounted) setState(() { _dashboard = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
    await Future.delayed(const Duration(seconds: 10));
    if (mounted) _loadDashboard();
  }

  Future<void> _loadMetrics() async {
    try {
      final headers = await ApiService.authHeaders();
      final res = await http.get(
        Uri.parse("${ApiService.baseUrl}/metrics/performance"),
        headers: headers,
      );
      if (res.statusCode == 200 && mounted) {
        setState(() => _metrics = jsonDecode(res.body));
      }
    } catch (_) {}
    await Future.delayed(const Duration(seconds: 10));
    if (mounted) _loadMetrics();
  }

  Future<void> _sendBroadcast() async {
    final headers = await ApiService.authHeaders();
    final res = await http.post(
      Uri.parse("${ApiService.baseUrl}/alerts/broadcast"),
      headers: headers,
      body: jsonEncode({
        "message": "Perhatian: anomali critical aktif. Tingkatkan kewaspadaan.",
        "severity": "critical",
      }),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res.statusCode == 204
          ? 'Broadcast terkirim ke semua operator ✓'
          : 'Gagal mengirim broadcast'),
    ));
  }

  String _fmt(dynamic val, String suffix, {int decimals = 1}) {
    if (val == null) return '—';
    return '${(val as num).toStringAsFixed(decimals)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final risk     = _dashboard?['global_risk'];
    final status   = (risk?['status'] ?? 'CRITICAL').toString().toUpperCase();
    final alerts   = (_dashboard?['active_alerts'] as List?) ?? [];
    final critical = alerts.where((a) => a['severity'] == 'critical').length;
    final warning  = alerts.where((a) => a['severity'] == 'warning').length;

    Color statusColor, statusBg, statusBorder;
    switch (status) {
      case 'NORMAL':
        statusColor  = AppColors.green;
        statusBg     = const Color(0xFF0D2010);
        statusBorder = const Color(0xFF1A4020);
        break;
      case 'WARNING':
        statusColor  = AppColors.yellow;
        statusBg     = const Color(0xFF201A00);
        statusBorder = const Color(0xFF403200);
        break;
      default:
        statusColor  = AppColors.redLight;
        statusBg     = AppColors.criticalBg;
        statusBorder = AppColors.criticalBorder;
    }

    // Metrics values
    final accuracy  = _fmt(_metrics?['accuracy'],         '%', decimals: 1) == '—'
        ? '—' : '${((_metrics!['accuracy'] as num)*100).toStringAsFixed(1)}%';
    final precision = _metrics == null ? '—'
        : '${((_metrics!['precision_avg'] as num)*100).toStringAsFixed(1)}%';
    final recall    = _metrics == null ? '—'
        : '${((_metrics!['recall_avg'] as num)*100).toStringAsFixed(1)}%';
    final latency   = _metrics == null ? '—'
        : '${_metrics!['inference_latency_ms']}ms';
    final uncertainty = _metrics?['last_uncertainty'] ?? '—';
    final alertsToday = _metrics?['total_alerts_today']?.toString() ?? '—';
    final resolvedToday = _metrics?['resolved_today']?.toString() ?? '—';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        _header(),
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadAll,
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  // Global status
                  AppCard(
                    borderColor: statusBorder,
                    backgroundColor: statusBg,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('STATUS GLOBAL', style: TextStyle(
                              color: statusColor, fontSize: 10, letterSpacing: 0.6)),
                          const SizedBox(height: 4),
                          Text(status, style: TextStyle(
                              color: statusColor, fontSize: 22,
                              fontWeight: FontWeight.w500)),
                        ]),
                        Row(children: [
                          _miniStatBox('$critical', 'critical', AppColors.red,
                              const Color(0xFF2D1414)),
                          const SizedBox(width: 8),
                          _miniStatBox('$warning', 'warning', AppColors.yellow,
                              const Color(0xFF292010)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Model performance — dari API
                  const SectionLabel('Model performance (live sim)'),
                  const SizedBox(height: 6),
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.6,
                    children: [
                      _perfBox(accuracy,  'Accuracy (test set)', AppColors.green),
                      _perfBox(precision, 'Precision avg',       AppColors.blue),
                      _perfBox(recall,    'Recall avg',          AppColors.purple),
                      _perfBox(latency,   'Inference latency',   AppColors.textPrimary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppCard(padding: const EdgeInsets.all(12), child: Column(children: [
                    _metaRow('Model uncertainty (avg)', uncertainty,
                        uncertainty == 'rendah' ? AppColors.green
                        : uncertainty == 'sedang' ? AppColors.yellow
                        : AppColors.red),
                    const SizedBox(height: 6),
                    _metaRow('Alert terdeteksi hari ini', alertsToday, AppColors.textPrimary),
                    const SizedBox(height: 6),
                    _metaRow('Alert resolved hari ini', resolvedToday, AppColors.green),
                  ])),
                  const SizedBox(height: 12),

                  // Active alerts
                  const SectionLabel('Alert aktif saat ini'),
                  const SizedBox(height: 6),
                  alerts.isEmpty
                    ? AppCard(padding: const EdgeInsets.all(14),
                        child: const Center(child: Text('Tidak ada alert aktif',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12))))
                    : AppCard(child: Column(
                        children: alerts.asMap().entries.map((e) {
                          final i = e.key;
                          final a = e.value;
                          final isCritical = a['severity'] == 'critical';
                          return Column(children: [
                            if (i > 0) const Divider(height: 1, color: AppColors.border),
                            _alertRow(
                              a['fault_label'] ?? 'Unknown',
                              '${a['unit']} • ${a['assigned_user']?['name'] ?? 'Unassigned'}',
                              isCritical ? StatusBadge.red('Critical') : StatusBadge.yellow('Warning'),
                            ),
                          ]);
                        }).toList(),
                      )),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sendBroadcast,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A6A),
                        foregroundColor: AppColors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Broadcast Alert ke Semua Operator ↗',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ]),
              ),
        ),
        _bottomNav(context, 'home'),
      ])),
    );
  }

  Widget _metaRow(String label, String value, Color valueColor) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      Text(value, style: TextStyle(color: valueColor, fontSize: 12, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('SUPERVISOR', style: TextStyle(
                color: AppColors.textSecondary, fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(_supervisorName.isNotEmpty ? _supervisorName : 'Supervisor',
                style: const TextStyle(color: AppColors.textPrimary,
                    fontSize: 15, fontWeight: FontWeight.w500)),
          ]),
          UserAvatar(
            initials: _initials.isNotEmpty ? _initials : 'SV',
            bg: const Color(0xFF2A1A5A),
            fg: AppColors.purple,
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: const [
          CircleAvatar(radius: 3.5, backgroundColor: AppColors.green),
          SizedBox(width: 5),
          Text('Semua unit • Shift Pagi',
              style: TextStyle(color: AppColors.green, fontSize: 11)),
        ]),
      ]),
    );
  }

  Widget _alertRow(String title, String meta, Widget badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(title, style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 13))),
            badge,
          ]),
          const SizedBox(height: 2),
          Text(meta, style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 11)),
        ])),
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
      decoration: BoxDecoration(color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(val, style: TextStyle(color: color, fontSize: 18,
            fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 10)),
      ]),
    );
  }

  Widget _bottomNav(BuildContext context, String active) {
    return Container(
      color: AppColors.navBg,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Beranda',
            active: active == 'home', onTap: () {}),
        BottomNavItem(icon: Icons.notifications_outlined, label: 'Alert',
            showDot: true, active: active == 'alert',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SvAlertScreen()))),
        BottomNavItem(icon: Icons.show_chart, label: 'Data Drift',
            active: active == 'drift',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SvDriftScreen()))),
        BottomNavItem(icon: Icons.history, label: 'Riwayat',
            active: active == 'history',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SvHistoryScreen()))),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil',
            active: active == 'profile',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SvProfileScreen()))),
      ]),
    );
  }
}