import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MinhasReservasPage extends StatefulWidget {
  const MinhasReservasPage({super.key});

  @override
  State<MinhasReservasPage> createState() => _MinhasReservasPageState();
}

class _MinhasReservasPageState extends State<MinhasReservasPage> {
  String filtroStatus = 'TODOS';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        title: const Text('Minhas Reservas'),
        backgroundColor: const Color(0xFF0E1A2F),
        actions: [
          DropdownButton<String>(
            value: filtroStatus,
            dropdownColor: const Color(0xFF1E2D45),
            underline: Container(),
            iconEnabledColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
              DropdownMenuItem(value: 'CONFIRMADA', child: Text('Confirmadas')),
              DropdownMenuItem(
                  value: 'CANCELADA_USUARIO', child: Text('Canceladas')),
              DropdownMenuItem(
                  value: 'CANCELADA_ADMIN',
                  child: Text('Canceladas pelo admin')),
            ],
            onChanged: (value) => setState(() => filtroStatus = value!),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('reservas')
            .where('usuarioId', isEqualTo: user.uid)
            .orderBy('data')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final hoje = DateTime.now();
          final docs = snapshot.data!.docs;

          final futuras = <QueryDocumentSnapshot>[];
          final passadas = <QueryDocumentSnapshot>[];

          for (var doc in docs) {
            final data = (doc['data'] as Timestamp).toDate();
            final status = doc['status'] ?? 'CONFIRMADA';

            if (filtroStatus != 'TODOS' && status != filtroStatus) continue;

            if (data.isBefore(hoje)) {
              passadas.add(doc);
            } else {
              futuras.add(doc);
            }
          }

          return ListView(
            children: [
              if (futuras.isNotEmpty)
                _buildSection('Próximas Reservas', futuras, true),
              if (passadas.isNotEmpty)
                _buildSection('Reservas Passadas', passadas, false),
              if (futuras.isEmpty && passadas.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Nenhuma reserva encontrada.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
      String titulo, List<QueryDocumentSnapshot> reservas, bool podeCancelar) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...reservas.map((doc) {
            final data = (doc['data'] as Timestamp).toDate();
            final horaInicio = doc['horaInicio'] ?? '--:--';
            final horaFim = doc['horaFim'] ?? '--:--';
            final status = doc['status'] ?? 'CONFIRMADA';
            final quadra = doc['quadraNome'] ?? 'Quadra';

            return Card(
              color: const Color(0xFF1E2D45),
              child: ListTile(
                title: Text(
                  quadra,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${DateFormat('dd/MM/yyyy').format(data)} | $horaInicio - $horaFim\nStatus: $status',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: podeCancelar && status == 'CONFIRMADA'
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed: () => _cancelarReserva(doc),
                      )
                    : null,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _cancelarReserva(QueryDocumentSnapshot doc) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: const Text('Cancelar Reserva',
            style: TextStyle(color: Colors.white)),
        content: const Text('Deseja cancelar esta reserva?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF2598C)),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await doc.reference.update({
        'status': 'CANCELADA_USUARIO',
        'dataCancelamento': Timestamp.now(),
      });
    }
  }
}
