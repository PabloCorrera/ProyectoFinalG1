import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioConsumidor {
  late String userId;
  late String nombre;
  late String apellido;
  late String? email;
  late String? imageUrl;

  UsuarioConsumidor(
      {this.userId = "",
      this.nombre = "",
      this.apellido = "",
      this.email = "",
      this.imageUrl = ""});

// Formulario para Firestore DataBase

  UsuarioConsumidor.fromJson(Map<String, Object?> json)
      : this(
            nombre: json['nombre']! as String,
            apellido: json['apellido']! as String,
            email: json['email']! as String,
            imageUrl: json['imageUrl']! as String);

  UsuarioConsumidor copyWith({
    String? nombre,
    String? apellido,
    String? email,
    String? imageUrl,
  }) {
    return UsuarioConsumidor(
        nombre: nombre ?? this.nombre,
        apellido: apellido ?? this.apellido,
        email: email ?? this.email,
        imageUrl: imageUrl ?? this.imageUrl);
  }

  Map<String, Object?> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'imageUrl': imageUrl
    };
  }

  String getId() {
    return userId;
  }

  static UsuarioConsumidor fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UsuarioConsumidor(
      userId: snapshot.id,
      nombre: data?['nombre'] ?? '',
      apellido: data?['apellido'] ?? '',
      email: data?['email'],
      imageUrl: data?['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'imageUrl': imageUrl,
    };
  }
}
