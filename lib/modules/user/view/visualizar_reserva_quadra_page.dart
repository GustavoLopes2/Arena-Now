import 'package:arenanow/modules/user/view/reserva_detalhe_page.dart';
import 'package:arenanow/widgets/user_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: const UserAppBar(
        title: "Minhas Reservas",
        showBack: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FILTRO',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                DropdownButton<String>(
                  value: filtroStatus,
                  dropdownColor: const Color(0xFF1E2D45),
                  style: const TextStyle(color: Colors.white),
                  underline: Container(),
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
                  onChanged: (v) {
                    setState(() => filtroStatus = v!);
                  },
                ),
              ],
            ),
          ),
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
                  if (filtroStatus != 'TODOS' && r.status != filtroStatus)
                    continue;

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
          ...reservas.map((r) => _buildReservaCard(r, podeCancelar)),
        ],
      ),
    );
  }

  Widget _buildReservaCard(ReservaQuadra r, bool podeCancelar) {
    final statusColor = _getStatusColor(r.status);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final bool podeCancelarReserva =
        podeCancelar && r.status == "CONFIRMADA" && r.usuarioId == userId;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReservaDetalhePage(
              reserva: r,
              podeCancelar: podeCancelarReserva,
            ),
          ),
        );

        if (result == true && mounted) {
          setState(() {});
        }
      },
      child: _buildReservaCardContent(r, statusColor),
    );
  }

  Widget _buildReservaCardContent(ReservaQuadra r, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.sports_soccer, color: statusColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  r.nomeQuadra ?? "Quadra",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd/MM/yyyy').format(r.data),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "${r.horaInicio} - ${r.horaFim}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "CONFIRMADA":
        return Colors.greenAccent.shade400;
      case "CANCELADA_USUARIO":
        return Colors.orangeAccent.shade200;
      case "CANCELADA_ADMIN":
        return Colors.redAccent.shade200;
      default:
        return Colors.white70;
    }
  }
}
