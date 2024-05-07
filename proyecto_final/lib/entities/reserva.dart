import 'package:cloud_firestore/cloud_firestore.dart';

class Reserva {
  late String? id;
  late String usuarioEmail;
  late String cocheraEmail;
  late Timestamp fechaCreacion;
  late double precioPorHora;
  Timestamp fechaEntrada;
  Timestamp fechaSalida;
  late double precioTotal;
  late String direccion;

  Reserva({
    this.id,
    required this.usuarioEmail,
    required this.cocheraEmail,
    required this.fechaCreacion,
    required this.precioPorHora,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.precioTotal,
    required this.direccion
  });

  Reserva.fromJson(Map<String, Object?> json)
      : this(
          id: '',
          usuarioEmail: json['usuarioEmail']! as String,
          cocheraEmail: json['cocheraEmail']! as String,
          fechaCreacion: json['fechaCreacion']! as Timestamp,
          precioPorHora: json['precioPorHora']! as double,
          fechaEntrada: json['fechaEntrada']! as Timestamp,
          fechaSalida: json['fechaSalida']! as Timestamp,
          precioTotal: json['precioTotal']! as double,
          direccion: json['direccion']! as String,
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
      'direccion':direccion,
    };
  }

  factory Reserva.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Reserva(
      id:snapshot.id,
      usuarioEmail: data?['usuarioEmail'] ?? '',
      cocheraEmail: data?['cocheraEmail'] ?? '',
      fechaCreacion: data?['fechaCreacion'] ?? Timestamp.now(),
      precioPorHora: (data?['precioPorHora'] ?? 0.0).toDouble(),
      fechaEntrada: data?['fechaEntrada'] ?? Timestamp.now(),
      fechaSalida: data?['fechaSalida'] ?? Timestamp.now(),
      precioTotal: (data?['precioTotal'] ?? 0.0).toDouble(),
      direccion: data?['direccion'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioEmail': usuarioEmail,
      'cocheraEmail': cocheraEmail,
      'fechaCreacion': fechaCreacion,
      'precioPorHora': precioPorHora,
      'fechaEntrada': fechaEntrada,
      'fechaSalida': fechaSalida,
      'precioTotal': precioTotal,
      'direccion':direccion,
    };
  }
}
