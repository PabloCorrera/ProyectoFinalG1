import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/pages/usuario_home.dart';
import 'package:proyecto_final/services/database_sevice.dart';

class MapsPage extends StatefulWidget {
  static const String name = 'mapsPage';
  const MapsPage({super.key});
  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<UsuarioCochera> _cocheras = [];
  List<LatLng> posiciones = [];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-34.61014682261275, -58.429135724657954),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(-34.61014682261275, -58.429135724657954),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "Busca tu garage mas cercano",
        style: TextStyle(color: Colors.black),
      )),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _cocherasDisponibles(),
      ),

      // Boton para agregar alguna funcionalidad
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('Buscar cocheras'),
        icon: const Icon(Icons.directions_car_filled_outlined),
      ),
    );
  }

//Metodo para ir a un punto en particular
  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Set<Marker> _cocherasDisponibles() {
    var marcadores = Set<Marker>();

    for (UsuarioCochera u in _cocheras) {
      marcadores.add(Marker(
          markerId: MarkerId(u.nombre),
          position: LatLng(u.lat, u.lng),
          infoWindow: InfoWindow(title: u.nombreCochera),
          onTap: () => context.pushNamed(UsuarioHome.name)));
    }

    return marcadores;
  }

  Future<void> _cargarUsuarios() async {
    List<UsuarioCochera> usuarios =
        await DatabaseService().getUsuariosCochera();
    ;
    setState(() {
      _cocheras = usuarios;
    });
  }
}