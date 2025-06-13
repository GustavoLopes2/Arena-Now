import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:arenanow/modules/admin/register/register_quadra_page.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: Text(nomeEstabelecimento),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('quadras')
              .where('estabelecimentoId', isEqualTo: estabelecimentoId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
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
                                estabelecimentoId: estabelecimentoId),
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

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final nome = data['nome'] ?? 'Sem nome';
                final modalidade = data['modalidade'] ?? '';
                final descricao = data['descricao'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16243D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      nome,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    subtitle: Text(
                      '$modalidade\n$descricao',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
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
