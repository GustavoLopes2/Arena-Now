import 'package:cloud_firestore/cloud_firestore.dart';

class Quadra {
  final String id;
  final String nome;
  final String descricao;
  final String modalidade; // ex: 'Beach Tennis', 'Futebol Society'
  final String estabelecimentoId;
  final DateTime criadoEm;

  Quadra({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.modalidade,
    required this.estabelecimentoId,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'modalidade': modalidade,
      'estabelecimentoId': estabelecimentoId,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  factory Quadra.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quadra(
      id: doc.id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      modalidade: data['modalidade'] ?? '',
      estabelecimentoId: data['estabelecimentoId'] ?? '',
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Quadra copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? modalidade,
    String? estabelecimentoId,
    DateTime? criadoEm,
  }) {
    return Quadra(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      modalidade: modalidade ?? this.modalidade,
      estabelecimentoId: estabelecimentoId ?? this.estabelecimentoId,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
