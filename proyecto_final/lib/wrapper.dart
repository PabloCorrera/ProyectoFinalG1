import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final/pages/home_page.dart';
import 'package:proyecto_final/pages/login_register_page.dart';
import 'package:proyecto_final/pages/user_register.dart';
import 'package:proyecto_final/pages/usuario_cochera_home.dart';
import 'package:proyecto_final/pages/usuario_home.dart';
import 'package:proyecto_final/services/database_sevice.dart';

class Wrapper extends StatefulWidget {
  static const String name = 'Wrapper';
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
//    FirebaseAuth.instance.authStateChanges().firstWhere((user) => user != null).then((user) {
//   if (user != null) {
//     redirigirUsuario(user.email!);
//   } else {
//     context.pushNamed(LoginPage.name);
//   }
// });

    return LoginPage();
  }

  Future<void> redirigirUsuario(String email) async {
    bool isConsumer =
        await DatabaseService().getTipoUsuario(email) == "consumidor";
    bool isOwner = await DatabaseService().getTipoUsuario(email) == "cochera";
    if (!kIsWeb) {
      if (isConsumer) {
        context.pushNamed(UsuarioHome.name);
      } else if (isOwner) {
        context.pushNamed(UsuarioCocheraHome.name);
      } else {
        context.pushNamed(HomePage.name);
      }
    } else {
      context.pushNamed(LoginPage.name);
    }
  }
}
