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
   _loadUsuariosReservas();
}





Future<void> _loadReservas() async {
    try {
      List<Reserva> reservas = await getReservas();
      print("CARGAAAAAAAAAAMOS LAS RESERVASSSSSSSSSS PRIMEROOOOOO");
      setState(() {
        _reservasFuture = reservas;
        print('Cantidad de reservas: ${_reservasFuture.length}');
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadUsuariosReservas() async {
    print("CARGAAAAAAAAAAMOS LOS USUARIOS RESERRRVAAAAAAAS");
    List<UsuarioConsumidor?> usuariosConsum = await getUsuariosDeReservas() ?? [];
    
    setState(() {
      _usuariosDeReserva = usuariosConsum;
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
      body: Column(
        children: [
          FutureBuilder<List<Reserva>>(
            future: getReservas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
      
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Cantidad de Reservas: ${_reservasFuture.length}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }
            },
          ),
          Expanded(
            child: vistaReservas(),
          ),
        ],
      ),
    ),
  );
}

Widget vistaReservas() {
  return ListView.builder(
    itemCount: _reservasFuture.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text("Hola"), // Si el nombre es nulo, muestra una cadena vacía
        subtitle: Text("Hola"), // Si el email es nulo, muestra una cadena vacía
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      );
    },
  );
}

 Future<List<UsuarioConsumidor?>> getUsuariosDeReservas() async {

  final List<UsuarioConsumidor?> consumidoresDeReserva = [];
  
 for (int i = 0; i <= _reservasFuture.length; i++) {
  print("Entró al foreach");  
  print(_reservasFuture.length); //Esto da 0;
  print(_reservasFuture[i].usuarioEmail);
  final UsuarioConsumidor? consumidor = await databaseService.buscarUsuario("clau@gmail.com");
 

  print("IMPRIMMMMMMMMMMMMMMMMMMIMOOOOOOOOOOOS EL METODOOOO");
  // consumidoresDeReserva.add(await databaseService.buscarUsuario(_reservasFuture[i].usuarioEmail));

    // Realiza alguna operación con 'cochera'
  }

  return consumidoresDeReserva;
}



}