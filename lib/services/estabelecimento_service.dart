import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/estabelecimento.dart';
import '../models/foto_estabelecimento.dart';

class EstabelecimentoService {
  final _db = FirebaseFirestore.instance;

  Future<String> criarEstabelecimento(Estabelecimento e) async {
    final doc = _db.collection('estabelecimentos').doc();
    await doc.set(e.toMap());
    return doc.id;
  }

  Future<void> adicionarFotoEstabelecimento(
    String estabelecimentoId,
    FotoEstabelecimento foto,
  ) async {
    final doc = _db.collection('foto_estabelecimento').doc();
    await doc.set({
      'estabelecimentoId': estabelecimentoId,
      'url': foto.url,
    });
  }

  Stream<List<Estabelecimento>> listarEstabelecimentos() {
    return _db.collection('estabelecimentos').snapshots().map(
          (qs) =>
              qs.docs.map((doc) => Estabelecimento.fromDocument(doc)).toList(),
        );
  }

  Future<Estabelecimento?> buscarPorId(String id) async {
    final doc = await _db.collection('estabelecimentos').doc(id).get();
    if (!doc.exists) return null;
    return Estabelecimento.fromDocument(doc);
  }
}
