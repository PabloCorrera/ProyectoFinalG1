import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_final/entities/reserva.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/entities/usuario_consumidor.dart';

const String USUARIO_CONSUMIDOR = "usuarioConsumidor";
const String USUARIO_COCHERA = "usuarioCochera";
const String RESERVA = "reserva";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _usuariosConsumidorRef;
  late final CollectionReference _usuariosCocheraRef;
  late final CollectionReference _reservaRef;
  
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

    _reservaRef = _firestore.collection(RESERVA).withConverter<Reserva>(
      fromFirestore: (snapshots, _)=> Reserva.fromJson(
            snapshots.data()!,
          ),
          toFirestore: (res, _) =>res.toJson(),
          );
  }

  Stream<QuerySnapshot> getUsuarios() {
    return _usuariosConsumidorRef.snapshots();
  }

  Future<bool> addUsuarioConsumidor(UsuarioConsumidor user) async {
    try {

      var query = await _usuariosConsumidorRef
          .where('email', isEqualTo: user.email)
          .get();

      if (query.docs.isEmpty) {
        await _usuariosConsumidorRef.add(user);
        return true;
      } else {
        print('El correo electrónico ya existe en la base de datos');
        return false;
      }
    } catch (e) {
     
      print('Error al agregar el usuario: $e');
      return false;
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

  Future<void> updateUsuarioCochera(String email, Map<String, dynamic> updatedAttributes) async {
  try {
    // Realiza una consulta para obtener el documento del usuario cochera usando su correo electrónico
    var querySnapshot = await _usuariosCocheraRef.where('email', isEqualTo: email).get();
    print(updatedAttributes);
    // Verifica si se encontró un documento con el correo electrónico proporcionado
    if (querySnapshot.docs.isNotEmpty) {
      // Si se encontró un documento, actualiza sus datos
      String docId = querySnapshot.docs.first.id;
      DocumentReference userRef = _usuariosCocheraRef.doc(docId);

      // Actualiza los atributos proporcionados en el mapa
      await userRef.update(updatedAttributes);
      print('Usuario cochera actualizado correctamente');
    } else {
      // Si no se encontró ningún documento con el correo electrónico dado, muestra un mensaje de error
      print('No se encontró ningún usuario cochera con el correo electrónico proporcionado');
    }
  } catch (e) {
    // Manejar cualquier error que ocurra durante el proceso
    print('Error al actualizar el usuario cochera: $e');
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

Future<List<UsuarioCochera>> getCocherasDisponibles() async {
  try {
    List<UsuarioCochera> cocherasDisponibles = usuariosCocheras
        .where((cochera) => cochera.cantLugares > 0)
        .toList();

    return cocherasDisponibles;
  } catch (e) {
    print('Error al obtener las cocheras con lugares disponibles: $e');
    return [];
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
 Future<bool> addReserva(Reserva reserva) async {
    try {
        await _reservaRef.add(reserva);
        return true;
    } catch (e) {
      print('Error al agregar el usuario: $e');
      return false; 
    }
  }

  Future<void> eliminarReserva(String id)async{
    _firestore.collection(RESERVA).doc(id).delete().then((value) => {null});
  }

  Future<List<UsuarioCochera>> getUsuariosCochera() async {
    final ref = _firestore.collection(USUARIO_COCHERA)
    .withConverter(fromFirestore: UsuarioCochera.fromFirestore, toFirestore:(UsuarioCochera usuarioCochera,_)=> usuarioCochera.toFirestore());
    List<UsuarioCochera> usuariosCochera = [];
    final docSnap = await ref.get();
    docSnap.docs.forEach((element) {
      usuariosCochera.add(element.data());
    }); 

    return usuariosCochera;
}

Future<List<Reserva>> getReservasPorCochera(String mailCochera)async{
final ref = _firestore.collection(RESERVA)
.where("cocheraEmail",isEqualTo: mailCochera)
.withConverter(fromFirestore: Reserva.fromFirestore, toFirestore: (Reserva reserva,_)=>reserva.toFirestore());
List<Reserva> listaReservas = [];
final docSnap = await ref.get();
docSnap.docs.forEach((element) {
  listaReservas.add(element.data());
});

return listaReservas;
}
Future<Reserva?> getReservaById(String id)async{
  final ref = _firestore.collection(RESERVA)
.doc(id)
.withConverter(fromFirestore: Reserva.fromFirestore, toFirestore: (Reserva reserva,_)=>reserva.toFirestore());
  final docSnap = await ref.get();
  return docSnap.data();
}

Future<List<Reserva>> getReservasPorUsuario(String mailUsuario)async{
final ref = _firestore.collection(RESERVA)
.where("usuarioEmail",isEqualTo: mailUsuario)
.orderBy("fechaCreacion",descending: true)
.withConverter(fromFirestore: Reserva.fromFirestore, toFirestore: (Reserva reserva,_)=>reserva.toFirestore());
List<Reserva> listaReservas = [];
final docSnap = await ref.get();
docSnap.docs.forEach((element) {
  listaReservas.add(element.data());
});

return listaReservas;
}

Future<UsuarioConsumidor> getConsumidorByEmail(String mailUsuario) async {
  final ref = _firestore.collection(USUARIO_CONSUMIDOR)
  .where("email",isEqualTo: mailUsuario)
  .withConverter(fromFirestore: UsuarioConsumidor.fromFirestore, toFirestore: (UsuarioConsumidor user,_)=>user.toFirestore());
  final docSnap = await ref.get();
  UsuarioConsumidor uc = UsuarioConsumidor();
    docSnap.docs.forEach((element){ 
      uc = element.data();
    });
    return uc;
}

Future<UsuarioCochera> getCocheraByEmail(String mailCochera) async {
  final ref = _firestore.collection(USUARIO_COCHERA)
  .where("email",isEqualTo: mailCochera)
  .withConverter(fromFirestore: UsuarioCochera.fromFirestore, toFirestore: (UsuarioCochera user,_)=>user.toFirestore());
  final docSnap = await ref.get();
  UsuarioCochera uc = UsuarioCochera();
    docSnap.docs.forEach((element){ 
      uc = element.data();
    });
    return uc;
}

  Future<UsuarioConsumidor?> buscarUsuario(String usuarioEmail) async {
    try {
      print("DATABASEEEEEEE");
      // Realiza una consulta para buscar al usuario por su correo electrónico
      var query = await _usuariosConsumidorRef
          .where('email', isEqualTo: usuarioEmail)
          .get();

      // Verifica si la consulta devolvió algún documento
      if (query.docs.isNotEmpty) {
        // Si se encontró un documento, convierte los datos a un objeto UsuarioConsumidor y devuélvelo
        return query.docs.first.data() as UsuarioConsumidor?;
      } else {
        // Si no se encontró ningún documento con el correo electrónico dado, devuelve null
        return null;
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante el proceso
      print('Error al buscar el usuario: $e');
      return null;
    }
  }


  Future<UsuarioCochera?> buscarUsuarioCochera(String usuarioEmail) async {
    try {
      print("DATABASE COCHERA");
      // Realiza una consulta para buscar al usuario por su correo electrónico
      var query = await _usuariosCocheraRef
          .where('email', isEqualTo: usuarioEmail)
          .get();

      // Verifica si la consulta devolvió algún documento
      if (query.docs.isNotEmpty) {
        // Si se encontró un documento, convierte los datos a un objeto UsuarioConsumidor y devuélvelo
        return query.docs.first.data() as UsuarioCochera?;
      } else {
        // Si no se encontró ningún documento con el correo electrónico dado, devuelve null
        return null;
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante el proceso
      print('Error al buscar el usuario: $e');
      return null;
    }
  }
}





