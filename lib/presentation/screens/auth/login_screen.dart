import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../main.dart'; // AppThemeScope
import '../guest/guest_main_screen.dart';
import 'member_login_screen.dart';
import '../../../services/database_seed_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void _navigateToGuest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GuestMainScreen()),
    );
  }

  void _navigateToMembersLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MemberLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Forzamos el tema claro para la pantalla de login
    const isDark = false;
    
    return Theme(
      data: AppThemes.lightTheme,
      child: Scaffold(
        backgroundColor: AppThemes.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Se elimina el botón de cambio de tema según lo solicitado
          actions: const [],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo de la iglesia (Mantenlo presionado para crear la base de datos)
                GestureDetector(
                  onLongPress: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Iniciando creación de colecciones...')),
                      );
                      await DatabaseSeedService.seedDatabase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Base de datos lista en Firebase.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: RepaintBoundary(
                    child: SvgPicture.asset(
                      'assets/images/logoBetel.svg',
                      height: 280,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Iglesia Betel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Más que una Iglesia, Somos una Familia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 60),
  
                // Botón Invitado
                ElevatedButton.icon(
                  onPressed: () => _navigateToGuest(context),
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Acceder como Invitado'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
  
                // Botón Miembros
                ElevatedButton.icon(
                  onPressed: () => _navigateToMembersLogin(context),
                  icon: const Icon(Icons.group),
                  label: const Text('Acceso para Miembros'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
