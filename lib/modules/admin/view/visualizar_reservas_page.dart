import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: Text('Reservas - $quadraNome'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quadras')
            .doc(quadraId)
            .collection('reservas')
            .where('data', isGreaterThanOrEqualTo: Timestamp.now())
            .orderBy('data')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma reserva futura encontrada.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final Map<String, List<Map<String, dynamic>>> reservasPorData = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['data'] as Timestamp?;
            if (timestamp == null) continue;

            final dataFormatada =
                DateFormat('dd/MM/yyyy').format(timestamp.toDate());
            reservasPorData.putIfAbsent(dataFormatada, () => []).add(data);
          }

          return ListView(
            children: reservasPorData.entries.map((entry) {
              final dataStr = entry.key;
              final reservas = entry.value;

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
                    ...reservas.map((reserva) {
                      final nome = reserva['usuarioNome'] ?? 'Usuário';
                      final horaInicio = reserva['horaInicio'] ?? '--:--';
                      final horaFim = reserva['horaFim'] ?? '--:--';
                      final status = reserva['status'] ?? 'confirmada';

                      return Card(
                        color: const Color(0xFF1E2D45),
                        child: ListTile(
                          title: Text(
                            nome,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '$horaInicio - $horaFim\nStatus: $status',
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
