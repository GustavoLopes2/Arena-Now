import 'package:cloud_firestore/cloud_firestore.dart';

class AgendaSemanal {
  final String id;
  final String quadraId;
  final String diaSemana;
  final String horaInicio;
  final String horaFim;
  final int intervaloMinutos;
  final DateTime criadoEm;

  AgendaSemanal({
    required this.id,
    required this.quadraId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFim,
    required this.intervaloMinutos,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'diaSemana': diaSemana,
      'horaInicio': horaInicio,
      'horaFim': horaFim,
      'intervaloMinutos': intervaloMinutos,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  factory AgendaSemanal.fromDocument(
    DocumentSnapshot doc, {
    required String quadraId,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return AgendaSemanal(
      id: doc.id,
      quadraId: quadraId,
      diaSemana: data['diaSemana'] ?? '',
      horaInicio: data['horaInicio'] ?? '',
      horaFim: data['horaFim'] ?? '',
      intervaloMinutos: (data['intervaloMinutos'] ?? 0) is int
          ? data['intervaloMinutos'] as int
          : int.tryParse('${data['intervaloMinutos']}') ?? 0,
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
