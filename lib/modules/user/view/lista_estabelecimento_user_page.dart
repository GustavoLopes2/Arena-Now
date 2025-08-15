import 'package:arenanow/modules/user/view/visualizar_quadra_user_page.dart';
import 'package:arenanow/widgets/dashboard_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:arenanow/modules/user/navigation/user_navigator.dart';

class ListaEstabelecimentosUserPage extends StatelessWidget {
  const ListaEstabelecimentosUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),
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
                      final modalidade = data['modalidade'] ?? '';
                      final qtdQuadras = data['qtdQuadras']?.toString() ?? '?';

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
                            child: imagem.isNotEmpty
                                ? Image.network(
                                    imagem,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[700],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          title: Text(
                            nome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '$qtdQuadras quadras • $modalidade',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () {
                            UserNavigator.push(
                              context,
                              VisualizarQuadraUserPage(
                                estabelecimentoId: id,
                                nomeEstabelecimento: nome,
                              ),
                            );
                          },
                        ),
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
}
