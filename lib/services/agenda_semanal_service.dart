import 'package:cloud_firestore/cloud_firestore.dart';

class AgendaSemanalService {
  final _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> buscarAgendaDia(
      String quadraId, String diaSemana) async {
    final snap = await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('agenda_semanal')
        .where('diaSemana', isEqualTo: diaSemana)
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }

  List<String> gerarHorariosPossiveis(List<Map<String, dynamic>> agendaList) {
    final List<String> horarios = [];

    for (var a in agendaList) {
      final inicio = _toTime(a['horaInicio']);
      final fim = _toTime(a['horaFim']);
      final intervalo = a['intervaloMinutos'] as int;

      var atual = inicio;

      while (atual.isBefore(fim)) {
        horarios.add(_formatTime(atual));
        atual = atual.add(Duration(minutes: intervalo));
      }
    }

    return horarios;
  }

  DateTime _toTime(String h) {
    final p = h.split(":");
    return DateTime(0, 0, 0, int.parse(p[0]), int.parse(p[1]));
  }

  String _formatTime(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }
}
