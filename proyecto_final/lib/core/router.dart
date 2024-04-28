import 'package:proyecto_final/pages/garage_home.dart';
import 'package:proyecto_final/pages/garage_register.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
import 'package:proyecto_final/pages/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/pages/user_register.dart';
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
    name: GarageRegister.name,
    path: '/garageRegister',
    builder: (context, state) => GarageRegister(),
  ), 

     GoRoute(
    name: UsuarioHome.name,
    path: '/usuarioHome',
    builder: (context, state) => const UsuarioHome(),
  ), 

       GoRoute(
    name: GarageHome.name,
    path: '/garageHome',
    builder: (context, state) => const GarageHome(),
  ),
  
]);
