import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bloqueio_quadra.dart';

class BloqueioService {
  final _db = FirebaseFirestore.instance;

  Future<String> criarBloqueio(String quadraId, BloqueioQuadra b) async {
    final doc =
        _db.collection('quadras').doc(quadraId).collection('bloqueios').doc();

    await doc.set(b.toMap());
    return doc.id;
  }

  Future<bool> existeBloqueioNoDia(String quadraId, DateTime data) async {
    final inicio = DateTime(data.year, data.month, data.day);
    final fim = inicio.add(Duration(days: 1));

    final r = await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('bloqueios')
        .where('dataInicio', isGreaterThanOrEqualTo: inicio)
        .where('dataInicio', isLessThan: fim)
        .get();

    return r.docs.isNotEmpty;
  }

  Stream<List<BloqueioQuadra>> listarBloqueios(String quadraId) {
    return _db
        .collection('quadras')
        .doc(quadraId)
        .collection('bloqueios')
        .snapshots()
        .map((qs) => qs.docs
            .map((doc) => BloqueioQuadra.fromDocument(doc, quadraId: quadraId))
            .toList());
  }

  Future<void> deletarBloqueio(String quadraId, String bloqueioId) async {
    await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('bloqueios')
        .doc(bloqueioId)
        .delete();
  }

  Future<void> atualizarBloqueio(
    String quadraId,
    String bloqueioId,
    BloqueioQuadra b,
  ) async {
    await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('bloqueios')
        .doc(bloqueioId)
        .update(b.toMap());
  }
}
