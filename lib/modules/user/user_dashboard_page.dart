import 'package:arenanow/modules/user/view/visualizar_estabelecimento_user_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:arenanow/widgets/dashboard_header.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E1A2F),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(color: Colors.white10, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFF2598C),
          unselectedItemColor: Colors.white38,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
          currentIndex: 0,
          onTap: (_) {},
        ),
      ),
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
                    itemCount: estabelecimentos.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final data = estabelecimentos[index].data()
                          as Map<String, dynamic>;
                      final doc = estabelecimentos[index];
                      final nome = data['nome'] ?? 'Sem nome';
                      final descricao = data['descricao'] ?? '';
                      final imagem = data['foto'] ?? '';
                      final modalidade = data['modalidade'] ?? 'Modalidade';
                      final quantidade = data['qtdQuadras']?.toString() ?? '?';

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
                                ? Image.network(imagem,
                                    width: 60, height: 60, fit: BoxFit.cover)
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[700],
                                    child: const Icon(Icons.image,
                                        color: Colors.white),
                                  ),
                          ),
                          title: Text(
                            nome,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          subtitle: Text(
                            '$quantidade quadras de $modalidade',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VisualizarEstabelecimentoPage(
                                  estabelecimentoId: doc.id,
                                  nomeEstabelecimento: nome,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
