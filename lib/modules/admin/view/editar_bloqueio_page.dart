import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:arenanow/models/bloqueio_quadra.dart';
import 'package:arenanow/services/bloqueio_service.dart';

class EditarBloqueioPage extends StatefulWidget {
  final String quadraId;
  final String bloqueioId;
  final BloqueioQuadra dadosBloqueio;

  const EditarBloqueioPage({
    super.key,
    required this.quadraId,
    required this.bloqueioId,
    required this.dadosBloqueio,
  });

  @override
  State<EditarBloqueioPage> createState() => _EditarBloqueioPageState();
}

class _EditarBloqueioPageState extends State<EditarBloqueioPage> {
  late final TextEditingController motivoController;
  late final TextEditingController horaInicioController;
  late final TextEditingController horaFimController;

  DateTime? dataInicio;
  DateTime? dataFim;

  @override
  void initState() {
    super.initState();

    motivoController = TextEditingController(text: widget.dadosBloqueio.motivo);
    horaInicioController =
        TextEditingController(text: widget.dadosBloqueio.horaInicio);
    horaFimController =
        TextEditingController(text: widget.dadosBloqueio.horaFim);

    dataInicio = widget.dadosBloqueio.dataInicio;
    dataFim = widget.dadosBloqueio.dataFim;
  }

  Future<void> _selecionarDataInicio() async {
    final d = await showDatePicker(
      context: context,
      initialDate: dataInicio ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      setState(() => dataInicio = d);
    }
  }

  Future<void> _selecionarDataFim() async {
    final d = await showDatePicker(
      context: context,
      initialDate: dataFim ?? (dataInicio ?? DateTime.now()),
      firstDate: dataInicio ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      setState(() => dataFim = d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = BloqueioService();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: const Text("Editar Bloqueio"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: motivoController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Motivo",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: horaInicioController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Hora início (ex: 14:00)",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: horaFimController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Hora fim (ex: 16:00)",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.dadosBloqueio.tipo == "PONTUAL") ...[
              ElevatedButton(
                onPressed: _selecionarDataInicio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2598C),
                ),
                child: Text(
                  dataInicio == null
                      ? "Selecionar data início"
                      : "Início: ${DateFormat('dd/MM/yyyy').format(dataInicio!)}",
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _selecionarDataFim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2598C),
                ),
                child: Text(
                  dataFim == null
                      ? "Selecionar data fim"
                      : "Fim: ${DateFormat('dd/MM/yyyy').format(dataFim!)}",
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final atualizado = widget.dadosBloqueio.copyWith(
                  motivo: motivoController.text.trim(),
                  horaInicio: horaInicioController.text.trim(),
                  horaFim: horaFimController.text.trim(),
                  dataInicio: dataInicio,
                  dataFim: dataFim,
                );

                await service.atualizarBloqueio(
                  widget.quadraId,
                  widget.bloqueioId,
                  atualizado,
                );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2598C),
                padding: const EdgeInsets.all(16),
              ),
              child: const Text("Salvar Alterações"),
            ),
          ],
        ),
      ),
    );
  }
}
