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

  Future<List<Map<String, dynamic>>> buscarBloqueios(String quadraId) async {
    final snap = await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('bloqueios')
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }

  Set<String> gerarBloqueios(
    List<Map<String, dynamic>> bloqueios,
    String diaSemana,
    DateTime diaSelecionado,
    int intervalo,
    DateTime Function(String) toTime,
    String Function(DateTime) formatTime,
  ) {
    final result = <String>{};

    for (var b in bloqueios) {
      final tipo = b['tipo'];
      final horaInicio = b['horaInicio'];
      final horaFim = b['horaFim'];

      final dataInicio = (b['dataInicio'] as Timestamp?)?.toDate();
      final dataFim = (b['dataFim'] as Timestamp?)?.toDate();

      bool bloqueia = false;

      if (tipo == 'RECORRENTE' && b['diaSemana'] == diaSemana) {
        bloqueia = true;
      } else if (tipo == 'PONTUAL' &&
          dataInicio != null &&
          dataFim != null &&
          !diaSelecionado.isBefore(dataInicio) &&
          !diaSelecionado.isAfter(dataFim)) {
        bloqueia = true;
      }

      if (bloqueia) {
        var atual = toTime(horaInicio);
        final fim = toTime(horaFim);

        while (atual.isBefore(fim)) {
          result.add(formatTime(atual));
          atual = atual.add(Duration(minutes: intervalo));
        }
      }
    }

    return result;
  }
}
