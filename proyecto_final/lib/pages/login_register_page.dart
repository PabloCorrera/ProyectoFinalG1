import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/pages/home_page.dart';
import 'package:proyecto_final/pages/usuario_home.dart';
import 'package:proyecto_final/services/database_sevice.dart';

class LoginPage extends StatefulWidget {
  static const String name = 'LoginPage';

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  String? userMail = FirebaseAuth.instance.currentUser?.email;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      bool registrado =
          await _databaseService.validarUsuario(_controllerEmail.text);
      if (context.mounted && registrado) {
        context.pushNamed(
          UsuarioHome.name,
          extra: _controllerEmail.text, // Pasando el objeto user como argumento
        );
      } else {
        context.pushNamed(HomePage.name);
      }
      ;
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await Auth().signInWithGoogle();
      if (context.mounted) {
        context.pushNamed(HomePage.name);
      }
    } catch (e) {
      setState(() {
        errorMessage = "error $e";
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      if (context.mounted) {
        context.pushNamed(HomePage.name);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('Bienvenido a We Park');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      obscureText: title == "Contraseña" ? true : false,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(10)),
      child: TextButton(
          onPressed: isLogin
              ? signInWithEmailAndPassword
              : createUserWithEmailAndPassword,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin ? 'Login' : 'Register',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                FontAwesomeIcons.car,
                color: Colors.white,
              )
            ],
          )),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text(isLogin ? 'Register instead' : 'Login instead'));
  }

  Widget _signInWithGoogle() {
    if (isLogin) {
      return Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(10)),
        child: TextButton(
            onPressed: signInWithGoogle,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign in with Google',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  FontAwesomeIcons.google,
                  color: Colors.white,
                ),
              ],
            )),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _entryField('Email', _controllerEmail),
            _entryField('Contraseña', _controllerPassword),
            _errorMessage(),
            _submitButton(),
            const SizedBox(
              height: 5,
            ),
            _signInWithGoogle(),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}
