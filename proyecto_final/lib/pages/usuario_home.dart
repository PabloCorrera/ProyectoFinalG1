import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pay/pay.dart';
import 'package:proyecto_final/assets/payment_config.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/core/utils.dart';
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
  Uint8List? imagen;
  XFile? fileImagen;
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
          title: Text('wePark',
              style: GoogleFonts.rowdies(textStyle: primaryTextStyle)),
          backgroundColor: botonReservaCancel,
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
            accountName: Text(
              'Bienvenido ${consumidor!.nombre}',
              style: GoogleFonts.rubik(textStyle: secondaryTextStyle),
            ),
            accountEmail: user != null ? Text(user!.email!) : null,
            currentAccountPicture: CircleAvatar(
              backgroundImage: consumidor != null &&
                      consumidor?.imageUrl != null &&
                      consumidor!.imageUrl!.isNotEmpty
                  ? NetworkImage(consumidor!.imageUrl!)
                  : null,
            ),
            decoration: const BoxDecoration(
              color: botonReservaCancel,
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: TextTheme(
                  titleMedium: GoogleFonts.rubik(
                textStyle: const TextStyle(color: magnolia),
              )),
            ),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.car_rental, color: botonReservaCancel),
                  title: Text('Reservar cochera', style: GoogleFonts.rubik()),
                  onTap: () => {
                    setState(() {
                      aMostrar = vistaCocheras();
                      Navigator.pop(context);
                    })
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.card_travel, color: botonReservaCancel),
                  title: Text('Mis reservas', style: GoogleFonts.rubik()),
                  onTap: () => {
                    setState(() {
                      aMostrar = vistaReservas();
                      Navigator.pop(context);
                    })
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: botonReservaCancel),
                  title: Text('Editar mis datos', style: GoogleFonts.rubik()),
                  onTap: () => {
                    setState(() {
                      aMostrar = vistaEditar();
                      Navigator.pop(context);
                    })
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.map, color: botonReservaCancel),
                  title: Text('Ver mapa', style: GoogleFonts.rubik()),
                  onTap: () => {
                    setState(() {
                      context.pushNamed(MapsPage.name);
                      Navigator.pop(context);
                    })
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: botonReservaCancel),
                  title: Text('Salir', style: GoogleFonts.rubik()),
                  onTap: () => {
                    context.pushNamed(LoginPage.name),
                    Auth().signOut(),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget vistaCocheras() {
  return FutureBuilder<List<UsuarioCochera>>(
    future: Future.delayed(Duration(milliseconds: 200), () => _cocherasFuture),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (snapshot.hasError) {
        return Center(
          child: Text('Error al cargar las cocheras.'),
        );
      } else {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final cochera = snapshot.data![index];
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
        } else {
          return Center(
            child: Text('No hay cocheras disponibles.'),
          );
        }
      }
    },
  );
}




  Widget vistaReservas() {
  return FutureBuilder<List<Reserva>>(
    future: Future.delayed(Duration(milliseconds: 200), () => _reservasFuture), // Llama a la función que carga las reservas
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Muestra el CircularProgressIdicator mientras los datos están siendo cargados.
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        if (snapshot.hasError) {
          // Muestra un mensaje de error si hubo un error al cargar los datos.
          return Center(
            child: Text('Error al cargar las reservas.'),
          );
        } else {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Si hay datos y no están vacíos, construye la ListView
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final reserva = snapshot.data![index];
                bool puedeCancelar = faltanMasDeCuarentaYcincoMinutos(reserva.fechaEntrada);
                String estado = estadoReserva(reserva.fechaEntrada);
                String fechaEntrada = DateFormat('yyyy-MM-dd kk:mm').format(reserva.fechaEntrada.toDate());
                String fechaSalida = DateFormat('yyyy-MM-dd kk:mm').format(reserva.fechaSalida.toDate());
                
                return ListTile(
                  title: Text(reserva.direccion),
                  trailing: puedeCancelar
                      ? ElevatedButton(
                          onPressed: () {
                            showDialogCancelarReserva(context, reserva);
                          },
                          child: const Text('Cancelar'),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Fecha entrada: $fechaEntrada"),
                      Text("Fecha salida: $fechaSalida"),
                      Text(
                        estado,
                        style: TextStyle(
                            color: estado == "Reserva activa" ? Colors.green : Colors.red),
                      )
                    ],
                  ),
                  onTap: () {},
                );
              },
            );
          } else {
            // Si no hay reservas en el historial
            return Center(
              child: Text('No hay reservas en el historial'),
            );
          }
        }
      }
    },
  );
}

  

  Widget vistaEditar() {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController apellidoController = TextEditingController();

    return FutureBuilder<UsuarioConsumidor>(
      future: databaseService.getConsumidorByEmail(user!.email!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          UsuarioConsumidor usuarioConsumidor = snapshot.data!;

          nombreController.text = usuarioConsumidor.nombre;
          apellidoController.text = usuarioConsumidor.apellido;

          return Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Editar usuario',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _entryField('Nombre', nombreController),
                    const SizedBox(height: 20),
                    _entryField('Apellido', apellidoController),
                    const SizedBox(height: 20),
                    imagePicker(),
                    const SizedBox(height: 20),
                    _submitButton(
                      nombreController,
                      apellidoController,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
      ],
    );
  }

  Widget imagePicker() {
    return Column(
      children: [
        imagen != null
            ? CircleAvatar(
                radius: 64,
                backgroundImage: MemoryImage(imagen!),
              )
            : CircleAvatar(
                radius: 64,
                backgroundImage: consumidor!.imageUrl == null
                    ? const NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/9131/9131529.png')
                    : NetworkImage(consumidor!.imageUrl!),
              ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: botonfunc),
              onPressed: () => selectImage(),
              child: const Text('Elegir imagen'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: botonfunc),
              onPressed: () => takeImage(),
              child: const Text('Tomar imagen'),
            ),
          ],
        ),
      ],
    );
  }

  takeImage() async {
    XFile? img = await pickImage(ImageSource.camera);
    if (img != null) {
      img.readAsBytes().then((foto) => {
            setState(() {
              imagen = foto;
              fileImagen = img;
              aMostrar = vistaEditar();
            })
          });
    }
  }

  selectImage() async {
    XFile? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      img.readAsBytes().then((foto) => {
            setState(() {
              imagen = foto;
              fileImagen = img;
              aMostrar = vistaEditar();
            })
          });
    }
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
              title: Text("Reservar en ${cochera.nombreCochera}"),
              contentTextStyle: GoogleFonts.rubik(
                textStyle: TextStyle(color: logoTitulos, fontSize: 20),
              ),
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
                    child: const Text(
                      'Cancelar',
                    )),
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

  Widget _submitButton(
    TextEditingController nombreController,
    TextEditingController apellidoController,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: botonfunc),
      onPressed: () async {
        if (isNotBlank(nombreController.text) &&
            isNotBlank(apellidoController.text)) {
          {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const Center(child: CircularProgressIndicator());
              },
            );
            try {
              String nombre = nombreController.text;
              String apellido = apellidoController.text;

              String urlImagen = "";
              if (fileImagen != null) {
                String uniqueName =
                    DateTime.now().millisecondsSinceEpoch.toString();

                Reference referenceRoot = FirebaseStorage.instance.ref();
                Reference referenceDirImages = referenceRoot.child('images');
                Reference imagenASubir = referenceDirImages.child(uniqueName);
                try {
                  await imagenASubir.putFile(File(fileImagen!.path));
                  await imagenASubir
                      .getDownloadURL()
                      .then((value) => urlImagen = value);
                } catch (error) {
                  print(error);
                  urlImagen = "";
                }
              }

              await databaseService.updateUsuarioConsumidor(
                  consumidor!.userId, nombre, apellido, urlImagen);
              setState(() {
                consumidor!.imageUrl = urlImagen;
                consumidor!.nombre = nombre;
                consumidor!.apellido = apellido;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Los datos del usuario fueron editados correctamente'),
                  duration: Duration(seconds: 3),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hubo un error al editar los datos'),
                  duration: Duration(seconds: 3),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              Navigator.pop(context);
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complete los datos correctamente por favor'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: const Text('Editar'),
    );
  }

  bool isNotBlank(String value) {
    return value.trim().isNotEmpty;
  }
}
