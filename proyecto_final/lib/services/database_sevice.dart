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

}
