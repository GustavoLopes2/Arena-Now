import 'package:arenanow/modules/user/user_dashboard_page.dart';
import 'package:arenanow/modules/user/view/visualizar_reserva_quadra_page.dart';
import 'package:flutter/material.dart';

class UserBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const UserBottomNavigation({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const UserDashboardPage();
        break;
      case 1:
        page = const MinhasReservasPage();
        break;
      case 2:
        page = const Scaffold(
          backgroundColor: Color(0xFF0E1A2F),
          body: Center(
            child: Text('Perfil do Usuário',
                style: TextStyle(color: Colors.white)),
          ),
        );
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E1A2F),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFFF2598C),
        unselectedItemColor: Colors.white38,
        onTap: (index) => _navigate(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
