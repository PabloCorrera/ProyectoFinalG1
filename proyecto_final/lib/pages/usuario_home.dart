import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
>>>>>>> main
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
<<<<<<< HEAD
import 'package:proyecto_final/pages/login_register_page.dart';
=======
import 'package:proyecto_final/pages/maps_page.dart';
>>>>>>> main
import 'package:proyecto_final/services/database_sevice.dart';
import 'package:proyecto_final/navBar/usuario/navbarUsuario.dart';

class UsuarioHome extends StatefulWidget {
  const UsuarioHome({Key? key}) : super(key: key);
  static const String name = 'UsuarioHome';
  @override
  State<UsuarioHome> createState() => _UsuarioHomeState();
}

class _UsuarioHomeState extends State<UsuarioHome> {
  DatabaseService databaseService = DatabaseService();
  late List<UsuarioCochera> _cocherasFuture = [];
  late List<Reserva> _reservasFuture = [];
  final User? user = Auth().currentUser;
  Widget? aMostrar;

  @override
  void initState() {
    super.initState();
    _loadCocheras();
    _loadReservas();
    
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

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Usuario'),
          backgroundColor: Colors.pink,
        ),
         drawer:Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Bienvenido'),
            accountEmail: user != null ? Text(user!.email!) : null,
            currentAccountPicture: const CircleAvatar(),
            decoration: const BoxDecoration(
              color: Colors.pinkAccent,
            ),
          ),
           ListTile(
            leading: const Icon(Icons.car_rental),
            title: const Text('Reservar cochera'),
            onTap: ()=> {
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
            leading: const Icon(Icons.logout),
            title: const Text('Salir'),
            onTap: () => {
              context.pushNamed(LoginPage.name),
              Auth().signOut(),
            },
          )
        ],
      ),
    ),
        body: aMostrar??vistaCocheras(),
      ),
=======
  Widget _verMapa() {
    return Container(
      decoration: BoxDecoration(
          color: Color.fromARGB(197, 223, 1, 227),
          borderRadius: BorderRadius.circular(10)),
      child: TextButton(
          onPressed: () => {context.pushNamed(MapsPage.name)},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ver Mapa',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                FontAwesomeIcons.map,
                color: Colors.white,
              ),
            ],
          )),
>>>>>>> main
    );

<<<<<<< HEAD


    
  }
  

  Widget vistaCocheras(){
   return ListView.builder(
          itemCount: _cocherasFuture.length,
          itemBuilder: (context, index) {
            final cochera = _cocherasFuture[index];
            return ListTile(
              title: Text(cochera.email),
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
Widget vistaReservas(){
   return ListView.builder(
          itemCount: _reservasFuture.length,
          itemBuilder: (context, index) {
            final reserva = _reservasFuture[index];
            return ListTile(
              title: Text(reserva.cocheraEmail),
            );
          },
        );
  }
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Usuario'),
        ),
        body: Column(children: <Widget>[
          _verMapa(),
          Expanded(
            child: ListView.builder(
              itemCount: _cocherasFuture.length,
              itemBuilder: (context, index) {
                final cochera = _cocherasFuture[index];
                return ListTile(
                  title: Text(cochera.nombreCochera),
                  subtitle: Text(cochera.direccion),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _showReservarDialog(context, cochera);
                    },
                    child: const Text('Reservar'),
                  ),
                );
              },
            ),
          )
        ]));
  }

>>>>>>> main
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
                            print(selectedDate);
                            if (selectedDate != null) {
                              setState(() {
                                fechaEntrada = selectedDate;
<<<<<<< HEAD
                                if (fechaEntrada!
                                    .isAtSameMomentAs(fechaSalida!)) {
                                  horaSalida!.minute !=
                                      horaEntrada!.minute + 15;
                                }
                                fechaSalida =
                                    fechaEntrada!.add(const Duration(days: 1));
=======
>>>>>>> main
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
<<<<<<< HEAD
                              '${horaEntrada!.hour}:${horaEntrada!.minute.toString().padLeft(2, '0')}'),
=======
                              '${horaEntrada!.hour}:${horaEntrada!.minute}'),
>>>>>>> main
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
<<<<<<< HEAD
                              initialDate: fechaEntrada!,
                              firstDate: fechaEntrada!,
=======
                              initialDate: fechaSalida!,
                              firstDate: DateTime.now(),
>>>>>>> main
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
<<<<<<< HEAD
                              initialTime: horaEntrada!,
=======
                              initialTime: horaSalida!,
>>>>>>> main
                            );
                            if (selectedTime != null) {
                              setState(() {
                                horaSalida = selectedTime;
                              });
                            }
                          },
<<<<<<< HEAD
                          child: Text(
                              '${horaSalida!.hour}:${horaSalida!.minute.toString().padLeft(2, '0')}'),
=======
                          child:
                              Text('${horaSalida!.hour}:${horaSalida!.minute}'),
>>>>>>> main
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
<<<<<<< HEAD
                    reservar(fechaEntrada, horaEntrada, fechaSalida, horaSalida,
                        cochera, context);
=======
                    DateTime dateTimeEntradaCompleto = DateTime(
                      fechaEntrada!.year,
                      fechaEntrada!.month,
                      fechaEntrada!.day,
                      horaEntrada!.hour,
                      horaEntrada!.minute,
                    );
                    DateTime dateTimeSalidaCompleto = DateTime(
                      fechaSalida!.year,
                      fechaSalida!.month,
                      fechaSalida!.day,
                      horaSalida!.hour,
                      horaSalida!.minute,
                    );
                    Timestamp entrada =
                        Timestamp.fromDate(dateTimeEntradaCompleto);
                    Timestamp salida =
                        Timestamp.fromDate(dateTimeSalidaCompleto);
                    Reserva reserva = Reserva(
                        usuarioEmail: user!.email!,
                        cocheraEmail: cochera.email,
                        fechaCreacion: Timestamp.now(),
                        precioPorHora: cochera.price,
                        fechaEntrada: entrada,
                        fechaSalida: salida,
                        precioTotal:
                            cochera.calcularPrecioTotal(entrada, salida));
                    databaseService
                        .addReserva(reserva)
                        .then((reservaExitosa) => {
                              if (reservaExitosa)
                                {Navigator.of(context).pop()}
                              else
                                {
                                  Navigator.of(context).pop(),
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'No se pudo realizar la reserva.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  )
                                }
                            });
>>>>>>> main
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
            precioTotal: cochera.calcularPrecioTotal(entrada, salida));
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
}
