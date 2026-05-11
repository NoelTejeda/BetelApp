import 'package:flutter/material.dart';

class CommissionDetailScreen extends StatelessWidget {
  final String name;
  final String mission;
  final String function;

  const CommissionDetailScreen({
    Key? key,
    required this.name,
    required this.mission,
    required this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              name,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 40),

            // Misión Section
            _buildInfoSection(
              context,
              title: 'MISIÓN',
              content: mission,
              icon: Icons.flag_rounded,
            ),
            const SizedBox(height: 40),

            // Función Section
            _buildInfoSection(
              context,
              title: 'FUNCIÓN',
              content: function,
              icon: Icons.settings_suggest_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, {required String title, required String content, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFD32F2F), size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          content,
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
