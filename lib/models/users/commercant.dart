class Commercant {
  final String id;
  final String email;
  final String code;
  final bool premiereConnexion;

  Commercant({
    required this.id,
    required this.email,
    required this.code,
    required this.premiereConnexion,
  });

  factory Commercant.fromMap(String id, Map<String, dynamic> data) {
    return Commercant(
      id: id,
      email: data['email'] ?? '',
      code: data['code'] ?? '',
      premiereConnexion: data['premiere_connexion'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'code': code,
      'premiere_connexion': premiereConnexion,
    };
  }
}
