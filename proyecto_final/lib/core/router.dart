import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_consumidor.dart';
import 'package:proyecto_final/pages/garage_register_autocomplete.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
import 'package:proyecto_final/pages/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/pages/maps_page.dart';
import 'package:proyecto_final/pages/user_register.dart';
import 'package:proyecto_final/pages/usuario_cochera_home.dart';
import 'package:proyecto_final/pages/usuario_home.dart';
import 'package:proyecto_final/wrapper.dart';

final appRouter = GoRouter(routes: [
  GoRoute(
    name: Wrapper.name,
    path: '/',
    builder: (context, state) => const Wrapper(),
  ),
  GoRoute(
    name: LoginPage.name,
    path: '/login',
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
    builder: (context, state) => const GarageRegisterAutoPlete(),
  ),
  GoRoute(
    name: MapsPage.name,
    path: '/mapsPage',
    builder: (context, state) => const MapsPage(),
  ),
GoRoute(
    name: UsuarioHome.name,
    path: '/usuarioHome',
    builder: (context, state) => const UsuarioHome(),
  ),

  GoRoute(
    name: UsuarioCocheraHome.name,
    path: '/usuarioCochera',
    builder: (context, state) => const UsuarioCocheraHome(),
  ),




]);
