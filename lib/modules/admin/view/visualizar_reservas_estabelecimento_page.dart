import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:arenanow/models/reserva_quadra.dart';
import 'package:arenanow/services/reserva_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final reservaService = ReservaService();

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
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
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
            onChanged: (val) => setState(() => filtroStatus = val!),
          ),
        ],
      ),
      body: StreamBuilder<List<ReservaQuadra>>(
        stream: reservaService
            .listarReservasDeEstabelecimento(widget.estabelecimentoId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservas = snapshot.data!;
          final hoje = DateTime.now();

          List<ReservaQuadra> futuras = [];
          List<ReservaQuadra> passadas = [];

          for (var r in reservas) {
            if (filtroStatus != 'TODOS' && r.status != filtroStatus) continue;

            if (r.data.isBefore(hoje)) {
              passadas.add(r);
            } else {
              futuras.add(r);
            }
          }

          return ListView(
            children: [
              if (futuras.isNotEmpty)
                _buildSection("Próximas Reservas", futuras),
              if (passadas.isNotEmpty)
                _buildSection("Reservas Anteriores", passadas),
              if (futuras.isEmpty && passadas.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "Nenhuma reserva encontrada.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<ReservaQuadra> reservas) {
    reservas.sort((a, b) => a.data.compareTo(b.data));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          ...reservas.map((r) {
            return Card(
              color: const Color(0xFF1E2D45),
              child: ListTile(
                title: Text(
                  r.usuarioNome,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "${DateFormat('dd/MM/yyyy').format(r.data)} | "
                  "${r.horaInicio} - ${r.horaFim}\n"
                  "Status: ${r.status}\n"
                  "Quadra: ${r.nomeQuadra ?? '---'}",
                  style: const TextStyle(color: Colors.white70),
                ),
                isThreeLine: true,
                trailing: r.status == "CONFIRMADA"
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed: () =>
                            _confirmarCancelamento(r.quadraId, r.id),
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _confirmarCancelamento(String quadraId, String reservaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: const Text("Cancelar Reserva",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "Deseja realmente cancelar esta reserva?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Não"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Sim, cancelar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ReservaService().cancelarReservaAdmin(quadraId, reservaId);
    }
  }
}
