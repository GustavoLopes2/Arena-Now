import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VisualizarQuadraPage extends StatelessWidget {
  final String quadraId;
  final String nomeQuadra;

  const VisualizarQuadraPage({
    super.key,
    required this.quadraId,
    required this.nomeQuadra,
  });

  void _abrirDialogEdicao(BuildContext context, String agendaId, String dia,
      String inicio, String fim, int intervalo) {
    final inicioController = TextEditingController(text: inicio);
    final fimController = TextEditingController(text: fim);
    final intervaloController =
        TextEditingController(text: intervalo.toString());

    bool validarHorario(String inicio, String fim) {
      final inicioParts = inicio.split(':').map(int.parse).toList();
      final fimParts = fim.split(':').map(int.parse).toList();
      final inicioMin = inicioParts[0] * 60 + inicioParts[1];
      final fimMin = fimParts[0] * 60 + fimParts[1];
      return fimMin > inicioMin;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: Text('Editar $dia', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: inicioController,
              decoration: const InputDecoration(labelText: 'Hora Início'),
            ),
            TextField(
              controller: fimController,
              decoration: const InputDecoration(labelText: 'Hora Fim'),
            ),
            TextField(
              controller: intervaloController,
              decoration: const InputDecoration(labelText: 'Intervalo'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              final horaInicio = inicioController.text.trim();
              final horaFim = fimController.text.trim();
              final intervaloTexto = intervaloController.text.trim();

              if (!validarHorario(horaInicio, horaFim)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Horário final deve ser maior que o horário inicial'),
                  ),
                );
                return;
              }

              await FirebaseFirestore.instance
                  .collection('quadras')
                  .doc(quadraId)
                  .collection('agenda_semanal')
                  .doc(agendaId)
                  .update({
                'horaInicio': horaInicio,
                'horaFim': horaFim,
                'intervaloMinutos': int.parse(intervaloTexto),
              });

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2598C),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: Text(nomeQuadra),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Horários Cadastrados',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('quadras')
                    .doc(quadraId)
                    .collection('agenda_semanal')
                    .orderBy('diaSemana')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum horário cadastrado.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final dia = data['diaSemana'];
                      final inicio = data['horaInicio'];
                      final fim = data['horaFim'];
                      final intervalo = data['intervaloMinutos'];

                      return Card(
                        color: const Color(0xFF1E2D45),
                        child: ListTile(
                          title: Text(
                            dia,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Das $inicio às $fim • $intervalo min',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              _abrirDialogEdicao(context, docs[index].id, dia,
                                  inicio, fim, intervalo);
                            },
                          ),
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
