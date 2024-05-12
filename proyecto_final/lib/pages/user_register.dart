import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/core/utils.dart';
import 'package:proyecto_final/entities/usuario_consumidor.dart';
import 'package:proyecto_final/pages/usuario_home.dart';
import 'package:proyecto_final/services/database_sevice.dart';

class UserRegister extends StatefulWidget {
  UserRegister({Key? key}) : super(key: key);

  static const String name = 'UserRegister';

  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerSurname = TextEditingController();
  String? userMail = FirebaseAuth.FirebaseAuth.instance.currentUser?.email;
  String? errorMessage = '';
  Uint8List? imagen;
  XFile? fileImagen;

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
      ],
    );
  }

  Widget _title() {
    return const Text(
      'Registro de Usuario',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void registrarUsuario() async {
    if (_controllerName.text.trim().isNotEmpty &&
        _controllerSurname.text.trim().isNotEmpty) {
      UsuarioConsumidor user = UsuarioConsumidor(
        nombre: _controllerName.text,
        apellido: _controllerSurname.text,
        email: userMail,
        imageUrl: ""
      );
      String urlImagen = "";
      if (fileImagen != null) {
        String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();

        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirImages = referenceRoot.child('images');
        Reference imagenASubir = referenceDirImages.child(uniqueName);
        try {
          await imagenASubir.putFile(File(fileImagen!.path));
          await imagenASubir.getDownloadURL().then((value) => urlImagen = value);
        } catch (error) {
          print(error);
          urlImagen = "";
        }
      }
      user.imageUrl = urlImagen;

      _databaseService.addUsuarioConsumidor(user);
       await Future.delayed(const Duration(seconds: 3)); 
      context.pushNamed(UsuarioHome.name);
    } else {
      setState(() {
        errorMessage = 'Por favor, complete todos los campos correctamente.';
      });
    }
  }

  Widget _submitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => registrarUsuario(),
      child: const Text('Confirmar'),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : '¡Ups! $errorMessage',
      style: const TextStyle(
        color: Colors.red,
      ),
    );
  }

  Widget imagePicker() {
    return Stack(
      children: [
        imagen != null
            ? CircleAvatar(
                radius: 64,
                backgroundImage: MemoryImage(imagen!),
              )
            : const CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/9131/9131529.png'),
              ),
        Positioned(
          bottom: -10,
          left: 80,
          child: IconButton(
            onPressed: () => selectImage(),
            icon: const Icon(Icons.add_a_photo),
          ),
        )
      ],
    );
  }

  selectImage() async {
    XFile? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      img.readAsBytes().then((foto) => {
            setState(() {
              imagen = foto;
              fileImagen = img;
            })
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFAF0050),
              Color(0x00EF5350),
            ],
            begin: Alignment.topCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'REGISTRO DE USUARIO',
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
            imagePicker(),
            const SizedBox(height: 20),
            _errorMessage(),
            const SizedBox(height: 20),
            _submitButton(context),
          ],
        ),
      ),
    );
  }
}
