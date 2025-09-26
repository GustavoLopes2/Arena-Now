import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  final _storage = FirebaseStorage.instance;

  Future<String?> uploadImagem({
    required File file,
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      await ref.putFile(file);

      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Erro ao enviar imagem: $e");
      return null;
    }
  }

  Future<void> deletarImagem(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e) {
      print("Erro ao deletar imagem: $e");
    }
  }
}
