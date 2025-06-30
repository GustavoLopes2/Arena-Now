import 'package:cloud_firestore/cloud_firestore.dart';

class ReservaQuadra {
  final String id;
  final String quadraId;
  final DateTime data; // dia da reserva
  final String horaInicio; // 'HH:mm'
  final String horaFim; // 'HH:mm'
  final String status; // 'CONFIRMADA', 'CANCELADA', etc.
  final String usuarioId;
  final String usuarioNome;
  final String? usuarioEmail;
  final DateTime criadoEm;

  ReservaQuadra({
    required this.id,
    required this.quadraId,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.status,
    required this.usuarioId,
    required this.usuarioNome,
    required this.usuarioEmail,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': Timestamp.fromDate(data),
      'horaInicio': horaInicio,
      'horaFim': horaFim,
      'status': status,
      'usuarioId': usuarioId,
      'usuarioNome': usuarioNome,
      'usuarioEmail': usuarioEmail,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  /// [quadraId] vem de fora (id do doc pai em 'quadras/{id}/reservas')
  factory ReservaQuadra.fromDocument(
    DocumentSnapshot doc, {
    required String quadraId,
  }) {
    final dataMap = doc.data() as Map<String, dynamic>;
    return ReservaQuadra(
      id: doc.id,
      quadraId: quadraId,
      data: (dataMap['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      horaInicio: dataMap['horaInicio'] ?? '',
      horaFim: dataMap['horaFim'] ?? '',
      status: dataMap['status'] ?? '',
      usuarioId: dataMap['usuarioId'] ?? '',
      usuarioNome: dataMap['usuarioNome'] ?? '',
      usuarioEmail: dataMap['usuarioEmail'],
      criadoEm: (dataMap['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ReservaQuadra copyWith({
    String? id,
    String? quadraId,
    DateTime? data,
    String? horaInicio,
    String? horaFim,
    String? status,
    String? usuarioId,
    String? usuarioNome,
    String? usuarioEmail,
    DateTime? criadoEm,
  }) {
    return ReservaQuadra(
      id: id ?? this.id,
      quadraId: quadraId ?? this.quadraId,
      data: data ?? this.data,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
      status: status ?? this.status,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNome: usuarioNome ?? this.usuarioNome,
      usuarioEmail: usuarioEmail ?? this.usuarioEmail,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
