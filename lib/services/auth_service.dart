import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser> register({
    required String nome,
    required String email,
    required String senha,
    required String role,
    String? telefone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    final user = AppUser(
      id: cred.user!.uid,
      nome: nome,
      email: email,
      telefone: telefone,
      role: role,
      criadoEm: DateTime.now(),
    );

    await _db.collection('users').doc(user.id).set(user.toMap());
    return user;
  }

  Future<User?> login(String email, String senha) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
    return cred.user;
  }

  /// Logout
  Future<void> logout() => _auth.signOut();
}
