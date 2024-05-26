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
import 'package:proyecto_final/models/constant.dart';
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
        drawer: buildDrawer(),
        body: Column(
          children: [
            AppBar(
              title: const Text('Home Usuario'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black, // Color del texto de la AppBar
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Expanded(
              child: aMostrar ?? vistaCocheras(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(
            'Bienvenido ${consumidor!.nombre}',
            style: const TextStyle(
              fontSize: 18, // Tamaño del texto
              color: logoTitulos, // Color del texto
            ),
          ),
          accountEmail: user != null
              ? Text(user!.email!,
                  style: TextStyle(
                    fontSize: 14, // Tamaño del texto
                    color: logoTitulos,
                  ))
              : null,
          currentAccountPicture: CircleAvatar(
              backgroundImage: consumidor != null &&
                      consumidor?.imageUrl != null &&
                      consumidor!.imageUrl!.isNotEmpty
                  ? NetworkImage(consumidor!.imageUrl!)
                  : null),
          decoration: const BoxDecoration(
            color: botonReservaCancel,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.car_rental, color: botonReservaCancel),
          title: const Text('Reservar cochera'),
          onTap: () => {
            setState(() {
              aMostrar = vistaCocheras();
              Navigator.pop(context);
            })
          },
        ),
        ListTile(
          leading: const Icon(Icons.card_travel, color: botonReservaCancel),
          title: const Text('Mis reservas'),
          onTap: () => {
            setState(() {
              aMostrar = vistaReservas();
              Navigator.pop(context);
            })
          },
        ),
        ListTile(
          leading: const Icon(Icons.map, color: botonReservaCancel),
          title: const Text('Ver mapa'),
          onTap: () => {
            setState(() {
              context.pushNamed(MapsPage.name);
              Navigator.pop(context);
            })
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: botonReservaCancel),
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
        return Column(
          children: [
            ListTile(
              title: Text(cochera.direccion),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Estacionamiento: ${cochera.nombreCochera}"),
                  Text("Por hora: ${cochera.price}"),
                ],
              ),
              trailing: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(botonReservaCancel),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(fontSize: 16)),
                ),
                onPressed: () {
                  _showReservarDialog(context, cochera);
                },
                child: const Text('Reservar'),
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
          ],
        );
      },
    );
  }

  Widget vistaReservas() {
    _loadReservas();
    return ListView.builder(
      itemCount: _reservasFuture.length,
      itemBuilder: (context, index) {
        final reserva = _reservasFuture[index];
        bool puedeCancelar =
            faltanMasDeCuarentaYcincoMinutos(reserva.fechaEntrada);
        String estado = estadoReserva(reserva.fechaEntrada);

        return Column(
          children: [
            ListTile(
              title: Text(reserva.direccion),
              trailing: puedeCancelar
                  ? ElevatedButton(
                      onPressed: () {
                        showDialogCancelarReserva(context, reserva);
                      },
                      child: const Text('Cancelar'),
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            botonReservaCancel),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0)),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(fontSize: 16)),
                      ),
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
                        color: estado == "Reserva activa"
                            ? Colors.green
                            : Colors.red),
                  )
                ],
              ),
              onTap: () {},
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ), // Divisor entre elementos de la lista
          ],
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
