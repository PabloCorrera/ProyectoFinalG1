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
<<<<<<< HEAD

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


//  GoRoute(
//     name: UsuarioCocheraHome.name, // Nombre de la ruta corregido
//     path: '/usuarioCocheraHome', // Ruta corregida
//     builder: (context, state) => const UsuarioCocheraHome(), // Página corregida
//   ),
  
=======
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
>>>>>>> ca744a17fce8061d992929e9f996e49844f82700
]);
