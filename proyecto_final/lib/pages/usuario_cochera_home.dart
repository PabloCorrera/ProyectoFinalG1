import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/core/utils.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/entities/usuario_consumidor.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
import 'package:proyecto_final/services/database_sevice.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum OpcionesRecaudacion { total, estemes, ultimasemana, personalizado }

class UsuarioCocheraHome extends StatefulWidget {
  const UsuarioCocheraHome({super.key});
  static const String name = 'UsuarioCocheraHome';

  @override
  State<UsuarioCocheraHome> createState() => _UsuarioCocheraHomeState();
}

class _UsuarioCocheraHomeState extends State<UsuarioCocheraHome> {
  DatabaseService databaseService = DatabaseService();
  late List<Reserva> _reservasFuture = [];
  late List<Reserva> _reservasActivas = [];
  late List<UsuarioConsumidor?> _usuariosDeReservasActivas = [];
  late List<UsuarioConsumidor?> _usuariosDeReserva = [];
  OpcionesRecaudacion opcionSeleccionada = OpcionesRecaudacion.total;
  String titulo = 'Total Recaudado:';

  late List<Reserva> _reservasExpiradas = [];
  late List<UsuarioConsumidor?> _usuariosDeReservaAnteriores = [];
  late double _recaudacionTotal = 0;
  final User? user = Auth().currentUser;
  late UsuarioCochera? usuarioCochera = UsuarioCochera();
  final String nombreUsuario = "";
  final String apellidoPersona = "";

  Widget? aMostrar;
  Widget? reservasAMostrar;
  String dropdownValue = 'Total';
  Uint8List? imagen;
  XFile? fileImagen;
  @override
  void initState() {
    super.initState();
    _loadReservas();
    _loadUsuarioCochera();
  }

