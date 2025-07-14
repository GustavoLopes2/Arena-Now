import 'package:cloud_firestore/cloud_firestore.dart';

class BloqueioQuadra {
  final String id;
  final String quadraId;
  final String tipo;
  final String motivo;
  final String horaInicio;
  final String horaFim;
  final String? diaSemana;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final DateTime criadoEm;

  BloqueioQuadra({
    required this.id,
    required this.quadraId,
    required this.tipo,
    required this.motivo,
    required this.horaInicio,
    required this.horaFim,
    required this.dataInicio,
    required this.dataFim,
    required this.diaSemana,
    required this.criadoEm,
  });

  BloqueioQuadra copyWith({
    String? motivo,
    String? horaInicio,
    String? horaFim,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return BloqueioQuadra(
      id: id,
      quadraId: quadraId,
      tipo: tipo,
      motivo: motivo ?? this.motivo,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
      diaSemana: diaSemana,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      criadoEm: criadoEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quadraId': quadraId,
      'tipo': tipo,
      'motivo': motivo,
      'horaInicio': horaInicio,
      'horaFim': horaFim,
      'diaSemana': diaSemana,
      'dataInicio': dataInicio,
      'dataFim': dataFim,
      'criadoEm': criadoEm,
    };
  }

  static BloqueioQuadra fromDocument(
    DocumentSnapshot doc, {
    required String quadraId,
  }) {
    final d = doc.data() as Map<String, dynamic>;

    return BloqueioQuadra(
      id: doc.id,
      quadraId: quadraId,
      tipo: d['tipo'] ?? '',
      motivo: d['motivo'] ?? '',
      horaInicio: d['horaInicio'] ?? '',
      horaFim: d['horaFim'] ?? '',
      diaSemana: d['diaSemana'],
      dataInicio: d['dataInicio'] != null
          ? (d['dataInicio'] as Timestamp).toDate()
          : null,
      dataFim:
          d['dataFim'] != null ? (d['dataFim'] as Timestamp).toDate() : null,
      criadoEm: d['criadoEm'] != null
          ? (d['criadoEm'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
