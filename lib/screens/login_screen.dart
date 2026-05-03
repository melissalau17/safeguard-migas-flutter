import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'operator/op_home_screen.dart';
import 'supervisor/sv_home_screen.dart';
// comment out if testing on web:
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  Future<void> _handleLogin(String role) async {
    final id = _idController.text.isEmpty ? 'OP-001' : _idController.text;
    final pass =
        _passController.text.isEmpty ? 'password123' : _passController.text;

    setState(() => _loading = true);
    try {
      final data = await ApiService.login(id, pass);
      final userRole = data['role'];

      // ── Kirim FCM token setelah login berhasil ──
      // Comment out if testing on web:
      // final fcmToken = await FirebaseMessaging.instance.getToken();
      // if (fcmToken != null) {
      //   await ApiService.updateFcmToken(fcmToken);
      // }

      
      // if (!kIsWeb) {
      //   final fcmToken = await FirebaseMessaging.instance.getToken();
      //   if (fcmToken != null) {
      //     await ApiService.updateFcmToken(fcmToken);
      //   }
      // }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => userRole == 'operator'
              ? const OpHomeScreen()
              : const SvHomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              _inputField('ID Karyawan', 'OP-20241', _idController),
              const SizedBox(height: 10),
              _inputField('Password', '••••••••', _passController,
                  obscure: true),
              const SizedBox(height: 20),
              const Text(
                'Masuk sebagai:',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 14),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _roleBtn('Operator Lapangan', 'operator',
                    const Color(0xFF1A3A6A), AppColors.blue),
                _roleBtn('Supervisor / Engineer', 'supervisor',
                    const Color(0xFF2A1A5A), AppColors.purple),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController ctrl,
      {bool obscure = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _roleBtn(String label, String role, Color bg, Color fg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleLogin(role),
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: Text(label,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
