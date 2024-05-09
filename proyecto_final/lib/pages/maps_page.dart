import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/services/database_sevice.dart';

final DatabaseService databaseService = DatabaseService();
final User? user = Auth().currentUser;

class MapsPage extends StatefulWidget {
  static const String name = 'mapsPage';
  const MapsPage({super.key});
  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<UsuarioCochera> _cocheras = [];
  List<LatLng> posiciones = [];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-34.61014682261275, -58.429135724657954),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(-34.61014682261275, -58.429135724657954),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            title: const Text(
          "Busca tu garage mas cercano",
          style: TextStyle(color: Colors.black),
        )),
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _cocherasDisponibles(),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),

        // Boton para agregar alguna funcionalidad
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _goToTheLake,
          label: const Text('Buscar cocheras'),
          icon: const Icon(Icons.directions_car_filled_outlined),
        ),
      ),
    );
  }

//Metodo para ir a un punto en particular
  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Set<Marker> _cocherasDisponibles() {
    var marcadores = Set<Marker>();

    for (UsuarioCochera u in _cocheras) {
      marcadores.add(Marker(
          markerId: MarkerId(u.nombre),
          position: LatLng(u.lat, u.lng),
          infoWindow: InfoWindow(title: u.nombreCochera),
          onTap: () async => await _showReservarDialog(context, u)));
      //context.pushNamed(UsuarioHome.name)));
    }

    return marcadores;
  }

  Future<void> _cargarUsuarios() async {
    List<UsuarioCochera> usuarios =
        await DatabaseService().getUsuariosCochera();
    ;
    setState(() {
      _cocheras = usuarios;
    });
  }
}

Future<void> _showReservarDialog(
    BuildContext context, UsuarioCochera cochera) async {
  DateTime? fechaEntrada = DateTime.now();
  TimeOfDay? horaEntrada = TimeOfDay.now();
  DateTime? fechaSalida = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? horaSalida = TimeOfDay.now();

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Reservar Cochera'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Fecha y hora de entrada:'),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: fechaEntrada!,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              fechaEntrada = selectedDate;
                              if (fechaEntrada!
                                  .isAtSameMomentAs(fechaSalida!)) {
                                horaSalida!.minute != horaEntrada!.minute + 15;
                              }
                              fechaSalida =
                                  fechaEntrada!.add(const Duration(days: 1));
                            });
                          }
                        },
                        child: Text(
                            '${fechaEntrada!.day}/${fechaEntrada!.month}/${fechaEntrada!.year}'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: horaEntrada!,
                          );
                          if (selectedTime != null) {
                            setState(() {
                              horaEntrada = selectedTime;
                            });
                          }
                        },
                        child: Text(
                            '${horaEntrada!.hour}:${horaEntrada!.minute.toString().padLeft(2, '0')}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Fecha y hora de salida:'),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: fechaEntrada!,
                            firstDate: fechaEntrada!,
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              fechaSalida = selectedDate;
                            });
                          }
                        },
                        child: Text(
                            '${fechaSalida!.day}/${fechaSalida!.month}/${fechaSalida!.year}'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: horaEntrada!,
                          );
                          if (selectedTime != null) {
                            setState(() {
                              horaSalida = selectedTime;
                            });
                          }
                        },
                        child: Text(
                            '${horaSalida!.hour}:${horaSalida!.minute.toString().padLeft(2, '0')}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  reservar(fechaEntrada, horaEntrada, fechaSalida, horaSalida,
                      cochera, context);
                },
                child: const Text('Reservar'),
              ),
            ],
          );
        },
      );
    },
  );
}

String estadoReserva(Timestamp timestamp) {
  DateTime ahora = DateTime.now();
  DateTime fechaTimestamp = timestamp.toDate();

  if (fechaTimestamp.isBefore(ahora) ||
      fechaTimestamp.isAtSameMomentAs(ahora)) {
    return "La reserva ya expiró";
  } else {
    return "Reserva activa";
  }
}

bool faltanMasDeSeisHoras(Timestamp timestamp) {
  DateTime horaActual = DateTime.now();
  DateTime horaEvento = timestamp.toDate();
  Duration diferencia = horaEvento.difference(horaActual);
  int horasFaltantes = diferencia.inHours;
  return horasFaltantes >= 6;
}

void reservar(
    DateTime? fechaEntrada,
    TimeOfDay? horaEntrada,
    DateTime? fechaSalida,
    TimeOfDay? horaSalida,
    UsuarioCochera cochera,
    BuildContext context) async {
  DateTime dateTimeEntradaCompleto = DateTime(
    fechaEntrada!.year,
    fechaEntrada.month,
    fechaEntrada.day,
    horaEntrada!.hour,
    horaEntrada.minute,
  );
  DateTime dateTimeSalidaCompleto = DateTime(
    fechaSalida!.year,
    fechaSalida.month,
    fechaSalida.day,
    horaSalida!.hour,
    horaSalida.minute,
  );
  Timestamp entrada = Timestamp.fromDate(dateTimeEntradaCompleto);
  Timestamp salida = Timestamp.fromDate(dateTimeSalidaCompleto);

  await cochera
      .tieneDisponibilidad(entrada, salida)
      .then((tieneDisponibilidad) async {
    if (tieneDisponibilidad) {
      Reserva res = Reserva(
        usuarioEmail: user!.email!,
        cocheraEmail: cochera.email,
        fechaCreacion: Timestamp.now(),
        precioPorHora: cochera.price,
        fechaEntrada: entrada,
        fechaSalida: salida,
        precioTotal: cochera.calcularPrecioTotal(entrada, salida),
        direccion: cochera.direccion,
      );
      databaseService.addReserva(res).then((reservaExitosa) => {
            if (reservaExitosa)
              {
                Navigator.of(context).pop(),
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reserva exitosa.'),
                    backgroundColor: Colors.green,
                  ),
                )
              }
            else
              {
                Navigator.of(context).pop(),
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo realizar la reserva.'),
                    backgroundColor: Colors.red,
                  ),
                )
              }
          });
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No hay disponibilidad para la fecha y hora seleccionadas.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  });
}
