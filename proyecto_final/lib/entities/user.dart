import 'cochera.dart';

class User {
  late String userId;
  late String nombre;
  late String apellido;
  late String? email;
  late List<Cochera> cocheras;
  late bool consumidor;
  late String urlImage;

  User({
    this.userId = "",
    this.nombre = "",
    this.apellido = "",
    this.email = "",
    List<Cochera>? cocheras,
    this.urlImage = "",
  }) : cocheras = cocheras ?? [];

// Formulario para Firestore DataBase

  User.fromJson(Map<String, Object?> json)
      : this(
          nombre: json['nombre']! as String,
          apellido: json['apellido']! as String,
          email: json['email']! as String,
          cocheras: json['cocheras']! as List<Cochera>,
          urlImage: json['urlImage']! as String,
        );

  User copyWith({
    String? nombre,
    String? apellido,
    String? email,
    List<Cochera>? cocheras,
    String? urlImage,
    String? reservaInReservada,
    String? reservaInCheckIn,
    String? reservaInCheckOut,
  }) {
    return User(
        nombre: nombre ?? this.nombre,
        apellido: apellido ?? this.apellido,
        email: email ?? this.email,
        cocheras: cocheras ?? this.cocheras,
        urlImage: urlImage ?? this.urlImage,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'cocheras': cocheras,
      'urlImage': urlImage,
    };
  }
  String getId(){
    return userId;
  }
}
