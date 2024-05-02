import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/entities/usuario_consumidor.dart';

const String USUARIO_CONSUMIDOR = "usuarioConsumidor";
const String USUARIO_COCHERA = "usuarioCochera";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _usuariosConsumidorRef;
  late final CollectionReference _usuariosCocheraRef;
  
  DatabaseService() {
    _usuariosConsumidorRef =
        _firestore.collection(USUARIO_CONSUMIDOR).withConverter<UsuarioConsumidor>(
              fromFirestore: (snapshots, _) => UsuarioConsumidor.fromJson(
                snapshots.data()!,
              ),
              toFirestore: (user, _) => user.toJson(),
            );
    _usuariosCocheraRef = _firestore.collection(USUARIO_COCHERA).withConverter<UsuarioCochera>(
          fromFirestore: (snapshots, _) => UsuarioCochera.fromJson(snapshots.data()!),
          toFirestore: (cochera, _) => cochera.toJson(),
        );
  }

  Stream<QuerySnapshot> getUsuarios() {
    return _usuariosConsumidorRef.snapshots();
  }

  Future<bool> addUsuarioConsumidor(UsuarioConsumidor user) async {
    try {
      // Realizar una consulta para verificar si el correo electrónico ya existe
      var query = await _usuariosConsumidorRef
          .where('email', isEqualTo: user.email)
          .get();

      // Verificar si la consulta devolvió algún documento
      if (query.docs.isEmpty) {
        // Si no se encontró ningún documento con el mismo correo electrónico, agregar el usuario
        await _usuariosConsumidorRef.add(user);
        return true; // Indicar que el usuario se agregó con éxito
      } else {
        // Si se encontró algún documento, el correo electrónico ya existe en la base de datos
        // Aquí puedes manejar la lógica para mostrar un mensaje de error o realizar otras acciones
        print('El correo electrónico ya existe en la base de datos');
        return false; // Indicar que hubo un problema al agregar el usuario
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante el proceso
      print('Error al agregar el usuario: $e');
      return false; // Indicar que hubo un problema al agregar el usuario
    }
  }


  Future<bool> addUsuarioCochera(UsuarioCochera userCochera) async {
    try {
      // Realizar una consulta para verificar si el correo electrónico ya existe
      var query = await _usuariosCocheraRef
          .where('email', isEqualTo: userCochera.email)
          .get();

      // Verificar si la consulta devolvió algún documento
      if (query.docs.isEmpty) {
        // Si no se encontró ningún documento con el mismo correo electrónico, agregar el usuario
        await _usuariosCocheraRef.add(userCochera);
        return true; // Indicar que el usuario se agregó con éxito
      } else {
        // Si se encontró algún documento, el correo electrónico ya existe en la base de datos
        // Aquí puedes manejar la lógica para mostrar un mensaje de error o realizar otras acciones
        print('El correo electrónico ya existe en la base de datos');
        return false; // Indicar que hubo un problema al agregar el usuario
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante el proceso
      print('Error al agregar el usuario: $e');
      return false; // Indicar que hubo un problema al agregar el usuario
    }
  }

  Future<String?> getTipoUsuario(String email) async {
    try {
      var queryConsumidor = await _usuariosConsumidorRef.where('email', isEqualTo: email).get();
      var queryCochera = await _usuariosCocheraRef.where('email', isEqualTo: email).get();

      if (queryConsumidor.docs.isNotEmpty) {
        return 'consumidor';
      } else if (queryCochera.docs.isNotEmpty) {
        return 'cochera';
      } else {
        return null; // Usuario no encontrado
      }
    } catch (e) {
      print('Error al obtener el tipo de usuario: $e');
      return null;
    }
  }



Future<bool> validarUsuario(String email) async {
  try {
    var queryConsumidor = await _usuariosConsumidorRef.where('email', isEqualTo: email).get();
    var queryDuenio = await _usuariosCocheraRef.where('email', isEqualTo: email).get();

    return queryConsumidor.docs.isNotEmpty || queryDuenio.docs.isNotEmpty;
  } catch (e) {
    print('Error al validar el usuario: $e');
    return false; // Manejo del error: en este caso, se asume que el usuario no existe
  }
}

  void updateUsuarioConsumidor(String email, String nombre, String apellido) async {
    // Primero, obtén una referencia al documento del usuario usando su email
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('USUARIO_CONSUMIDOR')
        .where('email', isEqualTo: email)
        .get();

    // Verifica si se encontró un documento con el email proporcionado
    if (querySnapshot.docs.isNotEmpty) {
      // Si se encontró un documento, actualiza sus datos
      String docId = querySnapshot.docs.first.id;
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('USUARIO_CONSUMIDOR')
          .doc(docId);

      // Actualiza el nombre y apellido del usuario
      await userRef.update({
        'nombre': nombre,
        'apellido': apellido,
      });
    }
  }
}
