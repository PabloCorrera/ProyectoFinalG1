import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/models/constant.dart';
import 'package:proyecto_final/pages/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:proyecto_final/pages/usuario_cochera_home.dart';
import 'package:proyecto_final/pages/usuario_home.dart';
import 'package:proyecto_final/services/database_sevice.dart';
import 'package:proyecto_final/services/local_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  static const String name = 'LoginPage';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late StreamSubscription<User?> user;
  String? errorMessage = '';
  bool isLogin = true;
  String? userMail = FirebaseAuth.instance.currentUser?.email;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  DatabaseService databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    obtenerCredenciales();
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<void> obtenerCredenciales() async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('usarAutenticacionBiometrica') == true) {
      try {
        bool isAuthorized = await LocalAuth.authenticate();
        if (isAuthorized) {
          String? usuario = await storage.read(key: 'usuario');
          String? contrasena = await storage.read(key: 'contrasena');
          if (usuario != null && contrasena != null) {
            try {
              await Auth()
                  .signInWithEmailAndPassword(
                      email: usuario, password: contrasena)
                  .then((value) => redirigirUsuario(usuario));
            } on FirebaseAuthException catch (e) {
              setState(() {
                errorMessage = e.message;
              });
            }
          }
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      if (!kIsWeb) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (prefs.getBool('usarAutenticacionBiometrica') == null) {
          bool? usarAutenticacionBiometrica = await _mostrarDialogo(context);
          if (usarAutenticacionBiometrica != null) {
            _guardarPreferencia(usarAutenticacionBiometrica);
            if (usarAutenticacionBiometrica) {
              guardarCredenciales(
                  _controllerEmail.text, _controllerPassword.text);
            }
          }
        }
      }
      await redirigirUsuario(_controllerEmail.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> redirigirUsuario(String email) async {
    bool isConsumer =
        await databaseService.getTipoUsuario(email) == "consumidor";
    bool isOwner = await databaseService.getTipoUsuario(email) == "cochera";
    if (!kIsWeb) {
      if (isConsumer) {
        context.pushNamed(UsuarioHome.name);
      } else if (isOwner) {
        context.pushNamed(UsuarioCocheraHome.name);
      } else {
        context.pushNamed(HomePage.name);
      }
    } else {
      if (isConsumer) {
        setState(() {
          errorMessage = "Utilice la version mobile de la aplicación";
        });
      } else if (isOwner) {
        context.pushNamed(UsuarioCocheraHome.name);
      } else {
        setState(() {
          errorMessage =
              "Por favor, complete el proceso de registro desde la aplicación";
        });
      }
    }
  }

  Future<bool?> _mostrarDialogo(BuildContext context) {
    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Habilitar autenticación biométrica'),
          content: const Text(
              '¿Desea utilizar autenticación biométrica para futuros inicios de sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardarPreferencia(bool usarAutenticacionBiometrica) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('usarAutenticacionBiometrica', usarAutenticacionBiometrica);
  }

  void guardarCredenciales(String usuario, String contrasena) async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    await storage.write(key: 'usuario', value: usuario);
    await storage.write(key: 'contrasena', value: contrasena);
  }

  Future<void> signInWithGoogle() async {
    try {
      await Auth().signInWithGoogle();
      if (context.mounted) {
        redirigirUsuario(Auth().currentUser!.email!);
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
    return Text('Bienvenido a wePark',
        // selectionColor: Theme.of(context).primaryColor,
        style: GoogleFonts.rowdies(
            textStyle: Theme.of(context).textTheme.titleLarge));
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: title == "Contraseña" ? true : false,
      decoration: InputDecoration(
        labelText: title,
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
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
        color: Theme.of(context).indicatorColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () async {
          // Mostrar el diálogo con el indicador de carga
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: CircularProgressIndicator());
            },
          );

          try {
            if (isLogin) {
              await signInWithEmailAndPassword();
            } else {
              await createUserWithEmailAndPassword();
            }
          } catch (e) {
            // Maneja el error si es necesario
          } finally {
            // Cerrar el diálogo después de completar la operación
            Navigator.pop(context);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLogin ? 'Login' : 'Register',
              selectionColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 5),
            const Icon(
              FontAwesomeIcons.car,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        setState(() {
          isLogin = !isLogin;
        });

        Navigator.pop(context);
      },
      child: Text(isLogin ? 'Registrate en wePark' : 'Iniciar sesión'),
    );
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
                  style: TextStyle(color: magnolia),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _title(),
                  _entryField('Email', _controllerEmail),
                  _entryField('Contraseña', _controllerPassword),
                  _errorMessage(),
                  _submitButton(),
                  const SizedBox(
                    height: 5,
                  ),
                  _signInWithGoogle(),
                  !kIsWeb ? _loginOrRegisterButton() : const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
