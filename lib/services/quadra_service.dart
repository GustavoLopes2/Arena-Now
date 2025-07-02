import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quadra.dart';

class QuadraService {
  final _db = FirebaseFirestore.instance;

  Future<String> criarQuadra(Quadra q) async {
    final doc = _db.collection('quadras').doc();
    await doc.set(q.copyWith(id: doc.id).toMap());
    return doc.id;
  }

  Stream<List<Quadra>> listarQuadras(String estabelecimentoId) {
    return _db
        .collection('quadras')
        .where('estabelecimentoId', isEqualTo: estabelecimentoId)
        .snapshots()
        .map((qs) => qs.docs.map((doc) => Quadra.fromDocument(doc)).toList());
  }

  Future<Quadra?> buscarPorId(String id) async {
    final doc = await _db.collection('quadras').doc(id).get();
    if (!doc.exists) return null;
    return Quadra.fromDocument(doc);
  }
}
