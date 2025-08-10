import 'package:arenanow/modules/user/view/lista_estabelecimento_user_page.dart';
import 'package:flutter/material.dart';
import 'package:arenanow/modules/user/view/visualizar_reserva_quadra_page.dart';
import 'package:arenanow/modules/user/view/user_profile_page.dart';

class UserRootPage extends StatefulWidget {
  const UserRootPage({super.key});

  @override
  State<UserRootPage> createState() => _UserRootPageState();
}

class _UserRootPageState extends State<UserRootPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ListaEstabelecimentosUserPage(),
    MinhasReservasPage(),
    UserProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0E1A2F),
        selectedItemColor: const Color(0xFFF2598C),
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
