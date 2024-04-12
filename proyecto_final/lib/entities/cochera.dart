import 'reserva.dart'; // Importa la clase Reserva si aún no lo has hecho

class Cochera {
  late String cocheraId;
  late String nombre;
  late String direccion;
  late double lat;
  late double lng;
  late double price;
  late String urlImage;
  late String owner;
  late String ownerName;
  late String descripcion;
  late List<Reserva> reservas;

  Cochera({
    this.cocheraId = "",
    this.nombre = "",
    this.direccion = "",
    this.lat = 0.0,
    this.lng = 0.0,
    this.price = 0.0,
    this.urlImage = "",
    required this.owner,
    required this.ownerName,
    required this.descripcion,
    List<Reserva>? reservas,
  }) : reservas = reservas ?? [];

 
  void addReserva(Reserva reserva) {
    reservas.add(reserva);
  }
}
