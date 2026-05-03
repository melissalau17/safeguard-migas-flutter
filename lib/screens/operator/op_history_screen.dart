import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import '../../services/api_service.dart';
import 'op_alert_screen.dart';
import 'op_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OpHistoryScreen extends StatefulWidget {
  const OpHistoryScreen({super.key});
  @override
  State<OpHistoryScreen> createState() => _OpHistoryScreenState();
}

class _OpHistoryScreenState extends State<OpHistoryScreen> {
  Map<String, dynamic>? _history;
  bool _loading = true;
  String _period = 'today';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final headers = await ApiService.authHeaders();
      final res = await http.get(
        Uri.parse("${ApiService.baseUrl}/history?period=$_period"),
        headers: headers,
      );
      if (res.statusCode == 200 && mounted) {
        setState(() { _history = jsonDecode(res.body); _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun',
                    'Jul','Agu','Sep','Okt','Nov','Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String? dt) {
    if (dt == null) return '';
    final d = DateTime.tryParse(dt)?.toLocal();
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  }

  String _formatDateTime(String? dt) {
    if (dt == null) return '';
    final d = DateTime.tryParse(dt)?.toLocal();
    if (d == null) return '';
    return '${_formatDate(d)} ${_formatTime(dt)}';
  }

  String _duration(String? start, String? end) {
    if (start == null) return '';
    final s = DateTime.tryParse(start);
    final e = end != null ? DateTime.tryParse(end) : DateTime.now();
    if (s == null || e == null) return '';
    final diff = e.difference(s).inMinutes;
    return diff < 60 ? '$diff mnt' : '${(diff/60).toStringAsFixed(1)} jam';
  }

  @override
  Widget build(BuildContext context) {
    final alerts = (_history?['alerts'] as List?) ?? [];
    final stats  = (_history?['stats'] as Map?) ?? {};
    final today  = _formatDate(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        _header(today),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadHistory,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              // Filter chips
              Row(children: [
                _chip('Hari ini',  'today'),
                const SizedBox(width: 8),
                _chip('7 Hari',   '7days'),
                const SizedBox(width: 8),
                _chip('30 Hari',  '30days'),
              ]),
              const SizedBox(height: 12),

              // Alert list
              _loading
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator()))
                : alerts.isEmpty
                  ? AppCard(padding: const EdgeInsets.all(20),
                      child: const Center(child: Text('Tidak ada anomaly pada periode ini',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12))))
                  : AppCard(child: Column(
                      children: alerts.asMap().entries.map((e) {
                        final i = e.key;
                        final a = e.value;
                        final isActive = a['status'] == 'active' ||
                                         a['status'] == 'acknowledged';
                        final start    = _formatTime(a['detected_at']);
                        final end      = isActive ? 'sekarang' : _formatTime(a['resolved_at']);
                        final dur      = _duration(a['detected_at'], a['resolved_at']);
                        final dateStr  = _period != 'today'
                            ? _formatDateTime(a['detected_at']) : '$start – $end';
                        return Column(children: [
                          if (i > 0) const Divider(height: 1, color: AppColors.border),
                          _faultRow(
                            a['fault_label'] ?? 'Unknown',
                            '$dateStr • Durasi: $dur',
                            isActive ? AppColors.redLight : AppColors.textMuted,
                            isActive ? StatusBadge.red('Aktif') : StatusBadge.green('Resolved'),
                          ),
                        ]);
                      }).toList(),
                    )),
              const SizedBox(height: 12),

              // Stats
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionLabel('Ringkasan periode ini'),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.8,
                    children: [
                      _statBox('${stats['total'] ?? alerts.length}',
                          'Total anomaly', AppColors.red),
                      _statBox('${stats['resolved'] ?? 0}',
                          'Resolved', AppColors.green),
                      _statBox('${stats['avg_duration_minutes'] ?? '-'}m',
                          'Avg durasi', AppColors.textPrimary),
                      _statBox('${stats['active'] ?? 0}',
                          'Masih aktif', AppColors.yellow),
                    ],
                  ),
                ]),
              ),
            ]),
          ),
        ),
        _bottomNav(context),
      ])),
    );
  }

  Widget _header(String today) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Riwayat Anomaly',
            style: TextStyle(color: AppColors.textPrimary,
                fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text('Update terakhir: $today',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _chip(String label, String period) {
    final active = _period == period;
    return GestureDetector(
      onTap: () {
        setState(() => _period = period);
        _loadHistory();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A3A6A) : AppColors.surface,
          border: Border.all(color: active ? AppColors.blue : AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(
            color: active ? AppColors.blue : AppColors.textSecondary,
            fontSize: 11, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _faultRow(String title, String meta, Color titleColor, Widget badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(title, style: TextStyle(
              color: titleColor, fontSize: 13, fontWeight: FontWeight.w500))),
          badge,
        ]),
        const SizedBox(height: 4),
        Text(meta, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 11)),
      ]),
    );
  }

  Widget _statBox(String value, String label, Color valueColor) {
    return Container(
      decoration: BoxDecoration(color: AppColors.bg,
          borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: TextStyle(color: valueColor, fontSize: 18,
            fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 10)),
      ]),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      color: AppColors.navBg,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Beranda',
            onTap: () => Navigator.pop(context)),
        BottomNavItem(icon: Icons.notifications_outlined, label: 'Alert',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const OpAlertScreen()))),
        BottomNavItem(icon: Icons.history, label: 'Riwayat', active: true,
            onTap: () {}),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const OpProfileScreen()))),
      ]),
    );
  }
}