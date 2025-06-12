import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:arenanow/modules/auth/login_page.dart';
import 'package:arenanow/modules/auth/auth_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (_) => false,
              );
            },
          )
        ],
      ),
      body: Center(
        child: Text(
          'Bem-vindo, ${user?.email ?? 'usuário'}!',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
