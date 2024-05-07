import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
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
  final User? user = Auth().currentUser;
  Widget? aMostrar;
  @override
  void initState() {
    super.initState();
    _loadReservas();
  }


  Future<void> _loadReservas() async {
    List<Reserva> reservas = await getReservas();
    print("LOAAAAAAAAAAAD RESERVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAS");
    print(reservas[0].usuarioEmail); ///Aca me trae bien la reserva
    setState(() {
      _reservasFuture = reservas;
      print(_reservasFuture.length);
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
      body: FutureBuilder<List<Reserva>>(
        future: getReservas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras espera la carga de datos
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Si hay un error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Si los datos se cargan correctamente
            _reservasFuture = snapshot.data!;
            return vistaReservas();
          }
        },
      ),
    ),
  );
}

Widget vistaReservas() {
  return ListView.builder(
    itemCount: _reservasFuture.length,
    itemBuilder: (context, index) {
      final reserva = _reservasFuture[index];
      return ListTile(
        title: Text(reserva.direccion),
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      );
    },
  );
}

}