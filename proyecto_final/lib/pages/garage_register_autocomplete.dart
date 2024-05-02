import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/models/autocomplete_prediction.dart';
import 'package:proyecto_final/services/database_sevice.dart';
import 'package:proyecto_final/services/location_list_tile.dart';
import '../models/constant.dart';

class GarageRegisterAutoPlete extends StatefulWidget {
  const GarageRegisterAutoPlete({Key? key}) : super(key: key);
  static const String name = 'garageRegisterAutoPlete';

  @override
  State<GarageRegisterAutoPlete> createState() => _GarageRegisterAutoPlete();
}

class _GarageRegisterAutoPlete extends State<GarageRegisterAutoPlete> {
  List<AutocompletePrediction> placePredictions = [];
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _controllerGarageName = TextEditingController();
  final TextEditingController _controllerGarageAdress = TextEditingController();
  final TextEditingController _controllerQuantitySpaces = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerSurname = TextEditingController();

  bool showSourceField = false;
  String? emailUsuario = FirebaseAuth.instance.currentUser?.email;

  String? errorMessage = '';

  //funcion AUTO complete de google
  Future<String> showGoogleAutoComplete() async {
    try {
      const kGoogleApiKey = apiKey;
      String calle = "no encontrada";
      Prediction? p = Prediction(description: "no econtrada");
      p = await PlacesAutocomplete.show(
          offset: 0,
          radius: 1000,
          strictbounds: false,
          region: "ar",
          context: context,
          apiKey: kGoogleApiKey,
          mode: Mode.overlay, // Mode.fullscreen
          language: "es",
          types: ["address"],
          hint: "Search place",
          components: [new Component(Component.country, "ar")]);
      return p!.description!;
    } catch (e) {
      String calle = "no encontrada";
      print("Error al obtener predicciones de lugares: $e");
      return calle;
    }
  }

  static bool isNotBlank(String value) {
  return value.trim().isNotEmpty;
}

  Widget _submitButton() {
  return ElevatedButton(
    onPressed: () {
      String email = emailUsuario ?? "";
      if (isNotBlank(_controllerName.text) &&
          isNotBlank(_controllerSurname.text) &&
          isNotBlank(_controllerGarageName.text) &&
          isNotBlank(_controllerGarageAdress.text) &&
          isNotBlank(_description.text) &&
          isNotBlank(_controllerPrice.text) &&
          isNotBlank(_controllerQuantitySpaces.text)) {
        UsuarioCochera usuarioCochera = UsuarioCochera(
          nombre: _controllerName.text,
          apellido: _controllerSurname.text,
          email: email,
          nombreCochera: _controllerGarageName.text,
          direccion: _controllerGarageAdress.text,
          descripcion: _description.text,
          price: double.parse(_controllerPrice.text),
          cantLugares: int.parse(_controllerQuantitySpaces.text),
        );
        _databaseService.addUsuarioCochera(usuarioCochera);
      } else {
        setState(() {
          errorMessage = 'Por favor, complete todos los campos correctamente.';
        });
      }
    },
    child: Text('Confirmar'),
  );
}

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
    ],
    );
  }

  Widget _entryFieldNumber(String title, TextEditingController controller) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ]);
  }

  Widget _title() {
    return const Text(
      'Registro de Cochera',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : '¡Ups! $errorMessage',
      style: TextStyle(
        color: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFAF0050),
                Color(0x00EF5350),
              ],
              begin: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'REGISTRO DE COCHERA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _entryField('Nombre', _controllerName),
              const SizedBox(height: 20),
              _entryField('Apellido', _controllerSurname),
              const SizedBox(height: 20),
              _entryField('Nombre Estacionamiento', _controllerGarageName),
              const SizedBox(height: 20),
              _entryField('Descripcion', _description),
              const SizedBox(height: 20),
              //_entryField('Direccion', _controllerGarageAdress, ),
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: TextFormField(
                  controller: _controllerGarageAdress,
                  onTap: () async {
                    try {
                      String selectedPlace = await showGoogleAutoComplete();
                      _controllerGarageAdress.text = selectedPlace;

                      setState(() {
                        showSourceField = true;
                      });
                    } catch (e) {
                      print("te la mandaste con algo perri $e");
                    }
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: "Buscar tu direccion",
                  ),
                ),
              ),

              ListView.builder(
                itemCount: placePredictions.length,
                shrinkWrap:
                    true, // Este atributo es importante para evitar un error de desbordamiento
                //  physics:
                //    NeverScrollableScrollPhysics(), // Deshabilita el desplazamiento de esta ListView
                itemBuilder: (context, index) => LocationListTile(
                  press: () {},
                  location: placePredictions[index].description!,
                ),
              ),

              _entryFieldNumber('Precio por hora', _controllerPrice),
              const SizedBox(height: 20),
              _entryFieldNumber(
                  'Cantidad de lugares', _controllerQuantitySpaces),

              _errorMessage(),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }
}
