import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:arenanow/models/reserva_quadra.dart';
import 'package:arenanow/services/reserva_service.dart';

class VisualizarReservasPage extends StatelessWidget {
  final String quadraId;
  final String quadraNome;

  const VisualizarReservasPage({
    super.key,
    required this.quadraId,
    required this.quadraNome,
  });

  @override
  Widget build(BuildContext context) {
    final reservaService = ReservaService();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: Text("Reservas - $quadraNome"),
      ),
      body: StreamBuilder<List<ReservaQuadra>>(
        stream: reservaService.listarReservasFuturas(quadraId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservas = snapshot.data!;
          if (reservas.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma reserva futura encontrada.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final Map<String, List<ReservaQuadra>> reservasPorData = {};

          for (var r in reservas) {
            final dataStr = DateFormat('dd/MM/yyyy').format(r.data);
            reservasPorData.putIfAbsent(dataStr, () => []).add(r);
          }

          return ListView(
            children: reservasPorData.entries.map((entry) {
              final dataStr = entry.key;
              final lista = entry.value;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dataStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...lista.map((reserva) {
                      return Card(
                        color: const Color(0xFF1E2D45),
                        child: ListTile(
                          title: Text(
                            reserva.usuarioNome,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${reserva.horaInicio} - ${reserva.horaFim}\nStatus: ${reserva.status}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
