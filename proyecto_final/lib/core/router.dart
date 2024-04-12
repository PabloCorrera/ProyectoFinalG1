import 'package:proyecto_final/home/login_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(routes: [
  GoRoute(
    name: LoginScreen.name,
    path: '/',
    builder: (context, state) => LoginScreen(),
  ),
/* GoRoute(
    name: LoginScreen.name,
    path: '/home',
    builder: (context, state) => LoginScreen(userName: state.extra as String),
  ), 
  */
]);
