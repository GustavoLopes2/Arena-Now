import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reserva_quadra.dart';

class ReservaService {
  final _db = FirebaseFirestore.instance;

  Future<void> criarReserva(String quadraId, ReservaQuadra r) async {
    final doc =
        _db.collection('quadras').doc(quadraId).collection('reservas').doc();

    await doc.set(r.toMap());
  }
}
