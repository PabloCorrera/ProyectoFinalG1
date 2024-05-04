import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/services/database_sevice.dart';

class UsuarioHome extends StatefulWidget {
  const UsuarioHome({Key? key}) : super(key: key);
  static const String name = 'UsuarioHome';
  @override
  State<UsuarioHome> createState() => _UsuarioHomeState();
}

class _UsuarioHomeState extends State<UsuarioHome> {
  DatabaseService databaseService = DatabaseService();
  late List<UsuarioCochera> _cocherasFuture = [];
  final User? user = Auth().currentUser;

  @override
  void initState() {
    super.initState();
    _loadCocheras();
  }

  Future<void> _loadCocheras() async {
    List<UsuarioCochera> cocheras = await getCocheras();
    setState(() {
      _cocherasFuture = cocheras;
    });
  }

  Future<List<UsuarioCochera>> getCocheras() async {
    return databaseService.getUsuariosCochera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Usuario'),
      ),
      body: ListView.builder(
        itemCount: _cocherasFuture.length,
        itemBuilder: (context, index) {
          final cochera = _cocherasFuture[index];
          return ListTile(
            title: Text(cochera.email),
            trailing: ElevatedButton(
              onPressed: () {
                _showReservarDialog(context,cochera);
              },
              child: const Text('Reservar'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showReservarDialog(BuildContext context,UsuarioCochera cochera) async {
    DateTime? fechaEntrada = DateTime.now();
    TimeOfDay? horaEntrada = TimeOfDay.now();
    DateTime? fechaSalida = DateTime.now().add(const Duration(days: 1));
    TimeOfDay? horaSalida = TimeOfDay.now();

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState){return  AlertDialog(
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
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          print(selectedDate);
                          if (selectedDate != null) {
                            setState(() {
                              fechaEntrada = selectedDate;
                            });
                          }
                        },
                        child: Text('${fechaEntrada!.day}/${fechaEntrada!.month}/${fechaEntrada!.year}'),
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
                        child: Text('${horaEntrada!.hour}:${horaEntrada!.minute}'),
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
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              fechaSalida = selectedDate;
                            });
                          }
                        },
                        child: Text('${fechaSalida!.day}/${fechaSalida!.month}/${fechaSalida!.year}'),
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
                            });
                          }
                        },
                        child: Text('${horaSalida!.hour}:${horaSalida!.minute}'),
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
                  Timestamp entrada = Timestamp.fromDate(dateTimeEntradaCompleto);
                  Timestamp salida = Timestamp.fromDate(dateTimeSalidaCompleto);
                  Reserva reserva = Reserva(usuarioEmail: user!.email!, cocheraEmail: cochera.email, fechaCreacion: Timestamp.now(), precioPorHora: cochera.price, fechaEntrada: entrada, fechaSalida: salida, precioTotal: cochera.calcularPrecioTotal(entrada, salida));              
                  databaseService.addReserva(reserva).then((reservaExitosa) => {
                    if (reservaExitosa)
                    {
                      Navigator.of(context).pop()
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
                  
                },
                child: const Text('Reservar'),
              ),
            ],
          );}
          ,
        );
      },
    );
  }
}
