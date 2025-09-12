import 'package:arenanow/widgets/user_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arenanow/models/reserva_quadra.dart';
import 'package:arenanow/services/reserva_service.dart';

class ReservaDetalhePage extends StatelessWidget {
  final ReservaQuadra reserva;
  final bool podeCancelar;

  const ReservaDetalhePage({
    super.key,
    required this.reserva,
    required this.podeCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(reserva.status);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar:
          UserAppBar(title: reserva.nomeQuadra ?? "Detalhes", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16243D),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sports_soccer, color: statusColor, size: 26),
                        const SizedBox(width: 10),
                        Text(
                          reserva.nomeQuadra ?? "Quadra",
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoItem(Icons.calendar_month, "Data",
                            DateFormat('dd/MM/yyyy').format(reserva.data)),
                        const SizedBox(height: 12),
                        _infoItem(Icons.schedule, "Horário",
                            "${reserva.horaInicio} - ${reserva.horaFim}"),
                        const SizedBox(height: 12),
                        _infoItem(
                            Icons.person, "Reservado por", reserva.usuarioNome),
                        const SizedBox(height: 12),
                        _infoItem(Icons.email, "E-mail",
                            reserva.usuarioEmail ?? "Não informado"),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            reserva.status.replaceAll("_", " "),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (podeCancelar)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirmarCancelamento(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2598C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cancelar Reserva",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
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

  Future<void> _confirmarCancelamento(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: const Text(
          "Cancelar Reserva",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Deseja realmente cancelar esta reserva?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Não"),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          ElevatedButton(
            child: const Text("Sim, cancelar"),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ReservaService().cancelarReservaUsuario(
        reserva.quadraId,
        reserva.id,
      );

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reserva cancelada com sucesso!"),
        ),
      );
    }
  }
}
