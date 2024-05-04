
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/pages/garageDetail.dart';
import 'package:proyecto_final/services/database_sevice.dart'; // Importa el servicio de base de datos

class UsuarioHome extends StatefulWidget {
  UsuarioHome({Key? key}) : super(key: key);

  static const String name = 'usuarioHome';

  @override
  _UsuarioHomeState createState() => _UsuarioHomeState();
}

class _UsuarioHomeState extends State<UsuarioHome> {
  late Future<List<UsuarioCochera>> cocherasDisponibles;

  @override
void initState() {
  super.initState();
  print("TRAEMOS LAS COCHERAS DISPONIBLES");
  cocherasDisponibles = DatabaseService().getCocherasDisponibles();
  cocherasDisponibles.then((cocheras) {
    if (cocheras.isNotEmpty) {
      print(cocheras[0].descripcion);
    } else {
      print("No hay cocheras disponibles.");
    }
  });
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Welcome'), // Aquí estableces el título del AppBar
    ),

    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Bienvenido Usuariooo'), // Agrega aquí el texto
          SizedBox(height: 20), // Agrega un espacio entre el texto y el botón
          _ListaCocherasDisponibles(),
        ],
      ),
    ),
  );
}


  }

class _ListaCocherasDisponibles extends StatelessWidget {
  const _ListaCocherasDisponibles({
    super.key,
  });

  @override
Widget build(BuildContext context) {
  return ExpansionTile(
    title: Text('Cocheras disponibles'),
    children: usuariosCocheras
        .map(
          (cochera) => ListTile(
            title: Text(cochera.descripcion), // Muestra la descripción de la cochera
            subtitle: Text('Cantidad: ${cochera.cantLugares}'), // Muestra la cantidad de lugares disponibles
            onTap: () {
              context.pushNamed(GarageDetail.name);
              // Aquí puedes manejar el evento al seleccionar la cochera
            },
          ),
        )
        .toList(),
  );
}
}