  Future<void> _loadReservas() async {
    try {
      List<Reserva> reservas = await getReservas();
      setState(() {
        _reservasFuture = reservas;
      });

      _loadReservasAnteriores();
      await _loadUsuariosReservas();
      await _loadReservasActivas();
      await _loadUsuariosReservasActivas();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadReservasActivas() async {
    List<Reserva> reservas = await getReservas();
    List<Reserva> reservasActivas = reservas
        .where(
            (reserva) => reserva.fechaSalida.toDate().isAfter(DateTime.now()))
        .toList();
    setState(() {
      _reservasActivas = reservasActivas;
    });
  }

  Future<void> _loadUsuariosReservas() async {
    List<UsuarioConsumidor?> usuariosConsum =
        await getUsuariosDeReservas(_reservasFuture);

    setState(() {
      _usuariosDeReserva = usuariosConsum;
    });
  }

  Future<void> _loadUsuariosReservasActivas() async {
    await _loadReservasActivas();
    List<UsuarioConsumidor?> usuariosReserv =
        await getUsuariosDeReservas(_reservasActivas);
    setState(() {
      _usuariosDeReservasActivas = usuariosReserv;
    });
  }

  Future<List<UsuarioConsumidor?>> getUsuariosDeReservas(
      List<Reserva> listaReservas) async {
    final List<UsuarioConsumidor?> consumidoresDeReserva = [];

    for (int i = 0; i < listaReservas.length; i++) {
      UsuarioConsumidor? u =
          await databaseService.buscarUsuario(listaReservas[i].usuarioEmail);
      if (u != null) {
        consumidoresDeReserva.add(u);
      }
    }

    return consumidoresDeReserva;
  }

  Future<void> _loadReservasAnteriores() async {
    final DateTime now = DateTime.now();
    double totalRecaudado = 0;
    late List<Reserva> reservasAnteriores = _reservasFuture
        .where((reserva) => reserva.fechaSalida.toDate().isBefore(now))
        .toList();
    _reservasExpiradas = reservasAnteriores;

    for (final reserva in reservasAnteriores) {
      totalRecaudado += reserva.precioTotal;
    }
    _recaudacionTotal = totalRecaudado;

    List<UsuarioConsumidor?> usuariosConsumAnteriores =
        await getUsuariosDeReservas(_reservasExpiradas) ?? [];

    setState(() {
      _usuariosDeReservaAnteriores = usuariosConsumAnteriores;
    });
  }

  Future<void> _loadUsuarioCochera() async {
    UsuarioCochera uc =
        await databaseService.getCocheraByEmail(user!.email!);
    setState(() {
      usuarioCochera = uc;
    });
  }

  Future<List<Reserva>> getReservas() async {
    return databaseService.getReservasPorCochera(user!.email!);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Usuario Cochera'),
          backgroundColor: Colors.pink,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text('Bienvenido'),
                accountEmail: user != null ? Text(user!.email!) : null,
                currentAccountPicture: !kIsWeb ? CircleAvatar(
                    backgroundImage: usuarioCochera != null &&
                            usuarioCochera?.imageUrl != null &&
                            usuarioCochera!.imageUrl!.isNotEmpty
                        ? NetworkImage(usuarioCochera!.imageUrl!)
                        : null,
                ) : null,
                decoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.card_travel),
                title: const Text('Reservas activas'),
                onTap: () => {
                  setState(() {
                    aMostrar = vistaReservas();
                    Navigator.pop(context);
                  })
                },
              ),
              ListTile(
                leading: const Icon(Icons.card_travel),
                title: const Text('Historial reservas'),
                onTap: () => {
                  setState(() {
                    aMostrar = vistaHistorialDeReservas();
                    Navigator.pop(context);
                  })
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar mis datos'),
                onTap: () => {
                  setState(() {
                    aMostrar = vistaEditar();
                    Navigator.pop(context);
                  })
                },
              ),
              /*
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Ver mapa'),
                onTap: () => {
                  setState(() {
                    context.pushNamed(MapsPage.name);
                    Navigator.pop(context);
                  })
                },
              ), */
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Recaudado'),
                onTap: () => {
                  setState(() {
                    aMostrar = VistaIncome();
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
        body: aMostrar ?? vistaReservas(),
      ),
    );
  }

  Future<UsuarioCochera> getUsuarioCochera(
      DatabaseService databaseService, email) async {
    UsuarioCochera? usuarioCochera =
        await databaseService.buscarUsuarioCochera(email);

    if (usuarioCochera != null) {
      print('Usuario encontrado: ${usuarioCochera.nombre}');
      return usuarioCochera;
    } else {
      print('Usuario no encontrado');
      return usuarioCochera as UsuarioCochera;
    }
  }

  Widget vistaReservas() {
    String titulo = 'Reservas Activas: ';
    String opcionSeleccionada =
        'Reservas actuales'; // Inicialmente seleccionamos "Reservas actuales"

    return Column(
      children: [
        const SizedBox(height: 12.0),
        Text(
          titulo + _usuariosDeReservasActivas.length.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        listaReservasActivas()
      ],
    );
  }

  Widget vistaHistorialDeReservas() {
    String titulo = 'Historial de Reservas: ';
    String opcionSeleccionada =
        'Reservas actuales'; // Inicialmente seleccionamos "Reservas actuales"
    return Column(
      children: [
        const SizedBox(height: 12.0),
        Text(
          titulo + _usuariosDeReserva.length.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        historialDeReservas()
      ],
    );
  }

  Widget listaReservasActivas() {
    print(
        "cantidad de usuarios: ${_usuariosDeReservasActivas} y cant de reservas activas ${_reservasActivas.length}");
    return Expanded(
      child: ListView.builder(
        itemCount: _usuariosDeReservasActivas.length,
        itemBuilder: (context, index) {
          var usuario = _usuariosDeReservasActivas[index]!;
          return ListTile(
            leading: const Icon(Icons.account_circle, size: 40),
            title: Text(usuario.nombre + " " + usuario.apellido),
            subtitle: Text(usuario.email!),
            trailing: ElevatedButton(
              onPressed: () {
                _mostrarDialogo(context, _reservasActivas[index], usuario);
              },
              child: const Text('Detalle'),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          );
        },
      ),
    );
  }

  Widget historialDeReservas() {
    DateTime fechaHoy = DateTime.now();

    return Expanded(
      child: ListView.builder(
        itemCount: _usuariosDeReserva.length,
        itemBuilder: (context, index) {
          DateTime fechaSalida = _reservasFuture[index].fechaSalida.toDate();

          // Determinar el color del texto basado en la fecha de salida
          Color colorTexto =
              fechaSalida.isBefore(fechaHoy) ? Colors.red : Colors.green;

          return ListTile(
            leading: const Icon(Icons.account_circle, size: 40),
            title: Text(
              '${_usuariosDeReserva[index]!.nombre} ${_usuariosDeReserva[index]!.apellido}',
              style:
                  TextStyle(color: colorTexto), // Establecer el color del texto
            ),
            subtitle: Text(_usuariosDeReserva[index]!.email ?? ''),
            trailing: ElevatedButton(
              onPressed: () {
                _mostrarDialogo(context, _reservasFuture[index],
                    _usuariosDeReserva[index]!);
              },
              child: const Text('Detalle'),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          );
        },
      ),
    );
  }

  Widget vistaEditar() {
    final TextEditingController nombreCocheraController =  TextEditingController();
    final TextEditingController descripcionController = TextEditingController();
    final TextEditingController precioController = TextEditingController();
    final TextEditingController cbuController = TextEditingController();
    final TextEditingController lugaresController = TextEditingController();

    return FutureBuilder<UsuarioCochera>(
      future: getUsuarioCochera(databaseService, user!.email!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          UsuarioCochera usuarioCochera = snapshot.data!;

          nombreCocheraController.text = usuarioCochera.nombreCochera;
          descripcionController.text = usuarioCochera.descripcion;
          precioController.text = usuarioCochera.price.toString();
          cbuController.text = usuarioCochera.cbu;
          lugaresController.text = usuarioCochera.cantLugares.toString();

          return Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'EDITAR COCHERA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _entryField('Nombre Cochera', nombreCocheraController),
                    const SizedBox(height: 20),
                    _entryField('Descripción', descripcionController),
                    const SizedBox(height: 20),
                    _entryFieldNumber('Precio', precioController),
                    const SizedBox(height: 20),
                    _entryFieldNumber('CBU', cbuController),
                    const SizedBox(height: 20),
                    _entryFieldNumber('Cantidad de lugares', lugaresController),
                    const SizedBox(height: 20),
                    imagePicker(),
                    const SizedBox(height: 20),
                    _submitButton(
                      nombreCocheraController,
                      descripcionController,
                      precioController,
                      cbuController,
                      lugaresController
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

  Widget _submitButton(
      TextEditingController nombreCocheraController,
      TextEditingController descripcionController,
      TextEditingController precioController,
      TextEditingController cbuController,
      TextEditingController lugaresController,) {
    return ElevatedButton(
      onPressed: () async {
        if (isNotBlank(nombreCocheraController.text) &&
            isNotBlank(descripcionController.text) &&
            isNotBlank(precioController.text) &&
            isNotBlank(cbuController.text) &&
            isNotBlank(lugaresController.text)) {
          if (cbuController.text.length == 22) {
            String nombreCochera = nombreCocheraController.text;
            String descripcion = descripcionController.text;
            double precio = double.parse(precioController.text);
            String cbu = cbuController.text;
            int cantLugares= int.parse(lugaresController.text);
           
            String urlImagen = "";
            if (fileImagen != null) {
              String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();

              Reference referenceRoot = FirebaseStorage.instance.ref();
              Reference referenceDirImages = referenceRoot.child('images');
              Reference imagenASubir = referenceDirImages.child(uniqueName);
              try {
                await imagenASubir.putFile(File(fileImagen!.path));
                await imagenASubir.getDownloadURL().then((value) => {
                  urlImagen = value,
                  setState(() {
                    usuarioCochera!.imageUrl = value;
                  })
                  });
              } catch (error) {
                print(error);
                urlImagen = "";
              }
            }
             Map<String, dynamic> updatedAttributes = {
              'nombreCochera': nombreCochera,
              'descripcion': descripcion,
              'price': precio,
              'cbu': cbu,
              'cantLugares' : cantLugares,
              'imageUrl' : urlImagen
            };
            await databaseService.updateUsuarioCochera(user!.email!, updatedAttributes);
            await Future.delayed(const Duration(seconds: 3));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Los datos del usuario fueron editados correctamente'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              aMostrar = vistaReservas();
            });
           
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El CBU debe tener 22 números'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
              ),
            );
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
      child: const Text('Submit'),
    );
  }

  @override
  Widget VistaIncome() {
    String titulo = "Total recaudado";

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.money,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '\$${_recaudacionTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ExpansionTile(
                //   title: Text('Opciones'),
                //   children: [
                //     RadioListTile(
                //         value: OpcionesRecaudacion.total,
                //         groupValue: opcionSeleccionada,
                //         onChanged: (value) {
                //            setState(() {
                //             opcionSeleccionada = value as OpcionesRecaudacion;
                //            });

                //         },
                //         title: Text("Total")),
                //     RadioListTile(
                //         value: OpcionesRecaudacion.ultimasemana,
                //         groupValue: opcionSeleccionada,
                //         onChanged: (value) {
                //           opcionSeleccionada = value as OpcionesRecaudacion;

                //           setState(() {});
                //         },
                //         title: Text("Ultima semana")),
                //     RadioListTile(
                //         value: OpcionesRecaudacion.estemes,
                //         groupValue: opcionSeleccionada,
                //         onChanged: (value) {
                //           opcionSeleccionada = value as OpcionesRecaudacion;

                //           setState(() {});
                //         },
                //         title: Text("Este mes")),
                //     RadioListTile(
                //         value: OpcionesRecaudacion.personalizado,
                //         groupValue: opcionSeleccionada,
                //         onChanged: (value) {
                //           setState(() {
                //             opcionSeleccionada = value as OpcionesRecaudacion;

                //           });
                //         },
                //         title: Text("Personalziado"))
                //   ],
                // ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _reservasExpiradas.length,
              itemBuilder: (context, index) {
                final reserva = _reservasExpiradas[index];
                return ListTile(
                  leading: const Icon(Icons.event),
                  title: Text("Reserva de " +
                      _usuariosDeReservaAnteriores[index]!.nombre +
                      " " +
                      _usuariosDeReservaAnteriores[index]!.apellido),
                  subtitle:
                      Text(_reservasExpiradas[index].precioTotal.toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool isNotBlank(String value) {
    return value.trim().isNotEmpty;
  }

  void _mostrarDialogo(BuildContext context, Reserva reserva,
      UsuarioConsumidor usuarioConsumidor) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

    DateTime fechaEntrada = reserva.fechaEntrada.toDate();
    DateTime fechaSalida = reserva.fechaSalida.toDate();
    String nombreCompletoUsuario =
        "${usuarioConsumidor.nombre} ${usuarioConsumidor.apellido}";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Dialog(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reserva de $nombreCompletoUsuario",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          "Fechas :",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16,
                                color: Colors.blue), // Icono de calendario
                            const SizedBox(width: 8.0),
                            const Text(
                              "Creación: ",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold), // Texto en negrita
                            ),
                            Text(
                              "${formatter.format(reserva.fechaCreacion.toDate())}", // Mostrar la fecha de creación
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            const Icon(Icons.arrow_downward,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 8.0),
                            const Text(
                              "Entrada: ",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold), // Texto en negrita
                            ),
                            Text(
                              "${formatter.format(fechaEntrada)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            const Icon(Icons.arrow_upward,
                                size: 16, color: Colors.red),
                            const SizedBox(width: 8.0),
                            const Text(
                              "Salida: ",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold), // Texto en negrita
                            ),
                            Text(
                              "${formatter.format(fechaSalida)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.moneyBillAlt,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 8.0),
                            const Text(
                              "Precio total: ",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold), // Texto en negrita
                            ),
                            Text(
                              "\$${reserva.precioTotal}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30.0),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cerrar"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
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

// Función para construir un campo de entrada de número
  Widget _entryFieldNumber(String title, TextEditingController controller) {
    return TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: title,
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ]);
  }
  
  Widget imagePicker() {
  return Column(
    children: [
      imagen != null
          ? CircleAvatar(
              radius: 64,
              backgroundImage: MemoryImage(imagen!),
            )
          : const CircleAvatar(
              radius: 64,
              backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/9131/9131529.png'),
            ),
      const SizedBox(height: 10), // Espacio entre la imagen y los botones
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => selectImage(),
            child: const Text('Elegir imagen'),
          ),
          const SizedBox(width: 10), // Espacio entre los botones
          ElevatedButton(
            onPressed: () => takeImage(),
            child: const Text('Tomar imagen'),
          ),
        ],
      ),
    ],
  );
}

   takeImage()async{
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
}
