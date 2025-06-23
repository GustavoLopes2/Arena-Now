import 'package:arenanow/modules/user/view/lista_estabelecimento_user_page.dart';
import 'package:arenanow/modules/user/view/visualizar_reserva_quadra_page.dart';
import 'package:arenanow/widgets/user_scaffold.dart';
import 'package:flutter/material.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ListaEstabelecimentosUserPage(),
    MinhasReservasPage(),
    Center(
      child: Text('Perfil', style: TextStyle(color: Colors.white)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return UserScaffold(
      currentIndex: _selectedIndex,
      body: _pages[_selectedIndex],
      onTabSelected: (index) => setState(() => _selectedIndex = index),
    );
  }
}
