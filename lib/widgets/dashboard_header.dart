import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:arenanow/modules/auth/auth_gate.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logoArenaNowIcon.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              const Text(
                'ArenaNow',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
