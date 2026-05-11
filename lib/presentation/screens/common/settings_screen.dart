import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
        await FirebaseMessaging.instance.subscribeToTopic('daily_verse');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('daily_verse');
      }
      setState(() {
        _dailyVerseEnabled = value;
      });
    } catch (e) {
      // Manejar error de conexión
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
