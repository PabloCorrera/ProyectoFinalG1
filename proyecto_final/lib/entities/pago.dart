import 'package:cloud_firestore/cloud_firestore.dart';

import 'reserva.dart';

class Pago {
  late Reserva reserva;
  late String duenio;
  late Timestamp fecha;
  late String horaEntrada;
  late String horaSalida;
  late double precio;

  Pago({
    required this.reserva,
    required this.duenio,
    required this.fecha,
    required this.horaEntrada,
    required this.horaSalida,
    required this.precio,
  });

  Pago.fromJson(Map<String, Object?> json)
      : this(
          reserva: json['reserva']! as Reserva,
          duenio: json['duenio']! as String,
          fecha: json['fecha']! as Timestamp,
          horaEntrada: json['horaEntrada']! as String,
          horaSalida: json['horaSalida']! as String,
          precio: json['precio']! as double,
        );

  Pago copyWith({
    Reserva? reserva,
    String? duenio,
    Timestamp? fecha,
    String? horaEntrada,
    String? horaSalida,
    double? precio,
  }) {
    return Pago(
      reserva: reserva ?? this.reserva,
      duenio: duenio ?? this.duenio,
      fecha: fecha ?? this.fecha,
      horaEntrada: horaEntrada ?? this.horaEntrada,
      horaSalida: horaSalida ?? this.horaSalida,
      precio: precio ?? this.precio,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'reserva': reserva,
      'duenio': duenio,
      'fecha': fecha,
      'horaEntrada': horaEntrada,
      'horaSalida': horaSalida,
      'precio': precio,
    };
  }
}
