import 'dart:ffi';

import 'cochera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  late String userId;
  late String nombre;
  late String apellido;
  late String? email;
  late List<Cochera> cocheras;
  late bool consumidor;
  late String urlImage;
  late String reservaInReservada;
  late String reservaInCheckIn;
  late String reservaInCheckOut;

  User({
    this.userId = "",
    this.nombre = "",
    this.apellido = "",
    this.email = "",
    List<Cochera>? cocheras,
    this.urlImage = "",
    this.reservaInReservada = "",
    this.reservaInCheckIn = "",
    this.reservaInCheckOut = "",
  }) : cocheras = cocheras ?? [];

  User.fromJson(Map<String, Object?> json)
      : this(
          nombre: json['nombre']! as String,
          apellido: json['apellido']! as String,
          email: json['email']! as String,
          cocheras: json['cocheras']! as List<Cochera>,
          urlImage: json['urlImage']! as String,
          reservaInReservada: json['reservaInReservada']! as String,
          reservaInCheckIn: json['reservaInCheckIn']! as String,
          reservaInCheckOut: json['reservaInCheckOut']! as String,
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
        reservaInReservada: reservaInReservada ?? this.reservaInReservada,
        reservaInCheckIn: reservaInCheckIn ?? this.reservaInCheckIn,
        reservaInCheckOut: reservaInCheckOut ?? this.reservaInCheckOut);
  }

  Map<String, Object?> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'cocheras': cocheras,
      'urlImage': urlImage,
      'reservaInReservada': reservaInReservada,
      'reservaInCheckin': reservaInCheckIn,
      'reservaInCheckOut': reservaInCheckOut,
    };
  }
}
