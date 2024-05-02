import 'package:proyecto_final/pages/garage_register.dart';
import 'package:proyecto_final/pages/garage_register_autocomplete.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
import 'package:proyecto_final/pages/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/pages/maps_page.dart';
import 'package:proyecto_final/pages/user_register.dart';
import 'package:proyecto_final/pages/usuario_cochera_home.dart';
import 'package:proyecto_final/pages/usuario_home.dart';

final appRouter = GoRouter(routes: [
  GoRoute(
    name: LoginPage.name,
    path: '/',
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    name: HomePage.name,
    path: '/home',
    builder: (context, state) => const HomePage(),
  ),
  GoRoute(
    name: UserRegister.name,
    path: '/userregister',
    builder: (context, state) => UserRegister(),
  ),
  GoRoute(
    name: GarageRegisterAutoPlete.name,
    path: '/garageRegisterAutoPlete',
    builder: (context, state) => GarageRegisterAutoPlete(),
  ),
  GoRoute(
    name: MapsPage.name,
    path: '/mapsPage',
    builder: (context, state) => MapsPage(),
  ),
GoRoute(
    name: UsuarioHome.name,
    path: '/usuarioHome',
    builder: (context, state) => UsuarioHome(),
  ),

]);
