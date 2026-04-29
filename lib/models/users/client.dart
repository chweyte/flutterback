class Client {
  final String id;
  final String email;
  final String telephone;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.email,
    required this.telephone,
    required this.createdAt,
  });

  factory Client.fromMap(String id, Map<String, dynamic> data) {
    return Client(
      id: id,
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'telephone': telephone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
