import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/services/database_sevice.dart';

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

double calcularPrecioTotal(DateTime dateTimeEntrada, DateTime dateTimeSalida) {
  double precioPorHora = price;

  Duration diferencia = dateTimeSalida.difference(dateTimeEntrada);
  int totalMinutos = diferencia.inMinutes;

  if (totalMinutos <= 60) {
    return precioPorHora;
  } else {
    int horas = totalMinutos ~/ 60;
    int minutosAdicionales = totalMinutos % 60;
    double cargoAdicional = 0.0;
    if (minutosAdicionales > 0) {
      cargoAdicional = precioPorHora / 4 * ((minutosAdicionales - 1) ~/ 15 + 1);
    }
    double precioTotal = precioPorHora * horas + cargoAdicional;
    return precioTotal;
  }
}

Future<bool> tieneDisponibilidad(Timestamp entrada, Timestamp salida)async{
    int reservasEnFecha = 0;
    DatabaseService databaseService = DatabaseService();
    DateTime dateEntrada = entrada.toDate();
    DateTime dateSalida = salida.toDate();
    await databaseService.getReservasPorCochera(email).then((reservas) => {
      reservas.forEach((reserva) {
        if (dateEntrada.isAfter(reserva.fechaEntrada.toDate()) && dateEntrada.isBefore(reserva.fechaSalida.toDate())) {
        reservasEnFecha++;
        }else if (dateSalida.isAfter(reserva.fechaEntrada.toDate()) && dateSalida.isBefore(reserva.fechaSalida.toDate())){
          reservasEnFecha++;
        } else if(dateEntrada.isAtSameMomentAs(reserva.fechaEntrada.toDate()) || dateSalida.isAtSameMomentAs(reserva.fechaSalida.toDate())) {
          reservasEnFecha++;
        }
       })
  
    });

    return reservasEnFecha < cantLugares;
}

    


}


final List<UsuarioCochera> usuariosCocheras = [
  UsuarioCochera(descripcion: 'La mejor Cochera', cantLugares: 17),
  UsuarioCochera(descripcion: 'Cochera Copada', cantLugares: 2),
  UsuarioCochera(descripcion: 'Alta cochera', cantLugares: 15),
  UsuarioCochera(descripcion: 'Dale que va', cantLugares: 25),
  UsuarioCochera(descripcion: 'Esta tampoco va', cantLugares: 0),
  UsuarioCochera(descripcion: 'Esta no va', cantLugares: 0)
];
