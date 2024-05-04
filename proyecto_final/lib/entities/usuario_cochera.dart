import 'reserva.dart'; // Importa la clase Reserva si aún no lo has hecho

class UsuarioCochera {
  late String userId;
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
  late List<Reserva> reservas;

  UsuarioCochera({
    this.userId = "",
    this.nombre = "",
    this.apellido = "",
    this.email = "",
    this.nombreCochera = "",
    this.direccion = "",
    this.lat = 0.0,
    this.lng = 0.0,
    this.price = 0.0,
    required this.descripcion,
    required this.cantLugares,
    List<Reserva>? reservas,
  }) : reservas = reservas ?? [];


UsuarioCochera.fromJson(Map<String, Object?> json)
      : this(
          nombre: json['nombre']! as String,
          apellido: json['apellido']! as String, // Added apellido
          email: json['email']! as String, // Added email
          nombreCochera: json['nombreCochera']! as String, // Added nombreCochera
          direccion: json['direccion']! as String,
          lat: json['lat']! as double,
          lng: json['lng']! as double,
          price: json['price']! as double,
          descripcion: json['descripcion']! as String,
          cantLugares: json['cantLugares']! as int,
          reservas: json['reservas']! as List<Reserva>,
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
  List<Reserva>? reservas,
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
    reservas: reservas ?? this.reservas,
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
      'reservas': reservas
    };
  }
 
  void addReserva(Reserva reserva) {
    reservas.add(reserva);
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
