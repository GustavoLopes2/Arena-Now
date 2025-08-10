import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/agenda_semanal.dart';
import '../models/bloqueio_quadra.dart';
import '../models/reserva_quadra.dart';

class QuadraHorariosService {
  final _db = FirebaseFirestore.instance;

  Future<List<String>> obterHorariosDisponiveis(
    String quadraId,
    DateTime diaSelecionado,
  ) async {
    final String diaSemana = _mapDiaSemana(diaSelecionado);

    final agendaDocs = await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('agenda_semanal')
        .where('diaSemana', isEqualTo: diaSemana)
        .get();

    if (agendaDocs.docs.isEmpty) return [];

    final agenda = agendaDocs.docs
        .map((doc) => AgendaSemanal.fromDocument(doc, quadraId: quadraId))
        .toList();

    final a = agenda.first;

    List<String> horariosGerados = [];
    DateTime atual = _toTime(a.horaInicio);
    final fim = _toTime(a.horaFim);

    while (atual.isBefore(fim)) {
      horariosGerados.add(_formatTime(atual));
      atual = atual.add(Duration(minutes: a.intervaloMinutos));
    }

    final bloqueiosDocs = await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('bloqueios')
        .get();

    final bloqueios = bloqueiosDocs.docs
        .map((d) => BloqueioQuadra.fromDocument(d, quadraId: quadraId))
        .toList();

    final bloqueados = <String>{};

    for (var b in bloqueios) {
      bool ativo = false;

      if (b.tipo == "RECORRENTE" && b.diaSemana == diaSemana) {
        ativo = true;
      } else if (b.tipo == "PONTUAL" &&
          b.dataInicio != null &&
          b.dataFim != null &&
          !diaSelecionado.isBefore(b.dataInicio!) &&
          !diaSelecionado.isAfter(b.dataFim!)) {
        ativo = true;
      }

      if (ativo) {
        DateTime atual = _toTime(b.horaInicio);
        final fim = _toTime(b.horaFim);
        while (atual.isBefore(fim)) {
          bloqueados.add(_formatTime(atual));
          atual = atual.add(Duration(minutes: a.intervaloMinutos));
        }
      }
    }

    final inicioDia =
        DateTime(diaSelecionado.year, diaSelecionado.month, diaSelecionado.day);
    final fimDia = inicioDia.add(Duration(days: 1));

    final reservasDocs = await _db
        .collection('quadras')
        .doc(quadraId)
        .collection('reservas')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
        .where('data', isLessThan: Timestamp.fromDate(fimDia))
        .get();

    final reservados = <String>{};

    for (var r in reservasDocs.docs) {
      final reserva = ReservaQuadra.fromDocument(r, quadraId: quadraId);

      DateTime atual = _toTime(reserva.horaInicio);
      final fim = _toTime(reserva.horaFim);

      while (atual.isBefore(fim)) {
        reservados.add(_formatTime(atual));
        atual = atual.add(Duration(minutes: a.intervaloMinutos));
      }
    }

    return horariosGerados
        .where((h) => !bloqueados.contains(h) && !reservados.contains(h))
        .toList();
  }

  String _mapDiaSemana(DateTime date) {
    final dias = [
      'SEGUNDA',
      'TERCA',
      'QUARTA',
      'QUINTA',
      'SEXTA',
      'SABADO',
      'DOMINGO',
    ];
    return dias[date.weekday - 1];
  }

  DateTime _toTime(String hora) {
    final parts = hora.split(':');
    return DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatTime(DateTime t) {
    return DateFormat.Hm().format(t);
  }
}
