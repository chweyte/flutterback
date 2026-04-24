import 'package:cloud_firestore/cloud_firestore.dart';

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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'telephone': telephone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
