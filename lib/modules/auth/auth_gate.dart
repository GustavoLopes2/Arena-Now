import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_page.dart';
import 'login_page.dart';
import '../user/user_dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final userId = snapshot.data!.uid;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(userId)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const Scaffold(
                    body: Center(child: Text('Usuário não encontrado.')));
              }

              final data = userSnapshot.data!.data() as Map<String, dynamic>;
              final role = data['role'];

              if (role == 'admin') {
                return HomePage();
              } else {
                return const UserDashboardPage();
              }
            },
          );
        }

        return const LoginPage();
      },
    );
  }
}
