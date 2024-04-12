import 'package:cloud_firestore/cloud_firestore.dart';

class Reserva {
  late String usuarioId;
  late Timestamp fechaCreacion;
  late String cocheraId;
  late String ownerId;
  late String estado;
  late double precioPorHora;
  Timestamp? fechaEntrada;
  Timestamp? fechaSalida;
  late String direccion;
  late String urlImage;
  late String ownerName;
  late double precioTotal;

    Reserva({
    required this.usuarioId,
    required this.fechaCreacion,
    required this.cocheraId,
    required this.ownerId,
    required this.estado,
    required this.precioPorHora,
    this.fechaEntrada,
    this.fechaSalida,
    required this.direccion,
    required this.urlImage,
    required this.ownerName,
    required this.precioTotal,
  });
}