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
        elevation: 0,
        title: Text(
          nomeEstabelecimento,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                    const Icon(Icons.sports_tennis,
                        color: Colors.white54, size: 70),
                    const SizedBox(height: 20),
                    const Text(
                      "Nenhuma quadra cadastrada.",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
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
                      icon: const Icon(Icons.add),
                      label: const Text("Cadastrar Quadra"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2598C),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
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
                    icon: const Icon(Icons.list),
                    label: const Text("Ver todas as reservas"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2598C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: quadras.length,
                    itemBuilder: (context, index) {
                      final q = quadras[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16243D),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            q.nome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "${_formatModalidade(q.modalidade)}\n${q.descricao}",
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: Colors.white54),
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
        label: const Text("Nova Quadra"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  String _formatModalidade(String modalidade) {
    switch (modalidade) {
      case "BEACH_TENNIS":
        return "Beach Tennis";
      case "FUTEBOL_SOCIETY":
        return "Futebol Society";
      default:
        return modalidade;
    }
  }
}
