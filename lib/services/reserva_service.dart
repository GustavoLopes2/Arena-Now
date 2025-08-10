import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reserva_quadra.dart';

class ReservaService {
  final _db = FirebaseFirestore.instance;

  Future<void> criarReserva({
    required String quadraId,
    required DateTime data,
    required String horaInicio,
    required String horaFim,
    required String usuarioId,
    required String usuarioNome,
    required String? usuarioEmail,
  }) async {
    final doc =
        _db.collection('quadras').doc(quadraId).collection('reservas').doc();

    await doc.set({
      'data': Timestamp.fromDate(data),
      'horaInicio': horaInicio,
      'horaFim': horaFim,
      'status': 'CONFIRMADA',
      'usuarioId': usuarioId,
      'usuarioNome': usuarioNome,
      'usuarioEmail': usuarioEmail,
      'criadoEm': Timestamp.now(),
    });
  }

  Stream<List<ReservaQuadra>> listarReservas(String quadraId) {
    return _db
        .collection('quadras')
        .doc(quadraId)
        .collection('reservas')
        .orderBy('data')
        .snapshots()
        .map((qs) => qs.docs
            .map((doc) => ReservaQuadra.fromDocument(doc, quadraId: quadraId))
            .toList());
  }

  Stream<List<ReservaQuadra>> listarReservasFuturas(String quadraId) {
    final hoje = DateTime.now();

    return _db
        .collection('quadras')
        .doc(quadraId)
        .collection('reservas')
        .where(
          'data',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(hoje.year, hoje.month, hoje.day),
          ),
        )
        .orderBy('data')
        .snapshots()
        .map(
          (qs) => qs.docs
              .map((doc) => ReservaQuadra.fromDocument(doc, quadraId: quadraId))
              .toList(),
        );
  }

  Stream<List<ReservaQuadra>> listarReservasDeEstabelecimento(
      String estabelecimentoId) {
    return _db
        .collection('quadras')
        .where('estabelecimentoId', isEqualTo: estabelecimentoId)
        .snapshots()
        .asyncMap((qsQuadras) async {
      List<ReservaQuadra> todas = [];

      for (var quadraDoc in qsQuadras.docs) {
        final quadraId = quadraDoc.id;
        final nomeQuadra = quadraDoc['nome'] ?? 'Quadra';

        final reservasSnap = await _db
            .collection('quadras')
            .doc(quadraId)
            .collection('reservas')
            .get();

        for (var r in reservasSnap.docs) {
          final reserva = ReservaQuadra.fromDocument(
            r,
            quadraId: quadraId,
            nomeQuadra: nomeQuadra,
          );
          todas.add(reserva);
        }
      }

      return todas;
    });
  }

  Future<void> cancelarReservaAdmin(String quadraId, String reservaId) async {
    await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('reservas')
        .doc(reservaId)
        .update({
      'status': 'CANCELADA_ADMIN',
      'canceladoPor': 'ADMIN',
      'dataCancelamento': Timestamp.now(),
    });
  }

  Stream<List<ReservaQuadra>> listarReservasDoUsuario(String usuarioId) {
    return _db.collection('quadras').snapshots().asyncMap((quadrasSnap) async {
      List<ReservaQuadra> todas = [];

      for (var quadraDoc in quadrasSnap.docs) {
        final quadraId = quadraDoc.id;
        final quadraNome = quadraDoc['nome'] ?? 'Quadra';

        final reservasSnap = await quadraDoc.reference
            .collection('reservas')
            .where('usuarioId', isEqualTo: usuarioId)
            .get();

        for (var r in reservasSnap.docs) {
          final reserva = ReservaQuadra.fromDocument(
            r,
            quadraId: quadraId,
            nomeQuadra: quadraNome,
          );
          todas.add(reserva);
        }
      }

      return todas;
    });
  }

  Future<void> cancelarReservaUsuario(String quadraId, String reservaId) async {
    await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('reservas')
        .doc(reservaId)
        .update({
      'status': 'CANCELADA_USUARIO',
      'dataCancelamento': Timestamp.now(),
    });
  }

  Future<List<Map<String, dynamic>>> buscarReservasDia(
      String quadraId, DateTime dia) async {
    final snap = await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('reservas')
        .where('data',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(DateTime(dia.year, dia.month, dia.day)))
        .where(
          'data',
          isLessThan: Timestamp.fromDate(
            DateTime(dia.year, dia.month, dia.day + 1),
          ),
        )
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }
}
