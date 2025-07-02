import 'package:cloud_firestore/cloud_firestore.dart';

class BloqueioQuadra {
  final String id;
  final String quadraId;
  final String tipo;
  final String? horaInicio;
  final String? horaFim;
  final String motivo;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final String? diaSemana;
  final DateTime criadoEm;

  BloqueioQuadra({
    required this.id,
    required this.quadraId,
    required this.tipo,
    this.horaInicio,
    this.horaFim,
    required this.motivo,
    this.dataInicio,
    this.dataFim,
    this.diaSemana,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'tipo': tipo,
      'horaInicio': horaInicio,
      'horaFim': horaFim,
      'motivo': motivo,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };

    if (dataInicio != null) {
      map['dataInicio'] = Timestamp.fromDate(dataInicio!);
    }
    if (dataFim != null) {
      map['dataFim'] = Timestamp.fromDate(dataFim!);
    }
    if (diaSemana != null) {
      map['diaSemana'] = diaSemana;
    }

    return map;
  }

  factory BloqueioQuadra.fromDocument(
    DocumentSnapshot doc, {
    required String quadraId,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return BloqueioQuadra(
      id: doc.id,
      quadraId: quadraId,
      tipo: data['tipo'] ?? '',
      horaInicio: data['horaInicio'],
      horaFim: data['horaFim'],
      motivo: data['motivo'] ?? '',
      dataInicio: (data['dataInicio'] as Timestamp?)?.toDate(),
      dataFim: (data['dataFim'] as Timestamp?)?.toDate(),
      diaSemana: data['diaSemana'],
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
