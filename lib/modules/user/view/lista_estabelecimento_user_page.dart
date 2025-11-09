import 'package:arenanow/modules/user/view/visualizar_quadra_user_page.dart';
import 'package:arenanow/widgets/user_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:arenanow/modules/user/navigation/user_navigator.dart';

class ListaEstabelecimentosUserPage extends StatelessWidget {
  const ListaEstabelecimentosUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: const UserAppBar(
        title: "Estabelecimentos",
        showBack: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'ESTABELECIMENTOS',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('estabelecimentos')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final estabelecimentos = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: estabelecimentos.length,
                    itemBuilder: (context, index) {
                      final data = estabelecimentos[index].data()
                          as Map<String, dynamic>;

                      final id = estabelecimentos[index].id;
                      final nome = data['nome'] ?? 'Sem nome';
                      final imagem = data['foto'] ?? '';
                      final modalidade = data['modalidade'] ?? 'Esportes';

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('quadras')
                            .where('estabelecimentoId', isEqualTo: id)
                            .snapshots(),
                        builder: (context, quadrasSnap) {
                          if (!quadrasSnap.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final qtdQuadras = quadrasSnap.data!.docs.length;

                          return _buildEstabelecimentoCard(
                            context: context,
                            nome: nome,
                            imagem: imagem,
                            modalidade: modalidade,
                            qtdQuadras: qtdQuadras.toString(),
                            onTap: () {
                              UserNavigator.push(
                                context,
                                VisualizarQuadraUserPage(
                                  estabelecimentoId: id,
                                  nomeEstabelecimento: nome,
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
          ],
        ),
      ),
    );
  }

  Widget _buildEstabelecimentoCard({
    required BuildContext context,
    required String nome,
    required String imagem,
    required String modalidade,
    required String qtdQuadras,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF16243D),
          borderRadius: BorderRadius.circular(18),
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
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 170,
                    width: double.infinity,
                    color: Colors.grey.shade800,
                    child: imagem.isNotEmpty
                        ? Image.network(imagem, fit: BoxFit.cover)
                        : const Icon(Icons.image,
                            color: Colors.white54, size: 60),
                  ),
                  Container(
                    height: 170,
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
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        modalidade.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF0E1A2F),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
                  Text(
                    nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$qtdQuadras quadras disponíveis",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
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
