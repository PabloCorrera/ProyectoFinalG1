import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class RegisterPage extends StatelessWidget {
  static const name = 'register';
  
  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Register(),
    );
  }
}

class Register extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _lastName = TextEditingController();

  Register();

  final Map<String, String> _usuariosYContrasenias = {
    'pablo': 'pablo1',
    'clau': 'clau2',
    'juli': 'juli3',
    'brian': 'brian5',
    'ilan': 'ilan4',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text('Ingrese Usuario y contraseña')
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              hintText: 'Username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
            ),
        inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
        LengthLimitingTextInputFormatter(30),
      ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _name,
            obscureText: true, // Para ocultar la contraseña
            decoration: const InputDecoration(
              hintText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
            ),
             inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            LengthLimitingTextInputFormatter(30),
      ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _lastName,
            obscureText: true, // Para ocultar la contraseña
            decoration: const InputDecoration(
              hintText: 'LastName',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
            ),
          ),
        ),
         Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _passwordController,
            obscureText: true, // Para ocultar la contraseña
            decoration: const InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            String username = _usernameController.text;
            String password = _passwordController.text;
            String name = _name.text;
            String lastName = _lastName.text;
            
            if (_usuariosYContrasenias.containsKey(username) &&
                _usuariosYContrasenias[username] == password) {
              // Si son válidos, navega a la pantalla de inicio
            //  context.pushNamed(HomeScreen.name, extra: username);
            } else {
              // Si no son válidos, muestra un mensaje de error
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error de inicio de sesión'),
                    content: Text('Usuario o contraseña incorrectos.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: const Text('Login'),
        ),
      ],
    );
  }

}

