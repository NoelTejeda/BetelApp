import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../domain/models/user_model.dart';
import '../teacher/teacher_main_screen.dart';
import '../student/student_main_screen.dart';
import '../../screens/admin/user_management_screen.dart';
import '../../../main.dart'; // Para AppThemes

class MemberLoginScreen extends StatefulWidget {
  const MemberLoginScreen({Key? key}) : super(key: key);

  @override
  State<MemberLoginScreen> createState() => _MemberLoginScreenState();
}

class _MemberLoginScreenState extends State<MemberLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Por favor, completa todos los campos para continuar.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        if (user.role == UserRole.seguridad) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UserManagementScreen()));
        } else if (user.role == UserRole.maestro) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TeacherMainScreen()));
        } else if (user.role == UserRole.alumno) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentMainScreen()));
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'El correo electrónico no tiene un formato válido.';
          break;
        case 'user-disabled':
          message = 'Esta cuenta ha sido desactivada. Contacta al administrador.';
          break;
        case 'user-not-found':
          message = 'No encontramos ninguna cuenta con este correo.';
          break;
        case 'wrong-password':
          message = 'La contraseña es incorrecta. Inténtalo de nuevo.';
          break;
        case 'invalid-credential':
          message = 'Los datos ingresados no coinciden con nuestros registros.';
          break;
        case 'network-request-failed':
          message = 'Error de conexión. Revisa tu internet e inténtalo de nuevo.';
          break;
        case 'too-many-requests':
          message = 'Demasiados intentos fallidos. Por favor, espera un momento.';
          break;
        default:
          message = 'Ocurrió un error inesperado al intentar iniciar sesión.';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Algo salió mal. Por favor, intenta de nuevo más tarde.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppThemes.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ingreso de Miembros'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text('¡Hola de nuevo!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                const Text('Inicia sesión para continuar', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFFF57C00), Color(0xFFFFB300)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
