import 'package:flutter/material.dart';
import '../../../main.dart';
import '../guest/guest_home_screen.dart';
import 'teacher_classes_screen.dart';
import '../common/profile_screen.dart';
import '../common/bible_reader_screen.dart';

import '../../widgets/custom_drawer.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({Key? key}) : super(key: key);

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GuestHomeScreen(),
    const BibleReaderScreen(),
    const Center(child: Text('Planes')),
    const TeacherClassesScreen(),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Biblia'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: 'Planes'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Clases'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tú'),
        ],
      ),
    );
  }
}
