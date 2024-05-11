import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/entities/usuario_consumidor.dart';
import 'package:proyecto_final/pages/income_home.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
import 'package:proyecto_final/pages/maps_page.dart';
import 'package:proyecto_final/services/database_sevice.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    setState(() {
      _reservasFuture = reservas;
    });

    await _loadUsuariosReservas();
  } catch (e) {
    print(e);
  }
}

  Future<void> _loadUsuariosReservas() async {
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
              leading: const Icon(Icons.edit),
              title: const Text('Editar mis datos'),
              onTap: () => {
                setState(() {
                  aMostrar = vistaEditar();
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
              leading: const Icon(Icons.bar_chart),
              title: const Text('Recaudado'),
              onTap: () => {
                setState(() {
                  context.pushNamed(IncomeHome.name, extra: _reservasFuture );
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

Future<UsuarioCochera> getUsuarioCochera(DatabaseService databaseService, email) async {

  UsuarioCochera? usuarioCochera = await  databaseService.buscarUsuarioCochera(email);

  if (usuarioCochera != null) {
    print('Usuario encontrado: ${usuarioCochera.nombre}');
    return usuarioCochera;
  } else {
    print('Usuario no encontrado');
    return usuarioCochera as UsuarioCochera;
  }
}


Widget vistaReservas() {
  return Column(
    children: [
      SizedBox(height: 12.0),
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
                  _mostrarDialogo(context, _reservasFuture[index], _usuariosDeReserva[index]!); 
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

 Widget vistaEditar() {
  // Define controladores para los campos de texto
  final TextEditingController nombreCocheraController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController cbuController = TextEditingController();

  return FutureBuilder<UsuarioCochera>(
    future: getUsuarioCochera(databaseService, user!.email!),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: 
          CircularProgressIndicator()
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        UsuarioCochera usuarioCochera = snapshot.data!;
        
        // Asigna los valores iniciales a los controladores
        nombreCocheraController.text = usuarioCochera.nombreCochera;
        descripcionController.text = usuarioCochera.descripcion;
        precioController.text = usuarioCochera.price.toString();
        //cbuController.text = usuarioCochera.cbu;

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
                  _entryField('CBU', cbuController),
                  const SizedBox(height: 20),
                  _submitButton(
                    nombreCocheraController,
                    descripcionController,
                    precioController,
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




Widget _submitButton(TextEditingController nombreCocheraController, TextEditingController descripcionController, TextEditingController precioController) {
  return ElevatedButton(
    onPressed: () async {
      String errorMessage = '';
      if(isNotBlank(nombreCocheraController.text) && isNotBlank(descripcionController.text) && isNotBlank(precioController.text)){
      String nombreCochera = nombreCocheraController.text;
      String descripcion = descripcionController.text;
      double precio = double.parse(precioController.text);
      print(precioController);
      Map<String, dynamic> updatedAttributes = {
        'nombreCochera': nombreCochera,
        'descripcion': descripcion,
        'price': precio,
      };
      ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
          content: Text('Los datos del usuario fueron editados correctamente'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
       setState(() {
        aMostrar = vistaReservas();
      });
      await databaseService.updateUsuarioCochera(user!.email!, updatedAttributes);

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
    child: Text('Editar'),
  );
}
  
bool isNotBlank(String value) {
    return value.trim().isNotEmpty;
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
                            "Entrada: ", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Texto en negrita
                          ),
                          Text(
                            "${formatter.format(fechaEntrada)}", 
                            style: TextStyle(fontSize: 16), // Texto normal
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                          SizedBox(width: 8.0),
                          Text(
                            "Salida: ",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Texto en negrita
                          ),
                          Text(
                            "${formatter.format(fechaSalida)}",
                            style: TextStyle(fontSize: 16), // Texto normal
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.moneyBillAlt, size: 16, color: Colors.blue),
                          SizedBox(width: 8.0),
                          Text(
                            "Precio total: ",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Texto en negrita
                          ),
                          Text(
                            "\$${reserva.precioTotal}", // Agrega el signo de pesos aquí
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
      final UsuarioConsumidor? consumidor =
          await databaseService.buscarUsuario(_reservasFuture[i].usuarioEmail);

      consumidoresDeReserva.add(
          await databaseService.buscarUsuario(_reservasFuture[i].usuarioEmail));
    }

    return consumidoresDeReserva;
  }
  


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
