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

  Color _statusColor(String status) {
    switch (status) {
      case "CONFIRMADA":
        return Colors.greenAccent.shade400;
      case "CANCELADA_USUARIO":
        return Colors.orangeAccent.shade200;
      case "CANCELADA_ADMIN":
        return Colors.redAccent.shade200;
      default:
        return Colors.white70;
    }
  }

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
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final Map<String, List<ReservaQuadra>> reservasPorData = {};

          for (var r in reservas) {
            final dataStr = DateFormat('dd/MM/yyyy').format(r.data);
            reservasPorData.putIfAbsent(dataStr, () => []).add(r);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: reservasPorData.entries.map((entry) {
              final dataStr = entry.key;
              final lista = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, top: 12),
                    child: Text(
                      dataStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ...lista.map((reserva) {
                    final color = _statusColor(reserva.status);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16243D),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.18),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.person, color: color),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    reserva.usuarioNome,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    reserva.status.replaceAll("_", " "),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.schedule,
                                        color: Colors.white70, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${reserva.horaInicio} - ${reserva.horaFim}",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.email,
                                        color: Colors.white70, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      reserva.usuarioEmail ?? "Sem e-mail",
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList()
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
