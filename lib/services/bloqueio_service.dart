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
}
