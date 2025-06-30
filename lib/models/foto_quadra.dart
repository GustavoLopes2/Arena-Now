class FotoQuadra {
  final String id;
  final String quadraId;
  final String url;

  FotoQuadra({
    required this.id,
    required this.quadraId,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'quadraId': quadraId,
      'url': url,
    };
  }

  factory FotoQuadra.fromDocument(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FotoQuadra(
      id: doc.id,
      quadraId: data['quadraId'] ?? '',
      url: data['url'] ?? '',
    );
  }
}
