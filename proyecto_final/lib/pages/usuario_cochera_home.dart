import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class UsuarioCocheraHome extends StatefulWidget {
  const UsuarioCocheraHome({super.key});
  static const String name = 'UsuarioCocheraHome';

  @override
  State<UsuarioCocheraHome> createState() => _UsuarioCocheraHomeState();
}

class _UsuarioCocheraHomeState extends State<UsuarioCocheraHome> {
  DatabaseService databaseService = DatabaseService();
  late List<Reserva> _reservasFuture = [];
  late List<UsuarioConsumidor?> _usuariosDeReserva = [];
  final User? user = Auth().currentUser;
  final String nombreUsuario = "";
  final String apellidoPersona= "";


  Widget? aMostrar;
  @override
  void initState() {
  super.initState();
    _loadReservas();
}

Future<void> _loadReservas() async {
  try {
    List<Reserva> reservas = await getReservas();
    print("CARGAAAAAAAAAAMOS LAS RESERVASSSSSSSSSS PRIMEROOOOOO");
    setState(() {
      _reservasFuture = reservas;
      print('Cantidad de reservas: ${_reservasFuture.length}');
    });

    // Después de cargar las reservas, cargar los usuarios de reservas
    await _loadUsuariosReservas();
  } catch (e) {
    print(e);
  }
}

  Future<void> _loadUsuariosReservas() async {
    print("CARGAAAAAAAAAAMOS LOS USUARIOS RESERRRVAAAAAAAS");
    List<UsuarioConsumidor?> usuariosConsum = await getUsuariosDeReservas() ?? [];
    
    setState(() {
      _usuariosDeReserva = usuariosConsum;
      print("A VER LOS USUARIOS DE RESERVA");
      print(_usuariosDeReserva.length);
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
              currentAccountPicture: const CircleAvatar(),
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
              ),
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
        ),
      ),
      body: aMostrar ?? vistaReservas(),
    ),
  );
}


Widget vistaReservas() {
  return Column(
    children: [
      Text(
        'Cantidad de Reservas: ${_reservasFuture.length}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: _usuariosDeReserva.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.account_circle,
                  size: 40), // Tamaño del icono de perfil
              title: Text(_usuariosDeReserva[index]!.nombre +
                  " " +
                  _usuariosDeReserva[index]!.apellido),
              subtitle: Text(_usuariosDeReserva[index]!.email!),
              trailing: ElevatedButton(
                onPressed: () {
                  _mostrarDialogo(context, _reservasFuture[index], _usuariosDeReserva[index]!); // Pasar reserva como parámetro
                },
                child: Text('Detalle'),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            );
          },
        ),
      ),
    ],
  );
}

void _mostrarDialogo(BuildContext context, Reserva reserva, UsuarioConsumidor usuarioConsumidor) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

  DateTime fechaEntrada = reserva.fechaEntrada.toDate(); 
  DateTime fechaSalida = reserva.fechaSalida.toDate(); 
  String nombreCompletoUsuario = "${usuarioConsumidor.nombre} ${usuarioConsumidor.apellido}";

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
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reserva de $nombreCompletoUsuario",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        "Fechas :",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.arrow_downward, size: 16, color: Colors.green), 
                          SizedBox(width: 8.0),
                          Text(
                            "Entrada: ${formatter.format(fechaEntrada)}", 
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                          SizedBox(width: 8.0),
                          Text(
                            "Salida: ${formatter.format(fechaSalida)}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); 
                          },
                          child: Text("Cerrar"),
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

 Future<List<UsuarioConsumidor?>> getUsuariosDeReservas() async {

  final List<UsuarioConsumidor?> consumidoresDeReserva = [];
  
 for (int i = 0; i < _reservasFuture.length; i++) {
  print("Entró al foreach");  
  print(_reservasFuture.length); //Esto da 0;
  print(_reservasFuture[i].usuarioEmail);
  final UsuarioConsumidor? consumidor = await databaseService.buscarUsuario(_reservasFuture[i].usuarioEmail);

  consumidoresDeReserva.add(await databaseService.buscarUsuario(_reservasFuture[i].usuarioEmail));
  print("Imprimimos los consumidores de reservasssss");
  print(consumidoresDeReserva[i]!.nombre);

    // Realiza alguna operación con 'cochera'
  }

  return consumidoresDeReserva;
}



}