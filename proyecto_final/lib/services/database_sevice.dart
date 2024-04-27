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

  void addUser(User user) async {
    _usuariosConsumidorRef.add(user);
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
