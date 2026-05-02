import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'operator/op_home_screen.dart';
import 'supervisor/sv_home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _login(BuildContext context, String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => role == 'operator' ? const OpHomeScreen() : const SvHomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'SafeGuard Migas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Masuk ke akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              _field('ID Karyawan', 'OP-20241'),
              const SizedBox(height: 10),
              _field('Password', '••••••••'),
              const SizedBox(height: 20),
              const Text(
                'Masuk sebagai:',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 14),
              _roleBtn(context, 'Operator Lapangan', 'operator',
                  const Color(0xFF1A3A6A), AppColors.blue),
              _roleBtn(context, 'Supervisor / Engineer', 'supervisor',
                  const Color(0xFF2A1A5A), AppColors.purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _roleBtn(BuildContext context, String label, String role, Color bg, Color fg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _login(context, role),
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}