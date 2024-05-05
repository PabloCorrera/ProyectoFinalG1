import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
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
    );



    
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
                                if (fechaEntrada!
                                    .isAtSameMomentAs(fechaSalida!)) {
                                  horaSalida!.minute !=
                                      horaEntrada!.minute + 15;
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
