import 'package:flutter/material.dart';

class UserScaffold extends StatelessWidget {
  final int currentIndex;
  final Widget body;
  final Function(int) onTabSelected;

  const UserScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      body: SafeArea(child: body),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0E1A2F),
        selectedItemColor: const Color(0xFFF2598C),
        unselectedItemColor: Colors.white38,
        currentIndex: currentIndex,
        onTap: onTabSelected,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
