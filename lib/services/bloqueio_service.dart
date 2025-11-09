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

  Future<List<BloqueioQuadra>> buscarBloqueios(String quadraId) async {
    final snap = await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('bloqueios')
        .get();

    return snap.docs
        .map((doc) => BloqueioQuadra.fromDocument(doc, quadraId: quadraId))
        .toList();
  }

  Set<String> gerarBloqueios(
    List<BloqueioQuadra> bloqueios,
    String diaSemanaAtual,
    DateTime diaSelecionado,
    int intervalo,
    DateTime Function(String) toTime,
    String Function(DateTime) formatTime,
  ) {
    final bloqueados = <String>{};

    for (var b in bloqueios) {
      if (b.tipo == "PONTUAL") {
        if (b.dataInicio != null && b.dataFim != null) {
          final dentroDoIntervalo = !diaSelecionado.isBefore(b.dataInicio!) &&
              !diaSelecionado.isAfter(b.dataFim!);

          if (dentroDoIntervalo) {
            final inicio = toTime(b.horaInicio);
            final fim = toTime(b.horaFim);

            DateTime atual = inicio;
            while (atual.isBefore(fim)) {
              bloqueados.add(formatTime(atual));
              atual = atual.add(Duration(minutes: intervalo));
            }
          }
        }
      }

      if (b.tipo == "RECORRENTE") {
        final diaPt = mapDiaInglesParaPortugues(b.diaSemana!);

        if (diaPt == diaSemanaAtual) {
          final inicio = toTime(b.horaInicio);
          final fim = toTime(b.horaFim);

          DateTime atual = inicio;
          while (atual.isBefore(fim)) {
            bloqueados.add(formatTime(atual));
            atual = atual.add(Duration(minutes: intervalo));
          }
        }
      }
    }

    return bloqueados;
  }

  String mapDiaInglesParaPortugues(String diaIng) {
    switch (diaIng.toUpperCase()) {
      case "MONDAY":
        return "SEGUNDA";
      case "TUESDAY":
        return "TERCA";
      case "WEDNESDAY":
        return "QUARTA";
      case "THURSDAY":
        return "QUINTA";
      case "FRIDAY":
        return "SEXTA";
      case "SATURDAY":
        return "SABADO";
      case "SUNDAY":
        return "DOMINGO";
      default:
        return "";
    }
  }
}
