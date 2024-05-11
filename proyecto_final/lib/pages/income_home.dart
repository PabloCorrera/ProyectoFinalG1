import 'package:flutter/material.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_consumidor.dart';
import 'package:proyecto_final/services/database_sevice.dart';

class IncomeHome extends StatefulWidget {
  static const String name = 'IncomeHome';

  final List<Reserva> reservas;

  const IncomeHome({Key? key, required this.reservas}) : super(key: key);

  @override
  State<IncomeHome> createState() => _IncomeHomeState();
}

class _IncomeHomeState extends State<IncomeHome> {
  late List<UsuarioConsumidor?> _usuariosDeReserva = [];
  late List<Reserva> reservasAnteriores = [];
  double totalRecaudado = 0;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    reservasAnteriores = widget.reservas.where((reserva) => reserva.fechaSalida.toDate().isBefore(now)).toList();
    for (final reserva in reservasAnteriores) {
      totalRecaudado += reserva.precioTotal;
    }
    _loadUsuariosReservas1();
  }

    Future<void> _loadUsuariosReservas1() async {
    await _loadUsuariosReservas();
  }


  Future<List<UsuarioConsumidor?>> getUsuariosDeReservas() async {
    final List<UsuarioConsumidor?> consumidoresDeReserva = [];

    for (int i = 0; i < reservasAnteriores.length; i++) {
      final UsuarioConsumidor? consumidor = await DatabaseService().buscarUsuario(reservasAnteriores[i].usuarioEmail);
      consumidoresDeReserva.add(consumidor);
    }

    setState(() {
    _usuariosDeReserva = consumidoresDeReserva;
    });

    return consumidoresDeReserva;
  }

  Future<void> _loadUsuariosReservas() async {
    List<UsuarioConsumidor?> usuariosConsum = await getUsuariosDeReservas() ?? [];
  

  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Income Home'),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(
                'Total Recaudado:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.money,
                    color: Colors.green, // Color del icono
                    size: 24, // Tamaño del icono
                  ),
                  SizedBox(width: 5), // Espacio entre el icono y el texto
                  Text(
                    '\$${totalRecaudado.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
              SizedBox(height: 16), // Espacio entre el total recaudado y el botón
              ElevatedButton(
                onPressed: () {
                  // Acción al presionar el botón
                },
                child: Text('Búsqueda avanzada'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _usuariosDeReserva.length,
            itemBuilder: (context, index) {
              final reserva = reservasAnteriores[index];
              return ListTile(
                leading: const Icon(Icons.event),
                title: Text("Reserva de " + _usuariosDeReserva[index]!.nombre + " " + _usuariosDeReserva[index]!.apellido),
                subtitle: Text(reservasAnteriores[index].precioTotal.toString()),
              );
            },
          ),
        ),
      ],
    ),
  );
}
  
  

}
