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

    await doc.set(a.toMap());
    return doc.id;
  }

  Future<bool> existeAgenda(String quadraId, String diaSemana) async {
    final query = await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('agenda_semanal')
        .where('diaSemana', isEqualTo: diaSemana)
        .get();

    return query.docs.isNotEmpty;
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

  Stream<List<AgendaSemanal>> listarAgendaPorQuadra(String quadraId) {
    return _db
        .collection('quadras')
        .doc(quadraId)
        .collection('agenda_semanal')
        .orderBy('diaSemana')
        .snapshots()
        .map((qs) => qs.docs
            .map((doc) => AgendaSemanal.fromDocument(doc, quadraId: quadraId))
            .toList());
  }

  Future<void> atualizarAgenda(
    String quadraId,
    String agendaId, {
    required String horaInicio,
    required String horaFim,
    required int intervaloMinutos,
  }) async {
    await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('agenda_semanal')
        .doc(agendaId)
        .update({
      'horaInicio': horaInicio,
      'horaFim': horaFim,
      'intervaloMinutos': intervaloMinutos,
    });
  }
}
