import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widgets.dart';
import '../../services/api_service.dart';
import 'sv_drift_screen.dart';
import 'sv_history_screen.dart';
import 'sv_profile_screen.dart';

class SvAlertScreen extends StatefulWidget {
  const SvAlertScreen({super.key});
  @override
  State<SvAlertScreen> createState() => _SvAlertScreenState();
}

class _SvAlertScreenState extends State<SvAlertScreen> {
  List<dynamic> _alerts = [];
  bool _loading = true;
  final Set<int> _loadingIds = {};

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      final results = await Future.wait([
        Future(() async {
          final r = await ApiService.getAlerts(status: 'active');
          return r;
        }),
        Future(() async {
          final r = await ApiService.getAlerts(status: 'acknowledged');
          return r;
        }),
      ]);
      final combined = [...results[0], ...results[1]];
      // Sort by detected_at descending
      combined.sort((a, b) {
        final ta = DateTime.tryParse(a['detected_at'] ?? '') ?? DateTime(0);
        final tb = DateTime.tryParse(b['detected_at'] ?? '') ?? DateTime(0);
        return tb.compareTo(ta);
      });
      if (mounted) setState(() { _alerts = combined; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doAction(int id, String action) async {
    setState(() => _loadingIds.add(id));
    try {
      switch (action) {
        case 'acknowledge': await ApiService.acknowledgeAlert(id); break;
        case 'resolve':     await ApiService.resolveAlert(id);     break;
        case 'escalate':    await ApiService.escalateAlert(id);    break;
      }
      await _loadAlerts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil: alert di-$action')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingIds.remove(id));
    }
  }

  String _formatTime(String? dt) {
    if (dt == null) return '';
    final d = DateTime.tryParse(dt)?.toLocal();
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} WIB';
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
                      final conf = ((a['confidence'] ?? 0.0) * 100)
                          .toStringAsFixed(0);
                      return _alertCard(
                        id: a['id'],
                        title: a['fault_label'] ?? 'Unknown',
                        badge: isCritical
                          ? StatusBadge.red('Critical')
                          : StatusBadge.yellow('Warning'),
                        borderColor: isCritical
                          ? AppColors.criticalBorder
                          : const Color(0xFF3D3015),
                        titleColor: isCritical
                          ? AppColors.redLight
                          : AppColors.yellowLight,
                        meta: '${a['unit']} • ${_formatTime(a['detected_at'])} • '
                              'Confidence: $conf% • Uncertainty: ${a['uncertainty'] ?? '-'}',
                        assignedTo: a['assigned_user']?['name'],
                        status: a['status'] ?? 'active',
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
        const Text('Manajemen Alert',
            style: TextStyle(color: AppColors.textPrimary,
                fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text('$critical critical • $warning warning • Semua unit',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _alertCard({
    required int id,
    required String title,
    required Widget badge,
    required Color borderColor,
    required Color titleColor,
    required String meta,
    String? assignedTo,
    required String status,
  }) {
    final isLoadingThis = _loadingIds.contains(id);

    return AppCard(
      borderColor: borderColor,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(title,
              style: TextStyle(color: titleColor, fontSize: 13,
                  fontWeight: FontWeight.w500))),
          badge,
        ]),
        const SizedBox(height: 6),
        Text(meta, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 11)),
        if (assignedTo != null) ...[
          const SizedBox(height: 4),
          Text('Assigned: $assignedTo',
              style: const TextStyle(color: AppColors.blue, fontSize: 11)),
        ],
        const SizedBox(height: 10),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: status == 'acknowledged'
              ? const Color(0xFF1A2A1A)
              : const Color(0xFF2D1414),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status == 'acknowledged' ? 'Acknowledged' : 'Active',
            style: TextStyle(
              color: status == 'acknowledged'
                ? AppColors.green : AppColors.red,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Action buttons
        isLoadingThis
          ? const Center(child: SizedBox(
              height: 24, width: 24,
              child: CircularProgressIndicator(strokeWidth: 2)))
          : Row(children: [
              if (status == 'active') ...[
                Expanded(child: _actionBtn(
                  'Acknowledge',
                  const Color(0xFF0F2A1A),
                  AppColors.green,
                  () => _doAction(id, 'acknowledge'),
                )),
                const SizedBox(width: 8),
              ],
              Expanded(child: _actionBtn(
                'Eskalasi',
                const Color(0xFF2D1414),
                AppColors.red,
                () => _doAction(id, 'escalate'),
              )),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn(
                'Resolve',
                const Color(0xFF1A3A6A),
                AppColors.blue,
                () => _doAction(id, 'resolve'),
              )),
            ]),
      ]),
    );
  }

  Widget _actionBtn(String label, Color bg, Color fg, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
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
        BottomNavItem(icon: Icons.show_chart, label: 'Data Drift',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SvDriftScreen()))),
        BottomNavItem(icon: Icons.history, label: 'Riwayat',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SvHistoryScreen()))),
        BottomNavItem(icon: Icons.person_outline, label: 'Profil',
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SvProfileScreen()))),
      ]),
    );
  }
}