import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
=======
import 'package:proyecto_final/entities/user.dart';
>>>>>>> 18c5c708b505018db03493db20f8ae291a0a02e2

const String USUARIO_CONSUMIDOR = "usuarioConsumidor";

class DatabaseService {
<<<<<<< HEAD

final _firesore = FirebaseFirestore.instance;

late final CollectionReference _usersRef;



=======
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _usuariosConsumidorRef;

  DatabaseService() {
    _usuariosConsumidorRef =
        _firestore.collection(USUARIO_CONSUMIDOR).withConverter<User>(
            fromFirestore: (snapshots, _) => User.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (user, _) => user.toJson());
  }

  Stream<QuerySnapshot> getUsuarios() {
    return _usuariosConsumidorRef.snapshots();
  }

  void addUsuario(User user) async {
    _usuariosConsumidorRef.add(user);
  }
>>>>>>> 18c5c708b505018db03493db20f8ae291a0a02e2
}
