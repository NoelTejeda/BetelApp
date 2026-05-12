import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/common/drawer_content_screen.dart';
import '../screens/common/settings_screen.dart';
import '../../services/app_content_service.dart';
import '../../services/auth_service.dart';
import '../../domain/models/app_content_model.dart';
import '../../domain/models/user_model.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../../main.dart'; // Para AppThemeScope

class CustomDrawer extends StatelessWidget {
  final bool isGuest;
  
  const CustomDrawer({
    Key? key,
    this.isGuest = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeScope = AppThemeScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          // Logo section on white background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
            ),
            child: SvgPicture.asset(
              'assets/images/logoBetel.svg',
              height: 120,
            ),
          ),
          
          // "Bienvenido" strip in grayish tone - CENTERED
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            color: const Color(0xFFECEFF1), // Premium grayish
            child: const Text(
              'Bienvenido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF263238),
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Clickable menu items on black background
          Expanded(
            child: Container(
              color: const Color(0xFF121212), // Deep Black
              child: Column(
                children: [
                   Expanded(
                    child: StreamBuilder<AppContentModel>(
                      stream: AppContentService().getContentStream(),
                      builder: (context, snapshot) {
                        final content = snapshot.data;
                        
                        return ListView(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          children: [
                            _buildMenuItem(
                              context, 
                              title: 'Conócenos', 
                              icon: Icons.info_outline_rounded,
                              content: (content?.aboutUs.isNotEmpty ?? false) 
                                ? content!.aboutUs 
                                : 'Somos la Iglesia Betel, una comunidad dedicada a compartir el amor de Dios y fortalecer la fe de cada persona. Nuestra visión es ser más que una iglesia, una familia unida en Cristo.\n\nContamos con más de 20 años de trayectoria sirviendo a nuestra comunidad y expandiendo el mensaje de esperanza a todas las naciones.',
                            ),
                            _buildMenuItem(
                              context, 
                              title: 'Ubícanos', 
                              icon: Icons.location_on_outlined,
                              content: (content?.location.isNotEmpty ?? false)
                                ? content!.location
                                : 'Nos encontramos ubicados en la calle Principal #123, en el corazón de la ciudad.\n\nHorarios de Servicio:\n- Domingo de Celebración: 9:00 AM y 11:30 AM\n- Escuela Dominical: 10:30 AM\n- Miércoles de Oración: 7:00 PM\n- Viernes de Jóvenes: 7:30 PM\n\n¡Te esperamos con los brazos abiertos!',
                            ),
                            _buildMenuItem(
                              context, 
                              title: 'Comisiones', 
                              icon: Icons.group_work_outlined,
                              content: 'Nuestras comisiones son el motor de nuestra iglesia:\n\nConoce todas nuestras comisiones, y si deseas formar parte de alguna, no dudes en comunicarte con el lider de cada comisión',
                            ),
                            
                            // Espacio para Administración (Solo si no es invitado)
                            if (!isGuest)
                              FutureBuilder<UserModel?>(
                                future: AuthService().getCurrentUser(),
                                builder: (context, userSnapshot) {
                                  final user = userSnapshot.data;
                                  if (user == null) return const SizedBox.shrink();
                                  
                                  if (user.role == UserRole.admin || user.role == UserRole.seguridad) {
                                    return _buildSimpleMenuItem(
                                      context,
                                      title: 'Administración',
                                      icon: Icons.admin_panel_settings_outlined,
                                      onTap: () {
                                        Navigator.pop(context);
                                        if (user.role == UserRole.admin) {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                                        } else {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen()));
                                        }
                                      },
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),

                            _buildSimpleMenuItem(
                              context,
                              title: 'Ajustes',
                              icon: Icons.settings_outlined,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                              },
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                  
                  const Divider(color: Colors.white10, height: 1),
                  
                  // Theme Toggle Section
                  SwitchListTile(
                    activeColor: const Color(0xFFF57C00),
                    secondary: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode, 
                      color: Colors.white70
                    ),
                    title: const Text(
                      'Modo Oscuro', 
                      style: TextStyle(color: Colors.white70, fontSize: 15)
                    ),
                    value: isDark,
                    onChanged: (bool value) {
                      themeScope.toggleTheme();
                    },
                  ),
                  
                  // Logout / Back to Home (Solo si NO es invitado)
                  if (!isGuest) ...[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                      leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                      title: const Text(
                        'Cerrar Sesión', 
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 15)
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required String title, required IconData icon, required String content}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: Colors.white, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrawerContentScreen(title: title, content: content),
          ),
        );
      },
    );
  }
  Widget _buildSimpleMenuItem(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: Colors.white, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      onTap: onTap,
    );
  }
}
