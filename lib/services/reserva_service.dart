import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reserva_quadra.dart';

class ReservaService {
  final _db = FirebaseFirestore.instance;

  Future<String> criarReserva(String quadraId, ReservaQuadra r) async {
    final reservas =
        _db.collection('quadras').doc(quadraId).collection('reservas');

    final conflitos = await reservas
        .where('data', isEqualTo: Timestamp.fromDate(r.data))
        .get();

    for (var doc in conflitos.docs) {
      final existente = ReservaQuadra.fromDocument(
        doc,
        quadraId: quadraId,
      );

      if (_temConflito(existente, r)) {
        throw Exception('Horário já reservado.');
      }
    }

    final doc = reservas.doc();
    await doc.set(r.toMap());
    return doc.id;
  }

  bool _temConflito(ReservaQuadra a, ReservaQuadra b) {
    final inicioA = _horaToInt(a.horaInicio);
    final fimA = _horaToInt(a.horaFim);
    final inicioB = _horaToInt(b.horaInicio);
    final fimB = _horaToInt(b.horaFim);

    return !(fimB <= inicioA || inicioB >= fimA);
  }

  int _horaToInt(String h) {
    final parts = h.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Stream<List<ReservaQuadra>> listarReservas(
    String quadraId,
    DateTime dia,
  ) {
    return _db
        .collection('quadras')
        .doc(quadraId)
        .collection('reservas')
        .where('data', isEqualTo: Timestamp.fromDate(dia))
        .snapshots()
        .map((qs) => qs.docs
            .map((doc) => ReservaQuadra.fromDocument(
                  doc,
                  quadraId: quadraId,
                ))
            .toList());
  }
}
