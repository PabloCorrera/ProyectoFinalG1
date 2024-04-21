import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_final/entities/user.dart';

const String USUARIO_CONSUMIDOR = "usuarioConsumidor";

class DatabaseService {
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
}
