import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quadra.dart';
import '../models/foto_quadra.dart';

class QuadraService {
  final _db = FirebaseFirestore.instance;

  Future<String> criarQuadra(Quadra q) async {
    final doc = _db.collection('quadras').doc();
    await doc.set(q.toMap());
    return doc.id;
  }

  Future<void> salvarFotoQuadra(String quadraId, FotoQuadra foto) async {
    final doc = _db.collection('foto_quadra').doc();
    await doc.set({
      'quadraId': quadraId,
      'url': foto.url,
    });
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
