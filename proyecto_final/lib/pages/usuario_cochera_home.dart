import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/entities/usuario_consumidor.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
import 'package:proyecto_final/pages/maps_page.dart';
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
  late List<Reserva> _reservasExpiradas= [];
  late List<UsuarioConsumidor?> _usuariosDeReservasActivas = [];
  late List<UsuarioConsumidor?> _usuariosDeReservasExpiradas = [] ;
  late List<UsuarioConsumidor?> _usuariosDeReserva = [];
  OpcionesRecaudacion opcionSeleccionada = OpcionesRecaudacion.total;
  String titulo = 'Total Recaudado:';
    int botonActivoIndex = 0;
    String tituloReservas = "Reservas activas :";
    List<String> titulosReservas = ["Reservas activas :", "Reservas expiradas :", "Reservas totales :"];
    int cantidadReservas = 0;
  late List<UsuarioConsumidor?> _usuariosDeReservaAnteriores = [];
  late double _recaudacionTotal = 0;
  final User? user = Auth().currentUser;
  final String nombreUsuario = "";
  final String apellidoPersona = "";

  Widget? aMostrar;
  Widget? reservasAMostrar;
  String dropdownValue = 'Total';

  @override
  void initState() {
    super.initState();
    _loadReservas();
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
      await _loadReservasExpiradas();
      await _loadUsuariosReservasActivas();
      await _loadUsuariosDeReservasExpiradas();
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

  Future<void>  _loadUsuariosDeReservasExpiradas() async {
    await _loadReservasExpiradas();
    List<UsuarioConsumidor?> usuariosReserv = await getUsuariosDeReservas(_reservasExpiradas);
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
                currentAccountPicture: !kIsWeb ? const CircleAvatar() : null,
                decoration: const BoxDecoration(
                  color: Colors.pinkAccent,
                ),
              ),
              
              ListTile(
                leading: const Icon(Icons.card_travel),
                title: const Text('Reservas'),
                onTap: () => {
                  setState(() {
                    aMostrar = vistaReservas();
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
                title: const Text('Estadísticas'),
                onTap: () => {
                  setState(() {
                    aMostrar = VistaEstadisticas();
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
    String titulo = tituloReservas;
    String opcionSeleccionada =
        'Reservas actualess';

 return Column(
      children: [
        const SizedBox(height: 12.0),
Text(
  titulo + cantidadReservas.toString(),
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
),
        const SizedBox(height: 12.0), 
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            botonReservas("Activas", 0, _reservasActivas.length),
            SizedBox(width: 12.0),
            botonReservas("Expiradas", 1, _reservasExpiradas.length),
            SizedBox(width: 12.0),
            botonReservas("Totales", 2, _reservasFuture.length),
          ],
        ),
 
        if (botonActivoIndex == 0)
          listaReservasActivas(),
        if (botonActivoIndex == 1)
          listaReservasExpiradas(),
        if (botonActivoIndex ==2)
          historialDeReservas(),
  
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
        
        });
      },

      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          index == botonActivoIndex ? Colors.green : Colors.blue,
        ),
      ),
      child: Text(texto),
    );
  }


Widget listaReservasActivas() {
  print(
      "cantidad de usuarios: ${_usuariosDeReservasActivas} y cant de reservas activas ${_reservasActivas.length}");
  return Expanded(
    child: _usuariosDeReservasActivas.isEmpty
        ? Center(
            child: Text(
              'No hay reservas activas',
              style: TextStyle(fontSize: 18.0),
            ),
          )
        : ListView.builder(
            itemCount: _usuariosDeReservasActivas.length,
            itemBuilder: (context, index) {
              var usuario = _usuariosDeReservasActivas[index]!;
              return ListTile(
                leading: const Icon(Icons.account_circle, size: 40),
                title: Text(usuario.nombre + " " + usuario.apellido),
                subtitle: Text(usuario.email!),
                trailing: ElevatedButton(
                  onPressed: () {
                    _mostrarDialogo(
                        context, _reservasActivas[index], usuario);
                  },
                  child: const Text('Detalle'),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
              );
            },
          ),
  );
}

Widget listaReservasExpiradas() {
  if (_usuariosDeReservasExpiradas.isEmpty) {
    return Center(
      child: Text(
        'No hay reservas expiradas',
        style: TextStyle(fontSize: 18.0),
      ),
    );
  } else {
    return Expanded(
      child: ListView.builder(
        itemCount: _usuariosDeReservasExpiradas.length,
        itemBuilder: (context, index) {
          var usuario = _usuariosDeReservasExpiradas[index]!;
          return ListTile(
            leading: const Icon(Icons.account_circle, size: 40),
            title: Text(usuario.nombre + " " + usuario.apellido),
            subtitle: Text(usuario.email!),
            trailing: ElevatedButton(
              onPressed: () {
                _mostrarDialogo(context, _reservasExpiradas[index], usuario);
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
}

Widget historialDeReservas() {
  DateTime fechaHoy = DateTime.now();

  return Expanded(
    child: ListView.builder(
      itemCount: _usuariosDeReserva.length,
      itemBuilder: (context, index) {
        DateTime fechaSalida = _reservasFuture[index].fechaSalida.toDate();
        DateTime fechaEntrada = _reservasFuture[index].fechaEntrada.toDate();
        
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

        return ListTile(
          leading: const Icon(Icons.account_circle, size: 40),
          title: Text(
            '${_usuariosDeReserva[index]!.nombre} ${_usuariosDeReserva[index]!.apellido}',
          ),
          subtitle: Text(
            estadoReserva,
            style: TextStyle(color: colorTexto),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              _mostrarDialogo(context, _reservasFuture[index], _usuariosDeReserva[index]!);
            },
            child: const Text('Detalle'),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                    _submitButton(
                      nombreCocheraController,
                      descripcionController,
                      precioController,
                      cbuController,
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
      TextEditingController cbuController) {
    return ElevatedButton(
      onPressed: () async {
        if (isNotBlank(nombreCocheraController.text) &&
            isNotBlank(descripcionController.text) &&
            isNotBlank(precioController.text) &&
            isNotBlank(cbuController.text)) {
          if (cbuController.text.length == 22) {
            String nombreCochera = nombreCocheraController.text;
            String descripcion = descripcionController.text;
            double precio = double.parse(precioController.text);
            String cbu = cbuController.text;
            print(precioController);
            Map<String, dynamic> updatedAttributes = {
              'nombreCochera': nombreCochera,
              'descripcion': descripcion,
              'price': precio,
              'cbu': cbu
            };
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
            await databaseService.updateUsuarioCochera(
                user!.email!, updatedAttributes);
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
Widget VistaEstadisticas() {
  String titulo = "Mis estadísticas";
  int reservasUltimos30Dias = obtenerReservasUltimos30Dias(); // Método que obtendrá el número de reservas en los últimos 30 días
  int reservasTotales = _reservasFuture.length; // Suponiendo que _reservasExpiradas y _reservasActivas contienen todas las reservas
  double recaudacionUltimos30Dias = obtenerRecaudacionUltimos30Dias(); // Método que obtendrá la recaudación de los últimos 30 días
  double recaudacionTotal = _recaudacionTotal; // Suponiendo que esta variable contiene la recaudación total

  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Reservas de los últimos 30 días: $reservasUltimos30Dias',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            'Reservas Totales: $reservasTotales',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            'Recaudación de los últimos 30 días: \$${recaudacionUltimos30Dias.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            'Recaudación Total: \$${recaudacionTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    ),
  );
}

// Ejemplo de métodos para obtener los datos requeridos
int obtenerReservasUltimos30Dias() {
  DateTime fechaHoy = DateTime.now();
  DateTime hace30Dias = fechaHoy.subtract(Duration(days: 30));
  return _reservasFuture
      .where((reserva) => reserva.fechaSalida.toDate().isAfter(hace30Dias))
      .length;
}

double obtenerRecaudacionUltimos30Dias() {
  DateTime fechaHoy = DateTime.now();
  DateTime hace30Dias = fechaHoy.subtract(Duration(days: 30));
  return _reservasExpiradas
      .where((reserva) => reserva.fechaSalida.toDate().isAfter(hace30Dias))
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
  
  

}