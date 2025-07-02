import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agenda_semanal.dart';

class AgendaService {
  final _db = FirebaseFirestore.instance;

  Future<String> criarAgenda(String quadraId, AgendaSemanal a) async {
    final doc = _db
        .collection('quadras')
        .doc(quadraId)
        .collection('agenda_semanal')
        .doc();

    await doc.set(a.copyWith(id: doc.id).toMap());
    return doc.id;
  }

  Stream<List<AgendaSemanal>> listarAgenda(String quadraId) {
    return _db
        .collection('quadras')
        .doc(quadraId)
        .collection('agenda_semanal')
        .snapshots()
        .map((qs) => qs.docs
            .map((doc) => AgendaSemanal.fromDocument(doc, quadraId: quadraId))
            .toList());
  }
}
