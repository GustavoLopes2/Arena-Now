import 'package:cloud_firestore/cloud_firestore.dart';

class Estabelecimento {
  final String id;
  final String nome;
  final String endereco;
  final String descricao;
  final int prazoCancelamentoHoras;
  final String? adminId;
  final DateTime criadoEm;

  Estabelecimento({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.descricao,
    required this.prazoCancelamentoHoras,
    this.adminId,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'endereco': endereco,
      'descricao': descricao,
      'prazoCancelamentoHoras': prazoCancelamentoHoras,
      'adminId': adminId,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  factory Estabelecimento.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Estabelecimento(
      id: doc.id,
      nome: data['nome'] ?? '',
      endereco: data['endereco'] ?? '',
      descricao: data['descricao'] ?? '',
      prazoCancelamentoHoras: (data['prazoCancelamentoHoras'] ?? 0) is int
          ? data['prazoCancelamentoHoras'] as int
          : int.tryParse('${data['prazoCancelamentoHoras']}') ?? 0,
      adminId: data['adminId'],
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Estabelecimento copyWith({
    String? id,
    String? nome,
    String? endereco,
    String? descricao,
    int? prazoCancelamentoHoras,
    String? adminId,
    DateTime? criadoEm,
  }) {
    return Estabelecimento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      endereco: endereco ?? this.endereco,
      descricao: descricao ?? this.descricao,
      prazoCancelamentoHoras:
          prazoCancelamentoHoras ?? this.prazoCancelamentoHoras,
      adminId: adminId ?? this.adminId,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
