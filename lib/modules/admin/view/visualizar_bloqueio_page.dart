import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:arenanow/models/bloqueio_quadra.dart';
import 'package:arenanow/services/bloqueio_service.dart';

import 'editar_bloqueio_page.dart';

class ListarBloqueiosPage extends StatelessWidget {
  final String quadraId;

  const ListarBloqueiosPage({super.key, required this.quadraId});

  String formatDate(DateTime? date) {
    if (date == null) return '---';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final service = BloqueioService();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: const Text('Bloqueios da Quadra'),
      ),
      body: StreamBuilder<List<BloqueioQuadra>>(
        stream: service.listarBloqueios(quadraId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bloqueios = snapshot.data!;
          if (bloqueios.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum bloqueio cadastrado.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: bloqueios.length,
            itemBuilder: (context, index) {
              final b = bloqueios[index];

              final bool recorrente = b.tipo == "RECORRENTE";

              final titulo = recorrente
                  ? "Recorrente: ${b.diaSemana}"
                  : "Pontual: ${formatDate(b.dataInicio)} até ${formatDate(b.dataFim)}";

              final horario = "${b.horaInicio} - ${b.horaFim}";

              return Card(
                color: const Color(0xFF1E2D45),
                child: ListTile(
                  title: Text(
                    titulo,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "${b.motivo}\n$horario",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditarBloqueioPage(
                                quadraId: quadraId,
                                bloqueioId: b.id,
                                dadosBloqueio: b,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: const Text(
                                'Deseja realmente excluir este bloqueio?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await service.deletarBloqueio(quadraId, b.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
