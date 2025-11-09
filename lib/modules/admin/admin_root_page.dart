import 'package:flutter/material.dart';

import 'package:arenanow/modules/home/home_page.dart';
import 'package:arenanow/modules/admin/view/admin_profile_page.dart';

class AdminRootPage extends StatefulWidget {
  const AdminRootPage({super.key});

  @override
  State<AdminRootPage> createState() => AdminRootPageState();
}

class AdminRootPageState extends State<AdminRootPage> {
  int _currentIndex = 0;

  final List<Widget> pages = [
    HomePage(),
    AdminProfilePage(),
  ];

  void navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF16243D),
        selectedItemColor: const Color(0xFFF2598C),
        unselectedItemColor: Colors.white60,
        currentIndex: _currentIndex,
        onTap: navigateTo,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
