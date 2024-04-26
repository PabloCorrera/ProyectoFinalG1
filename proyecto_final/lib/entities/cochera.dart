import 'reserva.dart'; // Importa la clase Reserva si aún no lo has hecho

class Cochera {
  late String cocheraId;
  late String nombre;
  late String direccion;
  late double lat;
  late double lng;
  late double price;
  late String urlImage;
  late String ownerId;
  late String descripcion;
  late int cantLugares;
  late List<Reserva> reservas;

  Cochera({
    this.cocheraId = "",
    this.nombre = "",
    this.direccion = "",
    this.lat = 0.0,
    this.lng = 0.0,
    this.price = 0.0,
    this.urlImage = "",
    required this.ownerId,
    required this.descripcion,
    required this.cantLugares,
    List<Reserva>? reservas,
  }) : reservas = reservas ?? [];


Cochera.fromJson(Map<String, Object?> json)
      : this(
          nombre: json['nombre']! as String,
          direccion: json['direccion']! as String,
          lat: json['lat']! as double,
          lng: json['lng']! as double,
          price: json['price']! as double,
          urlImage: json['urlImage']! as String,
          ownerId: json['owner']! as String,
          descripcion: json['descripcion']! as String,
          cantLugares: json['cantLugares']! as int,
          reservas: json['reservas']! as List<Reserva>,

        );

   Cochera copyWith({
    String? nombre,
    String? direccion,
    double? lat,
    double? lng,
    double? price,
    String? urlImage,
    String? owner ,
    String? ownerName,
    String? descripcion,
    int? cantLugares,
    List<Reserva>? reservas,
  }) {
    return Cochera(
        nombre: nombre ?? this.nombre,
        direccion: direccion ?? this.direccion,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        price: price ?? this.price,
        urlImage: urlImage ?? this.urlImage,
        ownerId: owner ?? this.ownerId,
        descripcion: descripcion ?? this.descripcion,
        reservas: reservas ?? this.reservas,
        cantLugares: cantLugares ?? this.cantLugares,
       
    );
  }

  Map<String, Object?> toJson() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'lat': lat,
      'lng': lng,
      'price': price,
      'urlImage': urlImage,
      'owner': ownerId,
      'descripcion': descripcion,
      'reservas': reservas,
      'cantLugares': cantLugares
      
    };
  }

 
  void addReserva(Reserva reserva) {
    reservas.add(reserva);
  }




}
