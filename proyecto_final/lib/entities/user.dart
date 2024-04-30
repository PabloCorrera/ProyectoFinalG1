import 'cochera.dart';

class User {
  late String userId;
  late String nombre;
  late String apellido;
  late String? email;
  late List<Map<String, dynamic>> cocheras; // Cambiar el tipo de la lista
  late bool consumidor;
  late String urlImage;

  User({
    this.userId = "",
    this.nombre = "",
    this.apellido = "",
    this.email = "",
    List<Map<String, dynamic>>? cocheras, // Cambiar el tipo de la lista
    this.urlImage = "",
    this.consumidor = true,
  }) : cocheras = cocheras ?? [];

  User.fromJson(Map<String, Object?> json)
      : this(
          nombre: json['nombre']! as String,
          apellido: json['apellido']! as String,
          email: json['email']! as String,
          cocheras: (json['cocheras']! as List<dynamic>).cast<Map<String, dynamic>>(), // Convertir la lista a la estructura esperada
          urlImage: json['urlImage']! as String,
          consumidor: json['consumidor']! as bool
        );

  User copyWith({
    String? nombre,
    String? apellido,
    String? email,
    List<Map<String, dynamic>>? cocheras, // Cambiar el tipo de la lista
    String? urlImage,
    bool? consumidor,
  }) {
    return User(
        nombre: nombre ?? this.nombre,
        apellido: apellido ?? this.apellido,
        email: email ?? this.email,
        cocheras: cocheras ?? this.cocheras,
        urlImage: urlImage ?? this.urlImage,
        consumidor: consumidor ?? this.consumidor
    );
  }

  Map<String, Object?> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'cocheras': cocheras,
      'urlImage': urlImage,
      'consumidor': consumidor
    };
  }
  String getId(){
    return userId;
  }

  void addCochera(Map<String, dynamic> cocheraMap) {
    this.cocheras.add(cocheraMap);
  }

  @override
  String toString() {
    return 'User{userId: $userId, nombre: $nombre, apellido: $apellido, email: $email, cocheras: $cocheras, consumidor: $consumidor, urlImage: $urlImage}';
  }

}
