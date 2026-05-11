import 'package:flutter/material.dart';
import '../../../main.dart'; // AppThemeScope
import 'guest_home_screen.dart';
import '../common/bible_reader_screen.dart';

import '../../widgets/custom_drawer.dart';

class GuestMainScreen extends StatefulWidget {
  const GuestMainScreen({Key? key}) : super(key: key);

  @override
  State<GuestMainScreen> createState() => _GuestMainScreenState();
}

class _GuestMainScreenState extends State<GuestMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GuestHomeScreen(),
    const BibleReaderScreen(),
    const Center(child: Text('Planes')),
    const Center(child: Text('Descubrir')),
    const Center(child: Text('Tú')),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CustomDrawer(isGuest: true),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Eliminamos el leading personalizado para que se muestre el icono de hamburguesa automáticamente
        // Botón de tema movido al Drawer para un diseño más limpio
        actions: const [],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: const Color(0xFFF57C00),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Biblia'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: 'Planes'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Descubrir'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tú'),
        ],
      ),
    );
  }
}
