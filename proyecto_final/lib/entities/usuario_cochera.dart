import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioCochera {
  late String nombre;
  late String apellido;
  late String email;
  late String nombreCochera;
  late String direccion;
  late double lat;
  late double lng;
  late double price;
  late String descripcion;
  late int cantLugares;

  UsuarioCochera({
    this.nombre = "",
    this.apellido = "",
    this.email = "",
    this.nombreCochera = "",
    this.direccion = "",
    this.lat = 0.0,
    this.lng = 0.0,
    this.price = 0.0,
    required this.descripcion,
    required this.cantLugares});


UsuarioCochera.fromJson(Map<String, Object?> json)
      : this(
          nombre: json['nombre']! as String,
          apellido: json['apellido']! as String, 
          email: json['email']! as String, 
          nombreCochera: json['nombreCochera']! as String, 
          direccion: json['direccion']! as String,
          lat: json['lat']! as double,
          lng: json['lng']! as double,
          price: json['price']! as double,
          descripcion: json['descripcion']! as String,
          cantLugares: json['cantLugares']! as int,
        );

   UsuarioCochera copyWith({
  String? nombre,
  String? apellido,
  String? email,
  String? nombreCochera,
  String? direccion,
  double? lat,
  double? lng,
  double? price,
  String? descripcion,
  int? cantLugares,
}) {
  return UsuarioCochera(
    nombre: nombre ?? this.nombre,
    apellido: apellido ?? this.apellido,
    email: email ?? this.email,
    nombreCochera: nombreCochera ?? this.nombreCochera,
    direccion: direccion ?? this.direccion,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    price: price ?? this.price,
    descripcion: descripcion ?? this.descripcion,
    cantLugares: cantLugares ?? this.cantLugares,
  );
}

  Map<String, Object?> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido, // Added apellido
      'email': email,
      'nombreCochera': nombreCochera, // Added nombreCochera
      'direccion': direccion,
      'lat': lat,
      'lng': lng,
      'price': price,
      'descripcion': descripcion,
      'cantLugares': cantLugares,
    };
  }
  factory UsuarioCochera.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UsuarioCochera(
      nombre: data?['nombre'],
      apellido: data?['apellido'],
      email: data?['email'],
      nombreCochera: data?['nombreCochera'],
      direccion: data?['direccion'],
      lat: data?['lat'],
      lng: data?['lng'],
      price: data?['price'],
      descripcion: data?['descripcion'],
      cantLugares: data?['cantLugares'],
    );
  }


 Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) 'nombre': nombre,
      if (apellido != null) 'apellido': apellido,
      if (email != null) 'email': email,
      if (nombreCochera != null) 'nombreCochera': nombreCochera,
      if (direccion != null) 'direccion': direccion,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (price != null) 'price': price,
      if (descripcion != null) 'descripcion': descripcion,
      if (cantLugares != null) 'cantLugares': cantLugares,
    };
  }

    bool verificarDisponibilidad(Timestamp fechaEntrada, Timestamp fechaSalida) {
    
    for (Reserva reserva in reservas) {
      if (fechaEntrada.isAfter(reserva.fechaEntrada!) && fechaEntrada.isBefore(reserva.fechaSalida!)) {
        reservasEnFecha++;
      }
      if (fechaSalida.isAfter(reserva.fechaEntrada!) && fechaSalida.isBefore(reserva.fechaSalida!)) {
        reservasEnFecha++;
      }
      if (fechaEntrada.isAtSameMomentAs(reserva.fechaEntrada!) || fechaSalida.isAtSameMomentAs(reserva.fechaSalida!)) {
        reservasEnFecha++;
      }
    }
    return reservasEnFecha < cantLugares;
  }


}
