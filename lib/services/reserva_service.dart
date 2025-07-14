import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reserva_quadra.dart';

class ReservaService {
  final _db = FirebaseFirestore.instance;

  Future<void> criarReserva(String quadraId, ReservaQuadra r) async {
    final doc =
        _db.collection('quadras').doc(quadraId).collection('reservas').doc();

    await doc.set(r.toMap());
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
}
