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
            title: Text(cochera.email ?? ''),
            trailing: ElevatedButton(
              onPressed: () {
                _showReservarDialog(context);
              },
              child: Text('Reservar'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showReservarDialog(BuildContext context) async {
    DateTime? fechaEntrada = DateTime.now();
    TimeOfDay? horaEntrada = TimeOfDay.now();
    DateTime? fechaSalida = DateTime.now().add(Duration(days: 1));
    TimeOfDay? horaSalida = TimeOfDay.now();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reservar Cochera'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fecha y hora de entrada:'),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: fechaEntrada!,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
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
              SizedBox(height: 20),
              Text('Fecha y hora de salida:'),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: fechaSalida!,
                          firstDate: fechaEntrada!,
                          lastDate: fechaEntrada!.add(Duration(days: 365)),
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
              child: Text('Cancelar'),
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
                print('Fecha de entrada seleccionada: $dateTimeEntradaCompleto');
                print('Fecha de salida seleccionada: $dateTimeSalidaCompleto');
                Navigator.of(context).pop();
              },
              child: Text('Reservar'),
            ),
          ],
        );
      },
    );
  }
}
