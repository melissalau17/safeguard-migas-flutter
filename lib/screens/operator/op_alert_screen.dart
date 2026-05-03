import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import '../../services/api_service.dart';
import 'op_history_screen.dart';
import 'op_profile_screen.dart';

class OpAlertScreen extends StatefulWidget {
  const OpAlertScreen({super.key});
  @override
  State<OpAlertScreen> createState() => _OpAlertScreenState();
}

class _OpAlertScreenState extends State<OpAlertScreen> {
  List<dynamic> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      final data = await ApiService.getAlerts(status: 'active');
      if (mounted) setState(() { _alerts = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _acknowledge(int alertId) async {
    try {
      await ApiService.acknowledgeAlert(alertId);
      _loadAlerts();
    } catch (_) {}
  }

  Future<void> _resolve(int alertId) async {
    try {
      await ApiService.resolveAlert(alertId);
      _loadAlerts();
    } catch (_) {}
  }

  String _timeAgo(String? detectedAt) {
    if (detectedAt == null) return '';
    final dt = DateTime.tryParse(detectedAt);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    return '${diff.inHours} jam lalu';
  }

  String _formatTime(String? detectedAt) {
    if (detectedAt == null) return '';
    final dt = DateTime.tryParse(detectedAt);
    if (dt == null) return '';
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2,'0')}:${local.minute.toString().padLeft(2,'0')} WIB';
  }

  @override
  Widget build(BuildContext context) {
    final critical = _alerts.where((a) => a['severity'] == 'critical').length;
    final warning  = _alerts.where((a) => a['severity'] == 'warning').length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        _header(critical, warning),
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _alerts.isEmpty
              ? const Center(child: Text('Tidak ada alert aktif',
                  style: TextStyle(color: AppColors.textSecondary)))
              : RefreshIndicator(
                  onRefresh: _loadAlerts,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _alerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final a = _alerts[i];
                      final isCritical = a['severity'] == 'critical';
                      final conf = ((a['confidence'] ?? 0.0) * 100).toStringAsFixed(0);
                      return _alertCard(
                        id: a['id'],
                        title: a['fault_label'] ?? 'Unknown',
                        badge: isCritical
                          ? StatusBadge.red('Critical')
                          : StatusBadge.yellow('Warning'),
                        dotColor: isCritical ? AppColors.red : AppColors.yellow,
                        titleColor: isCritical ? AppColors.redLight : AppColors.yellowLight,
                        borderColor: isCritical
                          ? AppColors.criticalBorder
                          : const Color(0xFF3D3015),
                        meta: '${a['unit']} • ${_formatTime(a['detected_at'])} • ${_timeAgo(a['detected_at'])}',
                        desc: a['description'] ?? '',
                        confidence: 'Confidence: $conf%',
                        confColor: isCritical ? AppColors.red : AppColors.yellow,
                        uncertainty: 'Uncertainty: ${a['uncertainty'] ?? '-'}',
                        status: a['status'],
                      );
                    },
                  ),
                ),
        ),
        _bottomNav(context),
      ])),
    );
  }

  Widget _header(int critical, int warning) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Alert Aktif',
            style: TextStyle(color: AppColors.textPrimary,
                fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text('$critical critical • $warning warning',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _alertCard({
    required int id,
    required String title, required Widget badge, required Color dotColor,
    required Color titleColor, required Color borderColor, required String meta,
    required String desc, required String confidence, required Color confColor,
    required String uncertainty, required String status,
  }) {
    return AppCard(
      borderColor: borderColor,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 3.5, backgroundColor: dotColor),
          const SizedBox(width: 8),
          Expanded(child: Text(title,
              style: TextStyle(color: titleColor, fontSize: 13,
                  fontWeight: FontWeight.w500))),
          badge,
        ]),
        const SizedBox(height: 8),
        Text(meta, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 11)),
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(
              color: AppColors.textMuted, fontSize: 12)),
        ],
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(confidence, style: TextStyle(color: confColor, fontSize: 11)),
          Text(uncertainty,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        // Action buttons
        if (status == 'active') Row(children: [
          Expanded(child: _actionBtn('Acknowledge', const Color(0xFF0F2A1A),
              AppColors.green, () => _acknowledge(id))),
          const SizedBox(width: 8),
          Expanded(child: _actionBtn('Resolve', const Color(0xFF1A3A6A),
              AppColors.blue, () => _resolve(id))),
        ]),
        if (status == 'acknowledged')
          _actionBtn('Resolve', const Color(0xFF1A3A6A),
              AppColors.blue, () => _resolve(id)),
      ]),
    );
  }

  Widget _actionBtn(String label, Color bg, Color fg, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg, foregroundColor: fg, elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
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
            active: true, onTap: () {}),
        BottomNavItem(icon: Icons.history, label: 'Riwayat',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const OpHistoryScreen()))),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const OpProfileScreen()))),
      ]),
    );
  }
}