import 'package:flutter/material.dart';
import 'package:arenanow/modules/admin/view/visualizar_quadra_page.dart';
import 'package:arenanow/modules/admin/register/register_quadra_page.dart';
import 'package:arenanow/modules/admin/view/visualizar_reservas_estabelecimento_page.dart';

import 'package:arenanow/models/quadra.dart';
import 'package:arenanow/services/quadra_service.dart';

class VisualizarEstabelecimentoPage extends StatelessWidget {
  final String estabelecimentoId;
  final String nomeEstabelecimento;

  const VisualizarEstabelecimentoPage({
    super.key,
    required this.estabelecimentoId,
    required this.nomeEstabelecimento,
  });

  @override
  Widget build(BuildContext context) {
    final quadraService = QuadraService();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: Text(nomeEstabelecimento),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<Quadra>>(
          stream:
              quadraService.listarQuadrasPorEstabelecimento(estabelecimentoId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final quadras = snapshot.data!;

            if (quadras.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nenhuma quadra cadastrada.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterQuadraPage(
                              estabelecimentoId: estabelecimentoId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2598C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cadastrar Quadra'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VisualizarReservasEstabelecimentoPage(
                          estabelecimentoId: estabelecimentoId,
                          nomeEstabelecimento: nomeEstabelecimento,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2598C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.list),
                  label: const Text('Ver todas as reservas'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: quadras.length,
                    itemBuilder: (context, index) {
                      final q = quadras[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16243D),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            q.nome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${q.modalidade}\n${q.descricao}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VisualizarQuadraPage(
                                  quadraId: q.id,
                                  nomeQuadra: q.nome,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFF2598C),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RegisterQuadraPage(estabelecimentoId: estabelecimentoId),
            ),
          );
        },
        label: const Text('Nova Quadra'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
