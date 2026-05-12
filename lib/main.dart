import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'presentation/screens/guest/guest_main_screen.dart';
import 'presentation/screens/auth/member_login_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurar notificaciones en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inicializar servicio de notificaciones
  await NotificationService.initialize();

  runApp(const MyApp());
}

class AppThemeScope extends InheritedWidget {
  final ThemeMode themeMode;
  final double fontSizeFactor;
  final VoidCallback toggleTheme;
  final Function(double) updateFontSize;

  const AppThemeScope({
    super.key,
    required this.themeMode,
    required this.fontSizeFactor,
    required this.toggleTheme,
    required this.updateFontSize,
    required super.child,
  });

  static AppThemeScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppThemeScope>()!;
  }

  @override
  bool updateShouldNotify(AppThemeScope oldWidget) {
    return themeMode != oldWidget.themeMode || fontSizeFactor != oldWidget.fontSizeFactor;
  }
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4285F4),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4285F4),
      brightness: Brightness.dark,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSizeFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final isDark = prefs.getBool('is_dark');
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      }
      _fontSizeFactor = prefs.getDouble('font_size_factor') ?? 1.0;
    });
  }

  void _toggleTheme() async {
    final newMode = (_themeMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    setState(() {
      _themeMode = newMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', newMode == ThemeMode.dark);
  }

  void _updateFontSize(double factor) async {
    setState(() {
      _fontSizeFactor = factor;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size_factor', factor);
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      themeMode: _themeMode,
      fontSizeFactor: _fontSizeFactor,
      toggleTheme: _toggleTheme,
      updateFontSize: _updateFontSize,
      child: MaterialApp(
        title: 'Betel App',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(_fontSizeFactor),
            ),
            child: child!,
          );
        },
        home: const WelcomeScreen(),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppThemes.lightTheme,
      child: Scaffold(
        backgroundColor: AppThemes.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: const [],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 3),
                
                // LOGO AGRANDADO
                SvgPicture.asset(
                  'assets/images/logoBetel.svg',
                  height: 250,
                ),
                
                const Spacer(flex: 2),
                
                // TEXTOS ORIGINALES
                const Text(
                  'Iglesia Betel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Más que una Iglesia, Somos una Familia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // BOTÓN INVITADO (GRIS)
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuestMainScreen())),
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Acceder como Invitado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEEEEE),
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // BOTÓN MIEMBRO (AZUL / GRADIENTE OPCIONAL)
                _buildMainButton(context),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context) {
    // Usamos el gradiente que mencionaste para el botón principal pero manteniendo la forma original
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFF57C00), Color(0xFFFFB300)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberLoginScreen())),
        icon: const Icon(Icons.group_outlined, color: Colors.white),
        label: const Text('Acceso para Miembros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
