import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VisualizarReservasEstabelecimentoPage extends StatefulWidget {
  final String estabelecimentoId;
  final String nomeEstabelecimento;

  const VisualizarReservasEstabelecimentoPage({
    super.key,
    required this.estabelecimentoId,
    required this.nomeEstabelecimento,
  });

  @override
  State<VisualizarReservasEstabelecimentoPage> createState() =>
      _VisualizarReservasEstabelecimentoPageState();
}

class _VisualizarReservasEstabelecimentoPageState
    extends State<VisualizarReservasEstabelecimentoPage> {
  String filtroStatus = 'TODOS';

  String formatDate(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: Text('Reservas - ${widget.nomeEstabelecimento}'),
        actions: [
          DropdownButton<String>(
            value: filtroStatus,
            dropdownColor: const Color(0xFF1E2D45),
            underline: Container(),
            iconEnabledColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
              DropdownMenuItem(value: 'CONFIRMADA', child: Text('Confirmadas')),
              DropdownMenuItem(
                  value: 'CANCELADA_USUARIO',
                  child: Text('Canceladas pelo usuário')),
              DropdownMenuItem(
                  value: 'CANCELADA_ADMIN',
                  child: Text('Canceladas pelo admin')),
            ],
            onChanged: (value) {
              setState(() => filtroStatus = value!);
            },
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('quadras')
            .where('estabelecimentoId', isEqualTo: widget.estabelecimentoId)
            .get(),
        builder: (context, snapshotQuadras) {
          if (!snapshotQuadras.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final quadras = snapshotQuadras.data!.docs;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _carregarReservasDeTodasAsQuadras(quadras),
            builder: (context, snapshotReservas) {
              if (!snapshotReservas.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final todasReservas = snapshotReservas.data!;
              final hoje = DateTime.now();
              final futuras = <Map<String, dynamic>>[];
              final passadas = <Map<String, dynamic>>[];

              for (var reserva in todasReservas) {
                final data = (reserva['data'] as Timestamp?)?.toDate();
                final status = reserva['status'] ?? 'CONFIRMADA';

                if (filtroStatus != 'TODOS' && status != filtroStatus) continue;

                if (data != null) {
                  if (data.isBefore(hoje)) {
                    passadas.add(reserva);
                  } else {
                    futuras.add(reserva);
                  }
                }
              }

              return ListView(
                children: [
                  if (futuras.isNotEmpty)
                    _buildSection('Próximas Reservas', futuras),
                  if (passadas.isNotEmpty)
                    _buildSection('Reservas Anteriores', passadas),
                  if (futuras.isEmpty && passadas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Nenhuma reserva encontrada.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _carregarReservasDeTodasAsQuadras(
      List<QueryDocumentSnapshot> quadras) async {
    List<Map<String, dynamic>> todas = [];

    for (var quadra in quadras) {
      final quadraId = quadra.id;
      final nomeQuadra = quadra['nome'] ?? 'Quadra';

      final reservasSnap = await FirebaseFirestore.instance
          .collection('quadras')
          .doc(quadraId)
          .collection('reservas')
          .get();

      for (var r in reservasSnap.docs) {
        final dados = r.data();
        dados['id'] = r.id;
        dados['quadraId'] = quadraId;
        dados['nomeQuadra'] = nomeQuadra;
        todas.add(dados);
      }
    }

    return todas;
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> reservas) {
    reservas.sort((a, b) {
      final dataA = (a['data'] as Timestamp?)?.toDate() ?? DateTime(2100);
      final dataB = (b['data'] as Timestamp?)?.toDate() ?? DateTime(2100);
      return dataA.compareTo(dataB);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...reservas.map((reserva) {
            final nome = reserva['usuarioNome'] ?? 'Usuário';
            final data = reserva['data'] as Timestamp?;
            final horaInicio = reserva['horaInicio'] ?? '--:--';
            final horaFim = reserva['horaFim'] ?? '--:--';
            final status = reserva['status'] ?? 'CONFIRMADA';
            final nomeQuadra = reserva['nomeQuadra'] ?? 'Quadra';

            return Card(
              color: const Color(0xFF1E2D45),
              child: ListTile(
                title: Text(
                  nome,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${data != null ? formatDate(data) : '--'} | $horaInicio - $horaFim\nStatus: $status\nQuadra: $nomeQuadra',
                  style: const TextStyle(color: Colors.white70),
                ),
                isThreeLine: true,
                trailing: status == 'CONFIRMADA'
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed: () => _confirmarCancelamento(
                            reserva['quadraId'], reserva['id']),
                      )
                    : null,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _confirmarCancelamento(String quadraId, String reservaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: const Text('Cancelar Reserva',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Deseja realmente cancelar esta reserva?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2598C),
            ),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance
          .collection('quadras')
          .doc(quadraId)
          .collection('reservas')
          .doc(reservaId)
          .update({
        'status': 'CANCELADA_ADMIN',
        'canceladoPor': 'ADMIN',
        'dataCancelamento': Timestamp.now(),
      });
    }
  }
}
