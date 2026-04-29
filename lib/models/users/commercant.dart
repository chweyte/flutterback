class Commercant {
  final String id;
  final String email;
  final String? nationalityId;
  final String? nationalityCardFrontUrl;
  final String? nationalityCardBackUrl;
  final bool premiereConnexion;

  Commercant({
    required this.id,
    required this.email,
    this.nationalityId,
    this.nationalityCardFrontUrl,
    this.nationalityCardBackUrl,
    required this.premiereConnexion,
  });

  factory Commercant.fromMap(String id, Map<String, dynamic> data) {
    return Commercant(
      id: id,
      email: data['email'] ?? '',
      nationalityId: data['nationality_id'],
      nationalityCardFrontUrl: data['nationality_card_front_url'],
      nationalityCardBackUrl: data['nationality_card_back_url'],
      premiereConnexion: data['premiere_connexion'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nationality_id': nationalityId,
      'nationality_card_front_url': nationalityCardFrontUrl,
      'nationality_card_back_url': nationalityCardBackUrl,
      'premiere_connexion': premiereConnexion,
    };
  }
}
