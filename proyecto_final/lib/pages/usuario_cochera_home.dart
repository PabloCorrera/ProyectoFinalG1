

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/core/utils.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/entities/usuario_consumidor.dart';
import 'package:proyecto_final/models/constant.dart';
import 'package:proyecto_final/pages/BarChart/bar_chart_page.dart';
import 'package:proyecto_final/pages/line_chart_widget.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
import 'package:proyecto_final/services/database_sevice.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

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
  late List<Reserva> _reservasExpiradas = [];
  late List<UsuarioConsumidor?> _usuariosDeReservasActivas = [];
  late List<UsuarioConsumidor?> _usuariosDeReservasExpiradas = [];

  late List<UsuarioConsumidor?> _usuariosDeReserva = [];
  OpcionesRecaudacion opcionSeleccionada = OpcionesRecaudacion.total;

  String titulo = 'Total Recaudado:';
  int botonActivoIndex = 0;
  String tituloReservas = "Reservas activas :";

  List<String> titulosReservas = [
    "Reservas activas :",
    "Reservas expiradas :",
    "Reservas totales :"
  ];

  int cantidadReservas = 0;
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
  late Future<void> _initialLoadFuture;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialLoadFuture = _loadReservas();
    _loadUsuarioCochera();
  }

  Future<void> _loadReservas() async {
    try {
      List<Reserva> reservas = await getReservas();
      setState(() {
        _reservasFuture = reservas;
      });

      _loadReservasAnteriores();
      return _loadUsuariosReservas()
          .then((_) => _loadReservasActivas())
          .then((_) => _loadReservasExpiradas())
          .then((_) => _loadUsuariosReservasActivas())
          .then((_) => _loadUsuariosDeReservasExpiradas());

          
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
      cantidadReservas = _reservasActivas.length;
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

  Future<void> _loadUsuariosDeReservasExpiradas() async {
    await _loadReservasExpiradas();
    List<UsuarioConsumidor?> usuariosReserv =
        await getUsuariosDeReservas(_reservasExpiradas);
    setState(() {
      _usuariosDeReservasExpiradas = usuariosReserv;
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

  Future<void> _loadReservasExpiradas() async {
    List<Reserva> reservas = await getReservas();
    List<Reserva> reservasExpiradas = reservas
        .where(
            (reserva) => reserva.fechaSalida.toDate().isBefore(DateTime.now()))
        .toList();
    setState(() {
      _reservasExpiradas = reservasExpiradas;
    });
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
    UsuarioCochera uc = await databaseService.getCocheraByEmail(user!.email!);
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
        title: Text('wePark',
            style: GoogleFonts.rowdies(
                textStyle: Theme.of(context).textTheme.titleLarge)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text('Bienvenido',
                    style: GoogleFonts.rubik(textStyle: secondaryTextStyle)),
              ),
              accountEmail: user != null
                  ? Text(user!.email!,
                      style: GoogleFonts.rubik(textStyle: terTextStyle))
                  : null,
              currentAccountPicture: !kIsWeb
                  ? CircleAvatar(
                      backgroundImage: usuarioCochera != null &&
                              usuarioCochera?.imageUrl != null &&
                              usuarioCochera!.imageUrl!.isNotEmpty
                          ? NetworkImage(usuarioCochera!.imageUrl!)
                          : null,
                    )
                  : null,
              decoration: const BoxDecoration(
                color: botonReservaCancel,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.card_travel, color: botonReservaCancel),
              title: Text('Reservas activas', style: GoogleFonts.rubik()),
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
              leading: const Icon(Icons.bar_chart, color: botonReservaCancel),
              title: Text('Recaudado', style: GoogleFonts.rubik()),
              onTap: () => {
                setState(() {
                  aMostrar = VistaEstadisticas();
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
            )
          ],
        ),
      ),
      body: FutureBuilder(
          future: _initialLoadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return aMostrar ?? vistaReservas();
            }
          }),
    ));
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
    String titulo = tituloReservas;
    String opcionSeleccionada = 'Reservas actualess';

    return Column(
      children: [
        const SizedBox(height: 12.0),
        Text(titulo + cantidadReservas.toString(),
            style: GoogleFonts.rubik(
              textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: logoTitulos),
            )),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            botonReservas(
              "Activas",
              0,
              _reservasActivas.length,
            ),
            const SizedBox(width: 12.0),
            botonReservas("Expiradas", 1, _reservasExpiradas.length),
            const SizedBox(width: 12.0),
            botonReservas("Totales", 2, _reservasFuture.length),
          ],
        ),
        if (botonActivoIndex == 0) listaReservasActivas(),
        if (botonActivoIndex == 1) listaReservasExpiradas(),
        if (botonActivoIndex == 2) historialDeReservas(),
      ],
    );
  }

  Widget botonReservas(String texto, int index, int cantidad) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          botonActivoIndex = index;
          tituloReservas = titulosReservas[index];
          cantidadReservas = cantidad;
          aMostrar = vistaReservas();
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            index == botonActivoIndex ? Colors.green : botonfunc),
      ),
      child: Text(texto, style: GoogleFonts.rubik()),
    );
  }

  Widget listaReservasActivas() {
    return Expanded(
      child: _usuariosDeReservasActivas.isEmpty
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Text(
                  'No hay reservas activas',
                  style: TextStyle(fontSize: 32.0),
                ),
                SizedBox(height: 16.0),
                Icon(
                  Icons.directions_car,
                  size: 60.0,
                  color: Color(0xFF2C7F8C),
                ),
                Icon(
                  Icons.clear,
                  size: 60.0,
                  color: Color(0xFF2C7F8C),
                ),
                Spacer(flex: 2),
              ],
            )
          : ListView.builder(
              itemCount: _usuariosDeReservasActivas.length,
              itemBuilder: (context, index) {
                var usuario = _usuariosDeReservasActivas[index]!;
                return Column(
                  children: [
                    ListTile(
                      leading: usuario.imageUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(usuario.imageUrl!),
                              radius: 20,
                            )
                          : const Icon(Icons.account_circle, size: 40),
                      title: Text(usuario.nombre + " " + usuario.apellido,
                          style: GoogleFonts.rubik()),
                      subtitle: Text(
                        usuario.email!,
                        style: GoogleFonts.rubik(textStyle: terTextStyle),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _mostrarDialogo(
                              context, _reservasActivas[index], usuario);
                        },
                        child: const Text('Detalle'),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget listaReservasExpiradas() {
    if (_usuariosDeReservasExpiradas.isEmpty) {
      return const Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'No hay reservas expiradas',
              style: TextStyle(fontSize: 30.0),
            ),
            SizedBox(height: 16.0),
            Icon(
              Icons.directions_car,
              size: 60.0,
              color: Color(0xFF2C7F8C),
            ),
            Icon(
              Icons.clear,
              size: 60.0,
              color: Color(0xFF2C7F8C),
            ),
            Spacer(flex: 2),
          ],
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: _usuariosDeReservasExpiradas.length,
          itemBuilder: (context, index) {
            var usuario = _usuariosDeReservasExpiradas[index]!;
            return Column(
              children: [
                ListTile(
                  leading: usuario.imageUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(usuario.imageUrl!),
                          radius: 20,
                        )
                      : const Icon(Icons.account_circle, size: 40),
                  title: Text(usuario.nombre + " " + usuario.apellido,
                      style: GoogleFonts.rubik()),
                  subtitle: Text(usuario.email!,
                      style: GoogleFonts.rubik(textStyle: terTextStyle)),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _mostrarDialogo(
                          context, _reservasExpiradas[index], usuario);
                    },
                    child: const Text('Detalle'),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  Widget historialDeReservas() {
    DateTime fechaHoy = DateTime.now();

    return _usuariosDeReserva.isEmpty
        ? const Expanded(
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Text(
                  'No hay reservas',
                  style: TextStyle(fontSize: 42.0),
                ),
                SizedBox(height: 16.0),
                Icon(
                  Icons.directions_car,
                  size: 60.0,
                  color: Color(0xFF2C7F8C),
                ),
                Icon(
                  Icons.clear,
                  size: 60.0,
                  color: Color(0xFF2C7F8C),
                ),
                Spacer(flex: 2),
              ],
            ),
          )
        : Expanded(
            child: ListView.builder(
              itemCount: _usuariosDeReserva.length,
              itemBuilder: (context, index) {
                DateTime fechaSalida =
                    _reservasFuture[index].fechaSalida.toDate();
                DateTime fechaEntrada =
                    _reservasFuture[index].fechaEntrada.toDate();

                String estadoReserva;
                Color colorTexto;
                if (fechaSalida.isBefore(fechaHoy)) {
                  estadoReserva = 'Expirada';
                  colorTexto = Colors.red;
                } else if (fechaSalida.isAfter(fechaHoy)) {
                  estadoReserva = 'Activa';
                  colorTexto = Colors.green;
                } else if (fechaEntrada.isAfter(fechaHoy)) {
                  estadoReserva = 'No iniciada';
                  colorTexto = Colors.blue;
                } else {
                  estadoReserva = 'En curso';
                  colorTexto = Colors.black;
                }

                return Column(
                  children: [
                    ListTile(
                      leading: _usuariosDeReserva[index]!.imageUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                  _usuariosDeReserva[index]!.imageUrl!),
                              radius: 20,
                            )
                          : const Icon(Icons.account_circle, size: 40),
                      title: Text(
                        '${_usuariosDeReserva[index]!.nombre} ${_usuariosDeReserva[index]!.apellido}',
                      ),
                      subtitle: Text(
                        estadoReserva,
                        style: GoogleFonts.rubik(
                            textStyle:
                                TextStyle(color: colorTexto, fontSize: 22)),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _mostrarDialogo(context, _reservasFuture[index],
                              _usuariosDeReserva[index]!);
                        },
                        child: const Text('Detalle'),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
  }

  Widget vistaEditar() {
    final TextEditingController nombreCocheraController =
        TextEditingController();
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
                    Text('Editar cochera',
                        style:
                            GoogleFonts.rubik(textStyle: secondaryTextStyle)),
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
                        lugaresController),
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
    TextEditingController lugaresController,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: botonfunc, textStyle: GoogleFonts.rubik()),
      onPressed: () async {
        if (isNotBlank(nombreCocheraController.text) &&
            isNotBlank(descripcionController.text) &&
            isNotBlank(precioController.text) &&
            isNotBlank(cbuController.text) &&
            isNotBlank(lugaresController.text)) {
          if (cbuController.text.length == 22) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const Center(child: CircularProgressIndicator());
              },
            );
            try {
              String nombreCochera = nombreCocheraController.text;
              String descripcion = descripcionController.text;
              double precio = double.parse(precioController.text);
              String cbu = cbuController.text;
              int cantLugares = int.parse(lugaresController.text);

              String urlImagen = "";
              if (usuarioCochera!.imageUrl != null &&
                  usuarioCochera!.imageUrl != "") {
                urlImagen = usuarioCochera!.imageUrl!;
              }
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
                  if (usuarioCochera!.imageUrl != null &&
                      usuarioCochera!.imageUrl != "") {
                    urlImagen = usuarioCochera!.imageUrl!;
                  } else {
                    urlImagen = "";
                  }
                }
              }
              Map<String, dynamic> updatedAttributes = {
                'nombreCochera': nombreCochera,
                'descripcion': descripcion,
                'price': precio,
                'cbu': cbu,
                'cantLugares': cantLugares,
                'imageUrl': urlImagen
              };
              await databaseService.updateUsuarioCochera(
                  user!.email!, updatedAttributes);
              setState(() {
                usuarioCochera!.imageUrl = urlImagen;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Los datos del usuario fueron editados correctamente',
                      style: GoogleFonts.rubik(
                          textStyle: secondaryTextStyle, fontSize: 20)),
                  duration: const Duration(seconds: 3),
                  backgroundColor: botonfunc,
                ),
              );
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hubo un error al editar los datos',
                      style: GoogleFonts.rubik(
                          textStyle: secondaryTextStyle, fontSize: 20)),
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              Navigator.pop(context);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('El CBU debe tener 22 números',
                    style: GoogleFonts.rubik(
                        textStyle: secondaryTextStyle, fontSize: 20)),
                duration: const Duration(seconds: 3),
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
      child: Text('Editar', style: GoogleFonts.rubik()),
    );
  }

  Widget VistaEstadisticas() {
    String titulo = "Mis estadísticas";
    int reservasUltimos30Dias = obtenerCantidadReservasUltimos30Dias();
    int cantidadReservasPrimerSemana = 5;
    int cantidadReservas2daSemana = 7;
    int cantidadReservas3eraSemana = 4;
    int cantidadReservas4taSemana = 2;
    double recaudacion1erSemana = 5000;
    double recaudacion2daSemana = 8000;
    double recaudacion3eraSemana = 2000;
    double recaudacion4taSemana = 9000;
    List<int> arrayCantidades = [cantidadReservasPrimerSemana,cantidadReservas2daSemana,cantidadReservas3eraSemana,cantidadReservas4taSemana];
    List<double> arrayRecaudaciones = [recaudacion1erSemana,recaudacion2daSemana,recaudacion3eraSemana,recaudacion4taSemana];
    int reservasTotales = _reservasFuture.length;
    double recaudacionUltimos30Dias = obtenerRecaudacionUltimos30Dias();
    int reservasUlt30 = obtenerCantidadReservasUltimos30Dias();
    double recaudacionTotal = obtenerRecaudacionTotal();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                titulo,
                style: GoogleFonts.rubik(
                    textStyle: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Reservas de los últimos 30 días: $reservasUltimos30Dias',
              style:
                  GoogleFonts.rubik(textStyle: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            Text(
              'Reservas Totales: $reservasTotales',
              style:
                  GoogleFonts.rubik(textStyle: const TextStyle(fontSize: 18)),
            ),
            Text(
              'Recaudación de los últimos 30 días: \$${recaudacionUltimos30Dias.toStringAsFixed(2)}',
              style:
                  GoogleFonts.rubik(textStyle: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            Text(
              'Recaudación Total: \$${recaudacionTotal.toStringAsFixed(2)}',
              style:
                  GoogleFonts.rubik(textStyle: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Cantidad de Reservas',
                style: GoogleFonts.rubik(
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChartPage(
                ultimos30: reservasUlt30,
                arrayCantidades : arrayCantidades,
                arrayRecaudaciones: arrayRecaudaciones,


              ),
            ),
          ],
        ),
      ),
    );
  }

  double obtenerRecaudacionUltimos30Dias() {
    DateTime fechaHoy = DateTime.now();
    DateTime hace30Dias = fechaHoy.subtract(const Duration(days: 30));
    return _reservasFuture
        .where((reserva) => reserva.fechaCreacion.toDate().isAfter(hace30Dias))
        .fold(0.0, (sum, reserva) => sum + reserva.precioTotal);
  }

  double obtenerRecaudacionTotal() {
  return _reservasFuture.fold(0.0, (sum, reserva) => sum + reserva.precioTotal);
}

  int obtenerCantidadReservasUltimos30Dias() {
    DateTime fechaHoy = DateTime.now();
    DateTime hace30Dias = fechaHoy.subtract(const Duration(days: 30));
    return _reservasFuture
        .where((reserva) => reserva.fechaEntrada.toDate().isAfter(hace30Dias))
        .length;
  }

  int obtenerCantidadReservasPrimerSemana() {
  DateTime fechaHoy = DateTime.now();
  DateTime hace30Dias = fechaHoy.subtract(const Duration(days: 30));
  DateTime hace23Dias = fechaHoy.subtract(const Duration(days: 23));
  
  return _reservasFuture
      .where((reserva) => reserva.fechaEntrada.toDate().isAfter(hace30Dias) && reserva.fechaEntrada.toDate().isBefore(hace23Dias))
      .length;
}

double obtenerRecaudacionPrimerSemana() {
  DateTime fechaHoy = DateTime.now();
  DateTime hace30Dias = fechaHoy.subtract(const Duration(days: 30));
  DateTime hace23Dias = fechaHoy.subtract(const Duration(days: 23));
  
  return _reservasFuture
      .where((reserva) => reserva.fechaEntrada.toDate().isAfter(hace30Dias) && reserva.fechaEntrada.toDate().isBefore(hace23Dias))
      .fold(0.0, (sum, reserva) => sum + reserva.precioTotal);
}

int obtenerCantidadReservasSegundaSemana() {
  DateTime fechaHoy = DateTime.now();
  DateTime hace22Dias = fechaHoy.subtract(const Duration(days: 22));
  DateTime hace16Dias = fechaHoy.subtract(const Duration(days: 16));

  return _reservasFuture
      .where((reserva) => reserva.fechaEntrada.toDate().isAfter(hace22Dias) && reserva.fechaEntrada.toDate().isBefore(hace16Dias))
      .length;
}

double obtenerRecaudacionSegundaSemana() {
  DateTime fechaHoy = DateTime.now();
  DateTime hace22Dias = fechaHoy.subtract(const Duration(days: 22));
  DateTime hace16Dias = fechaHoy.subtract(const Duration(days: 16));

  return _reservasFuture
      .where((reserva) => reserva.fechaEntrada.toDate().isAfter(hace22Dias) && reserva.fechaEntrada.toDate().isBefore(hace16Dias))
      .fold(0.0, (sum, reserva) => sum + reserva.precioTotal);
}


int obtenerCantidadReservasTercerSemana() {
  DateTime fechaHoy = DateTime.now();
  DateTime hace15Dias = fechaHoy.subtract(const Duration(days: 15));
  DateTime hace9Dias = fechaHoy.subtract(const Duration(days: 9));

  return _reservasFuture
      .where((reserva) => reserva.fechaEntrada.toDate().isAfter(hace15Dias) && reserva.fechaEntrada.toDate().isBefore(hace9Dias))
      .length;
}

double obtenerRecaudacionTercerSemana() {
  DateTime fechaHoy = DateTime.now();
  DateTime hace15Dias = fechaHoy.subtract(const Duration(days: 15));
  DateTime hace9Dias = fechaHoy.subtract(const Duration(days: 9));

  return _reservasFuture
      .where((reserva) => reserva.fechaEntrada.toDate().isAfter(hace15Dias) && reserva.fechaEntrada.toDate().isBefore(hace9Dias))
      .fold(0.0, (sum, reserva) => sum + reserva.precioTotal);
}


int obtenerCantidadReservasCuartaSemana() {
  DateTime fechaHoy = DateTime.now();
  DateTime hace8Dias = fechaHoy.subtract(const Duration(days: 8));
  DateTime hace1Dia = fechaHoy.subtract(const Duration(days: 1));

  return _reservasFuture
      .where((reserva) => reserva.fechaEntrada.toDate().isAfter(hace8Dias) && reserva.fechaEntrada.toDate().isBefore(hace1Dia))
      .length;
}

double obtenerRecaudacionCuartaSemana() {
  DateTime fechaHoy = DateTime.now();
  DateTime hace8Dias = fechaHoy.subtract(const Duration(days: 8));
  DateTime hace1Dia = fechaHoy.subtract(const Duration(days: 1));

  return _reservasFuture
      .where((reserva) => reserva.fechaEntrada.toDate().isAfter(hace8Dias) && reserva.fechaEntrada.toDate().isBefore(hace1Dia))
      .fold(0.0, (sum, reserva) => sum + reserva.precioTotal);
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
                          style: GoogleFonts.rubik(
                              textStyle: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
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
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
      style: GoogleFonts.rubik(),
      decoration: InputDecoration(
        labelText: title,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
        LengthLimitingTextInputFormatter(30),
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
          LengthLimitingTextInputFormatter(22),
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
            : CircleAvatar(
                radius: 64,
                backgroundImage: usuarioCochera!.imageUrl == null
                    ? const NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/9131/9131529.png')
                    : NetworkImage(usuarioCochera!.imageUrl!),
              ),
        const SizedBox(height: 10), // Espacio entre la imagen y los botones
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: botonfunc,
              ),
              onPressed: () => selectImage(),
              child: Text('Elegir imagen', style: GoogleFonts.rubik()),
            ),
            const SizedBox(width: 10), // Espacio entre los botones
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: botonfunc,
              ),
              onPressed: () => takeImage(),
              child: Text('Tomar imagen', style: GoogleFonts.rubik()),
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
}
