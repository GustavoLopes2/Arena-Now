import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String role;
  final DateTime criadoEm;

  AppUser({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    required this.role,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'role': role,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  factory AppUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      telefone: data['telefone'],
      role: data['role'] ?? 'user',
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  AppUser copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    String? role,
    DateTime? criadoEm,
  }) {
    return AppUser(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      role: role ?? this.role,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
