import 'cochera.dart';

class User {
  late String userId;
  late String nombre;
  late String apellido;
  late String email;
  late List<Cochera> cocheras;
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
  })  : cocheras = cocheras ?? [];
}
