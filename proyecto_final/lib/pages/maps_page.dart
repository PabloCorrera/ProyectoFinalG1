import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/models/constant.dart';
import 'package:proyecto_final/pages/usuario_home.dart';
import 'package:proyecto_final/services/database_sevice.dart';
import 'package:proyecto_final/assets/payment_config.dart';
import 'package:pay/pay.dart';

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

  static const CameraPosition posicionInicial = CameraPosition(
    target: LatLng(-34.61014682261275, -58.429135724657954),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("wePark",
              style: GoogleFonts.rowdies(
                textStyle: Theme.of(context).textTheme.titleLarge,
                color: logoTitulos,
              )),
        ),
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: posicionInicial,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _cocherasDisponibles(),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
    );
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

Future<List<Reserva>> getReservas() async {
  return databaseService.getReservasPorUsuario(user!.email!);
}

Future<void> _showReservarDialog(
    BuildContext context, UsuarioCochera cochera) async {
  DateTime? fechaEntrada = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay? horaEntrada = TimeOfDay.fromDateTime(fechaEntrada);
  DateTime? fechaSalida = DateTime.now().add(const Duration(days: 1, hours: 1));
  TimeOfDay? horaSalida = TimeOfDay.fromDateTime(fechaSalida);

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Reservar en ${cochera.nombreCochera}"),
            titleTextStyle: terTextStyle,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cochera.direccion,
                  style: GoogleFonts.rubik(
                      textStyle: secondaryTextStyle, fontSize: 18),
                ),
                Text(
                  'Fecha y hora de entrada:',
                  style: GoogleFonts.rubik(textStyle: terTextStyle),
                ),
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
                              if (fechaEntrada!.year == fechaSalida!.year &&
                                  fechaEntrada!.month == fechaSalida!.month &&
                                  fechaEntrada!.day == fechaSalida!.day) {
                                if (horaSalida!.hour <= horaEntrada!.hour) {
                                  horaSalida = TimeOfDay(
                                      hour: horaSalida!.hour,
                                      minute: horaSalida!.minute > 44
                                          ? horaSalida!.minute + 1
                                          : horaSalida!.minute + 10);
                                }
                              }
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
                              fechaEntrada = DateTime(
                                  fechaEntrada!.year,
                                  fechaEntrada!.month,
                                  fechaEntrada!.day,
                                  horaEntrada!.hour,
                                  horaEntrada!.minute);
                              if (fechaEntrada!.year == fechaSalida!.year &&
                                  fechaEntrada!.month == fechaSalida!.month &&
                                  fechaEntrada!.day == fechaSalida!.day) {
                                if (horaSalida!.hour <= horaEntrada!.hour) {
                                  horaSalida = TimeOfDay(
                                      hour: horaSalida!.hour,
                                      minute: horaSalida!.minute > 44
                                          ? horaSalida!.minute + 1
                                          : horaSalida!.minute + 10);
                                }
                              }
                              DateTime ahoraMasHora =
                                  DateTime.now().add(const Duration(hours: 1));
                              if (fechaEntrada!.isBefore(ahoraMasHora)) {
                                horaEntrada =
                                    TimeOfDay.fromDateTime(ahoraMasHora);
                              }
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
                Text('Fecha y hora de salida:',
                    style: GoogleFonts.rubik(textStyle: terTextStyle)),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: fechaSalida!,
                            firstDate: fechaEntrada!,
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              fechaSalida = selectedDate;
                              if (fechaEntrada!.year == fechaSalida!.year &&
                                  fechaEntrada!.month == fechaSalida!.month &&
                                  fechaEntrada!.day == fechaSalida!.day) {
                                if (horaSalida!.hour <= horaEntrada!.hour) {
                                  horaSalida = TimeOfDay(
                                      hour: horaSalida!.hour,
                                      minute: horaSalida!.minute > 44
                                          ? horaSalida!.minute + 1
                                          : horaSalida!.minute + 10);
                                }
                              }
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
                            initialTime: horaSalida!,
                          );
                          if (selectedTime != null) {
                            setState(() {
                              horaSalida = selectedTime;
                              fechaSalida = DateTime(
                                  fechaSalida!.year,
                                  fechaSalida!.month,
                                  fechaSalida!.day,
                                  horaSalida!.hour,
                                  horaSalida!.minute);
                            });
                          }
                        },
                        child: Text(
                            '${horaSalida!.hour}:${horaSalida!.minute.toString().padLeft(2, '0')}'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                Center(
                  child: Text(
                    'Precio de la reserva: \$${cochera.calcularPrecioTotal(fechaEntrada!, fechaSalida!)}',
                    style: GoogleFonts.rubik(textStyle: secondaryTextStyle),
                  ),
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
              GooglePayButton(
                paymentConfiguration:
                    PaymentConfiguration.fromJsonString(defaultGooglePay),
                paymentItems: [
                  PaymentItem(
                      amount: cochera
                          .calcularPrecioTotal(fechaEntrada!, fechaSalida!)
                          .toString(),
                      label: 'Total',
                      status: PaymentItemStatus.final_price)
                ],
                type: GooglePayButtonType.plain,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: (result) {
                  reservar(fechaEntrada, horaEntrada, fechaSalida, horaSalida,
                      cochera, context);
                },
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
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

bool faltanMasDeCuarentaYcincoMinutos(Timestamp timestamp) {
  DateTime horaActual = DateTime.now();
  DateTime horaEvento = timestamp.toDate();
  Duration diferencia = horaEvento.difference(horaActual);
  int minutosFaltantes = diferencia.inMinutes;
  return minutosFaltantes >= 45;
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
        precioTotal: cochera.calcularPrecioTotal(
            dateTimeEntradaCompleto, dateTimeSalidaCompleto),
        direccion: cochera.direccion,
      );
      databaseService.addReserva(res).then((reservaExitosa) => {
            if (reservaExitosa)
              {
                Navigator.of(context).pop(),
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Reserva exitosa.',
                      style: GoogleFonts.rubik(
                          textStyle: secondaryTextStyle, fontSize: 20),
                    ),
                    backgroundColor: botonfunc,
                  ),
                ),
                context.pushNamed(UsuarioHome.name)
              }
            else
              {
                Navigator.of(context).pop(),
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'No se pudo realizar la reserva.',
                      style: GoogleFonts.rubik(
                          textStyle: secondaryTextStyle, fontSize: 20),
                    ),
                    backgroundColor: Colors.red,
                  ),
                )
              }
          });
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'No hay disponibilidad para la fecha y hora seleccionadas.',
              style: GoogleFonts.rubik(
                  textStyle: secondaryTextStyle, fontSize: 20)),
          backgroundColor: Colors.red,
        ),
      );
    }
  });
}
