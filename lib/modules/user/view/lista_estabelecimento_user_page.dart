import 'package:flutter/material.dart';
import 'package:arenanow/widgets/dashboard_header.dart';

import 'package:arenanow/models/estabelecimento.dart';
import 'package:arenanow/services/estabelecimento_service.dart';
import 'package:arenanow/modules/user/view/visualizar_estabelecimento_user_page.dart';

class ListaEstabelecimentosUserPage extends StatelessWidget {
  const ListaEstabelecimentosUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = EstabelecimentoService();

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
              child: StreamBuilder<List<Estabelecimento>>(
                stream: service.listarEstabelecimentos(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final lista = snapshot.data!;

                  if (lista.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nenhum estabelecimento encontrado.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final est = lista[index];

                      return FutureBuilder<List<dynamic>>(
                        future: Future.wait([
                          service.buscarFoto(est.id),
                          service.contarQuadras(est.id),
                        ]),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: LinearProgressIndicator(),
                            );
                          }

                          final foto = snap.data![0] as String?;
                          final qtdQuadras = snap.data![1] as int;

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
                                est.nome,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${qtdQuadras} quadras\n${est.endereco}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VisualizarEstabelecimentoPage(
                                      estabelecimentoId: est.id,
                                      nomeEstabelecimento: est.nome,
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
            ),
          ],
        ),
      ),
    );
  }
}
