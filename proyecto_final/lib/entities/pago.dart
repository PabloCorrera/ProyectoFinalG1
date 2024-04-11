import 'reserva.dart';

class Pago {
  late Reserva reserva;
  late String duenio;
  late String fecha;
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
}