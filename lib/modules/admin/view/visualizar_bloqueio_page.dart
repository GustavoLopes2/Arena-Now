import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'editar_bloqueio_page.dart';

class ListarBloqueiosPage extends StatelessWidget {
  final String quadraId;

  const ListarBloqueiosPage({super.key, required this.quadraId});

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '---';
    return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: const Text('Bloqueios da Quadra'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quadras')
            .doc(quadraId)
            .collection('bloqueios')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum bloqueio cadastrado.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final tipo = data['tipo'] ?? 'N/A';
              final motivo = data['motivo'] ?? 'Sem motivo';
              final horaInicio = data['horaInicio'] ?? '00:00';
              final horaFim = data['horaFim'] ?? '00:00';
              final diaSemana = data['diaSemana'];
              final dataInicio = data['dataInicio'] as Timestamp?;
              final dataFim = data['dataFim'] as Timestamp?;

              final isRecorrente = tipo == 'RECORRENTE';

              return Card(
                color: const Color(0xFF1E2D45),
                child: ListTile(
                  title: Text(
                    isRecorrente
                        ? 'Recorrente: $diaSemana'
                        : 'Pontual: ${formatDate(dataInicio)} até ${formatDate(dataFim)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '$motivo\n$horaInicio - $horaFim',
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
                                bloqueioId: docs[index].id,
                                dadosBloqueio: data,
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
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: const Text(
                                  'Deseja realmente excluir este bloqueio?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                ),
                                ElevatedButton(
                                  child: const Text('Excluir'),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await FirebaseFirestore.instance
                                .collection('quadras')
                                .doc(quadraId)
                                .collection('bloqueios')
                                .doc(docs[index].id)
                                .delete();
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
