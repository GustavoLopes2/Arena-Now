class FotoEstabelecimento {
  final String id;
  final String estabelecimentoId;
  final String url;

  FotoEstabelecimento({
    required this.id,
    required this.estabelecimentoId,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'estabelecimentoId': estabelecimentoId,
      'url': url,
    };
  }

  factory FotoEstabelecimento.fromDocument(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FotoEstabelecimento(
      id: doc.id,
      estabelecimentoId: data['estabelecimentoId'] ?? '',
      url: data['url'] ?? '',
    );
  }
}
