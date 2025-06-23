import 'package:arenanow/modules/user/register/register_reserva_quadra_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        title: Text(nomeEstabelecimento),
        backgroundColor: const Color(0xFF0E1A2F),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quadras')
            .where('estabelecimentoId', isEqualTo: estabelecimentoId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final quadras = snapshot.data?.docs ?? [];

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
              final data = quadras[index].data() as Map<String, dynamic>;
              final nome = data['nome'] ?? 'Sem nome';
              final descricao = data['descricao'] ?? '';
              final modalidade = data['modalidade'] ?? 'N/A';
              final imagem = data['foto'] ?? '';

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
                            child: const Icon(Icons.image, color: Colors.white),
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
                    'Modalidade: $modalidade\n$descricao',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservarQuadraPage(
                          quadraId: quadras[index].id,
                          quadraNome: nome,
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
    );
  }
}
