import 'package:flutter/material.dart';
import 'package:arenanow/modules/user/register/register_reserva_quadra_page.dart';
import 'package:arenanow/widgets/user_bottom_navigation.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          nomeEstabelecimento,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: const UserBottomNavigation(currentIndex: 0),
      body: StreamBuilder<List<Quadra>>(
        stream:
            quadraService.listarQuadrasPorEstabelecimento(estabelecimentoId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final quadras = snapshot.data!;
          if (quadras.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma quadra cadastrada.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quadras.length,
            itemBuilder: (context, index) {
              final q = quadras[index];

              return FutureBuilder<String?>(
                future: quadraService.buscarFotoQuadra(q.id),
                builder: (context, snap) {
                  final foto = snap.data;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16243D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: foto != null
                            ? Image.network(
                                foto,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[700],
                                child: const Icon(Icons.image,
                                    color: Colors.white),
                              ),
                      ),
                      title: Text(
                        q.nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "Modalidade: ${q.modalidade}\n${q.descricao}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReservarQuadraPage(
                              quadraId: q.id,
                              quadraNome: q.nome,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
