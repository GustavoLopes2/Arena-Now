import 'package:flutter/material.dart';
import 'package:arenanow/modules/user/view/lista_estabelecimento_user_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),

      // Mantém estado das abas (scroll, filtros, etc.)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF16243D),
        selectedItemColor: const Color(0xFFF2598C),
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Reservas",
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
