
class UsuarioConsumidor{
  late String userId;
  late String nombre;
  late String apellido;
  late String? email;

  UsuarioConsumidor({
    this.userId = "",
    this.nombre = "",
    this.apellido = "",
    this.email = "",
  });

// Formulario para Firestore DataBase

  UsuarioConsumidor.fromJson(Map<String, Object?> json)
      : this(
          nombre: json['nombre']! as String,
          apellido: json['apellido']! as String,
          email: json['email']! as String,
        );

  UsuarioConsumidor copyWith({
    String? nombre,
    String? apellido,
    String? email,
  }) {
    return UsuarioConsumidor(
        nombre: nombre ?? this.nombre,
        apellido: apellido ?? this.apellido,
        email: email ?? this.email,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
    };
  }
  String getId(){
    return userId;
  }

}
