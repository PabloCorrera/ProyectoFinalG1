import 'package:cloud_firestore/cloud_firestore.dart';

class Reserva {
  late String usuarioEmail;
  late String cocheraEmail;
  late Timestamp fechaCreacion;
  late double precioPorHora;
  Timestamp fechaEntrada;
  Timestamp fechaSalida;
  late double precioTotal;

    Reserva({
    required this.usuarioEmail,
    required this.cocheraEmail,
    required this.fechaCreacion,
    required this.precioPorHora,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.precioTotal,
  });


  Reserva.fromJson(Map<String, Object?> json)
      : this(
          usuarioEmail: json['usuarioEmail']! as String,
          cocheraEmail: json['cocheraEmail']! as String,
          fechaCreacion: json['fechaCreacion']! as Timestamp,
          precioPorHora: json['precioPorHora']! as double,
          fechaEntrada: json['fechaEntrada']! as Timestamp,
          fechaSalida: json['fechaSalida']! as Timestamp,
          precioTotal: json['precioTotal']! as double,
        );

       Map<String, Object?> toJson() {
  return {
    'usuarioEmail': usuarioEmail,
    'cocheraEmail': cocheraEmail,
    'fechaCreacion': fechaCreacion,
    'precioPorHora': precioPorHora,
    'fechaEntrada': fechaEntrada,
    'fechaSalida': fechaSalida,
    'precioTotal': precioTotal,
  };
}
}