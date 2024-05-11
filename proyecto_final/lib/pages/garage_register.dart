import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/pages/usuario_cochera_home.dart';
import 'package:proyecto_final/services/database_sevice.dart';

class GarageRegister extends StatelessWidget {
  GarageRegister({Key? key}) : super(key: key);
   static const String name = 'GarageRegister';


  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _controllerGarageName = TextEditingController();
  final TextEditingController _controllerGarageAdress = TextEditingController();
  final TextEditingController _controllerQuantitySpaces = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerSurname = TextEditingController();
  final TextEditingController _controllerCBU = TextEditingController();
  
  String? errorMessage = '';
  String? emailUsuario = FirebaseAuth.instance.currentUser?.email;
  
  Widget _submitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        String email = emailUsuario ?? "";

        UsuarioCochera usuarioCochera = UsuarioCochera(
          nombre: _controllerName.text,
          apellido: _controllerSurname.text,
          email: email,
          nombreCochera: _controllerGarageName.text,
          direccion: _controllerGarageAdress.text,
          descripcion: _description.text,
          price: double.parse(_controllerPrice.text),
        cantLugares: int.parse(_controllerQuantitySpaces.text),
        CBU: _controllerCBU.text,
        );    
        _databaseService.addUsuarioCochera(usuarioCochera);
        context.pushNamed(UsuarioCocheraHome.name);
      },
      child: Text('Confirmar'),
    );
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _entryFieldNumber(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    ] 
    );
  }

  Widget _title () {
    return const Text (
      'Registro de Cochera',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : '¡Ups! $errorMessage',
      style: TextStyle(
         color: Colors.red,
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: _title(),
    ),
    body: SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration (
          gradient: LinearGradient(
            colors: [
              Color(0xFFAF0050),
              Color(0x00EF5350),
            ],
            begin: Alignment.topCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'REGISTRO DE COCHERA', 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, 
              ),
            ),
            const SizedBox(height: 20),
            _entryField('Nombre', _controllerName),
            const SizedBox(height: 20),
            _entryField('Apellido', _controllerSurname),
            const SizedBox(height: 20),
            _entryField('Nombre Estacionamiento', _controllerGarageName),
            const SizedBox(height: 20),
             _entryField('Descripcion', _description),
            const SizedBox(height: 20),
            _entryField('Direccion', _controllerGarageAdress, ),
            const SizedBox(height: 20),
            _entryFieldNumber('Precio por hora', _controllerPrice),
            const SizedBox(height: 20),
            _entryFieldNumber('Cantidad de lugares', _controllerQuantitySpaces),
             const SizedBox(height: 20),
            _entryField('CBU', _controllerCBU),
      
            _errorMessage(),
            _submitButton(context),
          ],
        ),
      ),
    ),
  );
}
}