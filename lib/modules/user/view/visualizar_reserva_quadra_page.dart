import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arenanow/widgets/dashboard_header.dart';

import 'package:arenanow/services/reserva_service.dart';
import 'package:arenanow/models/reserva_quadra.dart';

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
        body: Center(child: Text("Usuário não autenticado.")),
      );
    }

    final reservaService = ReservaService();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const DashboardHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MINHAS RESERVAS',
                  style: TextStyle(
                      color: Colors.white60, fontSize: 14, letterSpacing: 1.5),
                ),
                DropdownButton<String>(
                  value: filtroStatus,
                  dropdownColor: const Color(0xFF1E2D45),
                  underline: Container(),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                  items: const [
                    DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
                    DropdownMenuItem(
                        value: 'CONFIRMADA', child: Text('Confirmadas')),
                    DropdownMenuItem(
                        value: 'CANCELADA_USUARIO',
                        child: Text('Canceladas por você')),
                    DropdownMenuItem(
                        value: 'CANCELADA_ADMIN',
                        child: Text('Canceladas pelo admin')),
                  ],
                  onChanged: (v) => setState(() => filtroStatus = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<ReservaQuadra>>(
              stream: reservaService.listarReservasDoUsuario(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reservas = snapshot.data!;
                final hoje = DateTime.now();

                List<ReservaQuadra> futuras = [];
                List<ReservaQuadra> passadas = [];

                for (var r in reservas) {
                  if (filtroStatus != 'TODOS' && r.status != filtroStatus) {
                    continue;
                  }

                  if (r.data.isBefore(hoje)) {
                    passadas.add(r);
                  } else {
                    futuras.add(r);
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
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<ReservaQuadra> reservas, bool podeCancelar) {
    reservas.sort((a, b) => a.data.compareTo(b.data));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...reservas.map((r) {
            return Card(
              color: const Color(0xFF1E2D45),
              child: ListTile(
                title: Text(
                  r.nomeQuadra ?? "Quadra",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "${DateFormat('dd/MM/yyyy').format(r.data)} | ${r.horaInicio} - ${r.horaFim}\nStatus: ${r.status}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: podeCancelar && r.status == "CONFIRMADA"
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed: () => _confirmarCancelamento(r),
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _confirmarCancelamento(ReservaQuadra r) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: const Text("Cancelar Reserva",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "Deseja realmente cancelar esta reserva?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Não"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Sim, cancelar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ReservaService().cancelarReservaUsuario(r.quadraId, r.id);
    }
  }
}
