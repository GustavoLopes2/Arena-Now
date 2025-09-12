import 'package:arenanow/widgets/user_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:arenanow/models/quadra.dart';
import 'package:arenanow/services/quadra_service.dart';
import 'package:arenanow/modules/user/register/register_reserva_quadra_page.dart';

class VisualizarQuadraUserPage extends StatelessWidget {
  final String estabelecimentoId;
  final String nomeEstabelecimento;

  const VisualizarQuadraUserPage({
    super.key,
    required this.estabelecimentoId,
    required this.nomeEstabelecimento,
  });

  @override
  Widget build(BuildContext context) {
    final quadraService = QuadraService();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: const UserAppBar(title: "Quadras", showBack: true),
      body: SafeArea(
        child: StreamBuilder<List<Quadra>>(
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
                  'Nenhuma quadra cadastrada.',
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
                    final foto = snap.data ?? "";

                    return _buildQuadraCard(
                      context: context,
                      nome: q.nome,
                      descricao: q.descricao,
                      modalidade: q.modalidade,
                      fotoUrl: foto,
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
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuadraCard({
    required BuildContext context,
    required String nome,
    required String descricao,
    required String modalidade,
    required String fotoUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16243D),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey.shade800,
                    child: fotoUrl.isNotEmpty
                        ? Image.network(fotoUrl, fit: BoxFit.cover)
                        : const Icon(Icons.image,
                            color: Colors.white54, size: 60),
                  ),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        modalidade,
                        style: const TextStyle(
                          color: Color(0xFF0E1A2F),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
