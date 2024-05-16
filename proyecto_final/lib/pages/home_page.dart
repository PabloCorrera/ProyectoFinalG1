import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final/auth.dart';
import 'package:proyecto_final/pages/garage_register_autocomplete.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_final/pages/maps_page.dart';
import 'package:proyecto_final/pages/user_register.dart';

class HomePage extends StatefulWidget {
  static const String name = 'HomePage';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
    if (context.mounted) {
      context.pushNamed(LoginPage.name);
    }
  }

  Widget _title() {
    return const Text('Bienvenido a We Park');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(onPressed: signOut, child: const Text('Sign out'));
  }

  Widget _registerConsumerButton() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(10)),
      child: TextButton(
          onPressed: () => {context.pushNamed(UserRegister.name)},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Registrarse como consumidor',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                FontAwesomeIcons.userPlus,
                color: Colors.white,
              ),
            ],
          )),
    );
  }

  Widget _registerGarageButton() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(10)),
      child: TextButton(
          onPressed: () => {context.pushNamed(GarageRegisterAutoPlete.name)},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Registrarse como garage',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                FontAwesomeIcons.car,
                color: Colors.white,
              ),
            ],
          )),
    );
  }

  Widget _verMapa() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
          color: Color.fromARGB(197, 223, 1, 227),
          borderRadius: BorderRadius.circular(10)),
      child: TextButton(
          onPressed: () => {context.pushNamed(MapsPage.name)},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ver Mapa',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                FontAwesomeIcons.map,
                color: Colors.white,
              ),
            ],
          )),
    );
  }

  Widget _logOutButton() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(10)),
      child: TextButton(
          onPressed: () => {signOut()},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'cerrar sesion',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                FontAwesomeIcons.car,
                color: Colors.white,
              ),
            ],
          )),
    );
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
            _userUid(),
            const SizedBox(
              height: 20,
            ),
            _registerConsumerButton(),
            const SizedBox(
              height: 5,
            ),
            _registerGarageButton(),
            const SizedBox(
              height: 50,
            ),
            _signOutButton(),
          ],
        ),
      ),
    );
  }
}
