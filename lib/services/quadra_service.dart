import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/quadra.dart';
import '../models/foto_quadra.dart';

class QuadraService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

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

  Stream<List<Quadra>> listarQuadrasPorEstabelecimento(
      String estabelecimentoId) {
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

  Future<String?> buscarFotoQuadra(String quadraId) async {
    final snap = await _db
        .collection('foto_quadra')
        .where('quadraId', isEqualTo: quadraId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data()['url'];
  }

  Future<String> uploadFotoQuadra(String quadraId, XFile file) async {
    final bytes = await file.readAsBytes();
    final ext = file.name.split(".").last;

    final ref = _storage.ref().child("quadras/$quadraId/foto.$ext");

    await ref.putData(
      bytes,
      SettableMetadata(contentType: "image/$ext"),
    );

    return await ref.getDownloadURL();
  }
}
