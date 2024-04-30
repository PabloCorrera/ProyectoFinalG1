import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_final/entities/cochera.dart';

import 'package:proyecto_final/entities/user.dart';

const String USUARIO_CONSUMIDOR = "usuarioConsumidor";
const String COCHERA = "cochera";

class DatabaseService {

  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _usuariosConsumidorRef;
  late final CollectionReference _cocheraRef;

  DatabaseService() {
    _usuariosConsumidorRef =
        _firestore.collection(USUARIO_CONSUMIDOR).withConverter<User>(
            fromFirestore: (snapshots, _) => User.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (user, _) => user.toJson(),
        );
    _cocheraRef = 
    _firestore.collection(COCHERA).withConverter<Cochera>(
      fromFirestore: (snapshots, _) => Cochera.fromJson(
        snapshots.data()!
        ),
        toFirestore: (cochera, _) => cochera.toJson(),
  );
  }

  

  Stream<QuerySnapshot> getUsuarios() {
    return _usuariosConsumidorRef.snapshots();
  }

Future<bool> addUser(User user) async {
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

Future<bool> validarUsuario(String email) async {
  try {
    var query = await _usuariosConsumidorRef.where('email', isEqualTo: email).get();
    return query.docs.isNotEmpty;
  } catch (e) {
    print('Error al validar el usuario: $e');
    return false; // Manejo del error: en este caso, se asume que el usuario no existe
  }
}

  void addCochera(Cochera cochera) async {
    _cocheraRef.add(cochera);
  }

  void updateUser(String email, String nombre, String apellido) async {
  // Primero, obtén una referencia al documento del usuario usando su email
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('USUARIO_CONSUMIDOR')
      .where('email', isEqualTo: email)
      .get();

  // Verifica si se encontró un documento con el email proporcionado
  if (querySnapshot.docs.isNotEmpty) {
    // Si se encontró un documento, actualiza sus datos
    String docId = querySnapshot.docs.first.id;
    DocumentReference userRef = FirebaseFirestore.instance.collection('USUARIO_CONSUMIDOR').doc(docId);

    // Actualiza el nombre y apellido del usuario
    await userRef.update({
      'nombre': nombre,
      'apellido': apellido,
    });
  }
  }

}
