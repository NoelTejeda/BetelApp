import 'package:flutter/material.dart';
import '../../../main.dart';
import 'student_classes_screen.dart';
import '../common/profile_screen.dart';
import '../common/bible_reader_screen.dart';

import '../../widgets/custom_drawer.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({Key? key}) : super(key: key);

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Dashboard Alumno')),
    const BibleReaderScreen(),
    const StudentClassesScreen(),
    const Center(child: Text('Tus Logros')),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mi Academia Betel', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: const Color(0xFFF57C00),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Biblia'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Clases'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Logros'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tú'),
        ],
      ),
    );
  }
}
