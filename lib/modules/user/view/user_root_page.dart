import 'package:arenanow/modules/user/view/lista_estabelecimento_user_page.dart';
import 'package:arenanow/modules/user/view/visualizar_reserva_quadra_page.dart';
import 'package:flutter/material.dart';
import 'package:arenanow/modules/user/view/user_profile_page.dart';

class UserRootPage extends StatefulWidget {
  const UserRootPage({super.key});

  @override
  State<UserRootPage> createState() => UserRootPageState();
}

class UserRootPageState extends State<UserRootPage> {
  int _currentIndex = 0;

  final List<Widget> _rootPages = const [
    ListaEstabelecimentosUserPage(),
    MinhasReservasPage(),
    UserProfilePage(),
  ];

  final List<Widget> _pageStack = [];
  bool get hasPages => _pageStack.isNotEmpty;

  void openPage(Widget page) {
    setState(() {
      _pageStack.add(page);
    });
  }

  void closePage() {
    setState(() {
      if (_pageStack.isNotEmpty) {
        _pageStack.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageStack.isNotEmpty) {
          closePage();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1A2F),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF0E1A2F),
          selectedItemColor: const Color(0xFFF2598C),
          unselectedItemColor: Colors.white70,
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() {
              _currentIndex = i;
              _pageStack.clear();
            });
          },
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
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _rootPages.map((page) {
                return _injectNavigator(page);
              }).toList(),
            ),
            ..._pageStack.map((page) {
              return _injectNavigator(page);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _injectNavigator(Widget page) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => _PageWrapper(
            child: page,
            onPop: closePage,
          ),
        );
      },
    );
  }
}

class _PageWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onPop;

  const _PageWrapper({
    super.key,
    required this.child,
    required this.onPop,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onPop();
        return false;
      },
      child: child,
    );
  }
}
