import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pay/pay.dart';
import 'package:proyecto_final/assets/payment_config.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/entities/usuario_consumidor.dart';
import 'package:proyecto_final/pages/maps_page.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
import 'package:proyecto_final/services/database_sevice.dart';

class UsuarioHome extends StatefulWidget {
  const UsuarioHome({super.key});
  static const String name = 'UsuarioHome';
  @override
  State<UsuarioHome> createState() => _UsuarioHomeState();
}

class _UsuarioHomeState extends State<UsuarioHome> {
  DatabaseService databaseService = DatabaseService();
  late List<UsuarioCochera> _cocherasFuture = [];
  late List<Reserva> _reservasFuture = [];
  final User? user = Auth().currentUser;
  late UsuarioConsumidor? consumidor = UsuarioConsumidor();
  Widget? aMostrar;
  @override
  void initState() {
    super.initState();
    _loadCocheras();
    _loadReservas();
    _loadConsumidor();
  }

  Future<void> _loadCocheras() async {
    List<UsuarioCochera> cocheras = await getCocheras();
    setState(() {
      _cocherasFuture = cocheras;
    });
  }

  Future<void> _loadReservas() async {
    List<Reserva> reservas = await getReservas();
    setState(() {
      _reservasFuture = reservas;
    });
  }

  Future<List<UsuarioCochera>> getCocheras() async {
    return databaseService.getUsuariosCochera();
  }

  Future<List<Reserva>> getReservas() async {
    return databaseService.getReservasPorUsuario(user!.email!);
  }

  Future<void> _loadConsumidor() async {
    UsuarioConsumidor uc =
        await databaseService.getConsumidorByEmail(user!.email!);
    setState(() {
      print('ente');
      consumidor = uc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Usuario'),
          backgroundColor: Colors.pink,
        ),
        drawer: buildDrawer(),
        body: aMostrar ?? vistaCocheras(),
      ),
    );
  }

  Widget buildDrawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName:  Text('Bienvenido ${consumidor!.nombre}'),
          accountEmail: user != null ? Text(user!.email!) : null,
          currentAccountPicture: CircleAvatar(
              backgroundImage: consumidor!.imageUrl!=""? NetworkImage(consumidor!.imageUrl!):null),
          decoration: const BoxDecoration(
            color: Colors.pinkAccent,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.car_rental),
          title: const Text('Reservar cochera'),
          onTap: () => {
            setState(() {
              aMostrar = vistaCocheras();
              Navigator.pop(context);
            })
          },
        ),
        ListTile(
          leading: const Icon(Icons.card_travel),
          title: const Text('Mis reservas'),
          onTap: () => {
            setState(() {
              aMostrar = vistaReservas();
              Navigator.pop(context);
            })
          },
        ),
        ListTile(
          leading: const Icon(Icons.map),
          title: const Text('Ver mapa'),
          onTap: () => {
            setState(() {
              context.pushNamed(MapsPage.name);
              Navigator.pop(context);
            })
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Salir'),
          onTap: () => {
            context.pushNamed(LoginPage.name),
            Auth().signOut(),
          },
        )
      ],
    ));
  }

  Widget vistaCocheras() {
    return ListView.builder(
      itemCount: _cocherasFuture.length,
      itemBuilder: (context, index) {
        final cochera = _cocherasFuture[index];
        return ListTile(
          title: Text(cochera.direccion),
          subtitle: Text("Precio por hora: ${cochera.price}"),
          trailing: ElevatedButton(
            onPressed: () {
              _showReservarDialog(context, cochera);
            },
            child: const Text('Reservar'),
          ),
        );
      },
    );
  }

  Widget vistaReservas() {
    return ListView.builder(
      itemCount: _reservasFuture.length,
      itemBuilder: (context, index) {
        final reserva = _reservasFuture[index];
        bool puedeCancelar =
            faltanMasDeCuarentaYcincoMinutos(reserva.fechaEntrada);
        String estado = estadoReserva(reserva.fechaEntrada);
        return ListTile(
          title: Text(reserva.direccion),
          trailing: puedeCancelar
              ? ElevatedButton(
                  onPressed: puedeCancelar
                      ? () {
                          showDialogCancelarReserva(context, reserva);
                        }
                      : () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Ya no puede cancelar reserva'),
                            backgroundColor: Colors.red,
                          ));
                        },
                  child: const Text('Cancelar'),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Fecha entrada: ${reserva.fechaEntrada.toDate()}"),
              Text("Fecha salida: ${reserva.fechaSalida.toDate()}"),
              Text(
                estado,
                style: TextStyle(
                    color:
                        estado == "Reserva activa" ? Colors.green : Colors.red),
              )
            ],
          ),
          onTap: () {},
        );
      },
    );
  }

  void showDialogCancelarReserva(BuildContext context, Reserva reserva) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cancelar reserva"),
          content:
              const Text("¿Estás seguro de que quieres cancelar esta reserva?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                int cantReservasPre = _reservasFuture.length;
                await databaseService
                    .eliminarReserva(reserva.id!)
                    .then((value) => {
                          _loadReservas().then((value) => setState(() {
                                aMostrar = vistaReservas();
                                if (cantReservasPre > _reservasFuture.length) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Reserva cancelada satisfactoriamente'),
                                    backgroundColor: Colors.green,
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        'No se pudo cancelar la reserva, intente nuevamente.'),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                                Navigator.of(context).pop();
                              })),
                        });
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReservarDialog(
      BuildContext context, UsuarioCochera cochera) async {
    DateTime? fechaEntrada = DateTime.now().add(const Duration(hours: 1));
    TimeOfDay? horaEntrada = TimeOfDay.fromDateTime(fechaEntrada);
    DateTime? fechaSalida =
        DateTime.now().add(const Duration(days: 1, hours: 1));
    TimeOfDay? horaSalida = TimeOfDay.fromDateTime(fechaSalida);

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
                                  horaSalida!.minute !=
                                      horaEntrada!.minute + 15;
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
                                DateTime ahoraMasHora = DateTime.now()
                                    .add(const Duration(hours: 1));
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
                  const Text('Fecha y hora de salida:'),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
            content: Text(
                'No hay disponibilidad para la fecha y hora seleccionadas.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
    _loadReservas();
  }

  String obtenerImagenConsumidor() {
    String url = "";
    databaseService.getConsumidorByEmail(user!.email!).then((value) => {
          if (value.imageUrl != null) {url = value.imageUrl!} else {url = ""}
        });
    return url;
  }
}
