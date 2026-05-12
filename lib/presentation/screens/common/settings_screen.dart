import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../main.dart'; // Importar para AppThemeScope

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyVerseEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyVerseEnabled = prefs.getBool('daily_verse_enabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _toggleDailyVerse(bool value) async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_verse_enabled', value);

    try {
      if (value) {
        await FirebaseMessaging.instance.subscribeToTopic('diario');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('diario');
      }
      setState(() {
        _dailyVerseEnabled = value;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar preferencia: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeScope = AppThemeScope.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ajustes', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Notificaciones'),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Versículo Diario'),
                      subtitle: const Text('Recibe una palabra de aliento cada mañana'),
                      secondary: Icon(Icons.auto_stories, color: theme.colorScheme.primary),
                      value: _dailyVerseEnabled,
                      onChanged: _toggleDailyVerse,
                      activeColor: const Color(0xFFD32F2F),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Accesibilidad Visual'),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.text_fields, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          const Text('Tamaño de letra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: themeScope.fontSizeFactor,
                        min: 0.8,
                        max: 1.8,
                        divisions: 5,
                        label: _getLabelForFactor(themeScope.fontSizeFactor),
                        onChanged: (value) => themeScope.updateFontSize(value),
                        activeColor: const Color(0xFFD32F2F),
                      ),
                      const Center(
                        child: Text(
                          'Vista previa del texto',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Esta es una muestra de cómo se verá el texto en la Biblia y en las noticias de la iglesia.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Aplicación'),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                ),
                child: const ListTile(
                  title: Text('Versión'),
                  trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
                  leading: Icon(Icons.info_outline, color: Colors.grey),
                ),
              ),
            ],
          ),
    );
  }

  String _getLabelForFactor(double factor) {
    if (factor <= 0.8) return 'Pequeño';
    if (factor <= 1.0) return 'Normal';
    if (factor <= 1.2) return 'Grande';
    if (factor <= 1.4) return 'Muy Grande';
    return 'Extra Grande';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
