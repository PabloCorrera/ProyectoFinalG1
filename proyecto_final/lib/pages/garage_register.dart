import 'package:flutter/material.dart';

class GarageRegister extends StatelessWidget {
  GarageRegister({Key? key}) : super(key: key);
   static const String name = 'GarageRegister';

  final TextEditingController _controllerOwner = TextEditingController();
  final TextEditingController _controllerOwnerName = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String? errorMessage = '';

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () {
        // Aquí puedes agregar la lógica para confirmar el registro
      },
      child: Text('Confirmar'),
    );
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: title == "Contraseña",
      decoration: InputDecoration(
        labelText: title,
      ),
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
    body: Container(
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
          Text(
            'REGISTRO DE COCHERA', // Agregamos el título aquí
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _entryField('Nombre', _controllerOwner),
          const SizedBox(height: 20),
          _entryField('Apellido', _controllerOwnerName),
          const SizedBox(height: 20),
          _entryField('Descripcion', _description),
          _errorMessage(),
          const SizedBox(height: 20),
          _submitButton(),
        ],
      ),
    ),
  );
}

}
