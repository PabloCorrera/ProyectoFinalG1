import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_final/core/utils.dart';
import 'package:proyecto_final/entities/usuario_cochera.dart';
import 'package:proyecto_final/models/autocomplete_prediction.dart';
import 'package:proyecto_final/pages/usuario_cochera_home.dart';
import 'package:proyecto_final/services/database_sevice.dart';
import 'package:proyecto_final/services/location_list_tile.dart';
import '../models/constant.dart';
import 'package:geocoding/geocoding.dart' as geo;

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
  final TextEditingController _controllerQuantitySpaces =
      TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerSurname = TextEditingController();
  final TextEditingController _controllerCbu = TextEditingController();

  double latitud = 0;
  double lngitud = 0;

  bool showSourceField = false;
  String? emailUsuario = FirebaseAuth.instance.currentUser?.email;

  String? errorMessage = '';

  Uint8List? imagen;
  XFile? fileImagen;

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

  Future<void> convertAdressToLatLng(String garageAdress) async {
    try {
      List<geo.Location> locations =
          await geo.locationFromAddress(_controllerGarageAdress.text);
      latitud = locations[0].latitude;
      lngitud = locations[0].longitude;
      print("Latitud" + "$latitud" + " Longitud " + "$lngitud");
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: botonfunc, textStyle: GoogleFonts.rubik()),
      onPressed: () async {
        print("se recibio la direccion" + _controllerGarageAdress.text);
        await convertAdressToLatLng(_controllerGarageAdress.text);
        String email = emailUsuario ?? "";
        if (isNotBlank(_controllerName.text) &&
            isNotBlank(_controllerSurname.text) &&
            isNotBlank(_controllerGarageName.text) &&
            isNotBlank(_controllerGarageAdress.text) &&
            isNotBlank(_description.text) &&
            isNotBlank(_controllerPrice.text) &&
            isNotBlank(_controllerQuantitySpaces.text) &&
            isNotBlank(_controllerCbu.text)) {
          if (_controllerCbu.text.length == 22) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Center(child: CircularProgressIndicator());
              },
            );
            UsuarioCochera usuarioCochera = UsuarioCochera(
                nombre: _controllerName.text,
                apellido: _controllerSurname.text,
                email: email,
                nombreCochera: _controllerGarageName.text,
                direccion: _controllerGarageAdress.text,
                descripcion: _description.text,
                price: double.parse(_controllerPrice.text),
                cantLugares: int.parse(_controllerQuantitySpaces.text),
                lat: latitud,
                lng: lngitud,
                cbu: _controllerCbu.text,
                imageUrl: "");
            String urlImagen = "";
            if (fileImagen != null) {
              String uniqueName =
                  DateTime.now().millisecondsSinceEpoch.toString();

              Reference referenceRoot = FirebaseStorage.instance.ref();
              Reference referenceDirImages = referenceRoot.child('images');
              Reference imagenASubir = referenceDirImages.child(uniqueName);
              try {
                await imagenASubir.putFile(File(fileImagen!.path));
                await imagenASubir
                    .getDownloadURL()
                    .then((value) => urlImagen = value);
              } catch (error) {
                print(error);
                urlImagen = "";
              }
            }
            usuarioCochera.imageUrl = urlImagen;
            _databaseService.addUsuarioCochera(usuarioCochera);
            await Future.delayed(const Duration(seconds: 3));
            Navigator.pop(context);
            context.pushNamed(UsuarioCocheraHome.name);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('El CBU debe tener 22 números'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Por favor, complete todos los campos correctamente.'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Text('Confirmar'),
    );
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration:
          InputDecoration(labelText: title, labelStyle: GoogleFonts.rubik()),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
      ],
    );
  }

  Widget _entryFieldNumber(String title, TextEditingController controller) {
    return TextField(
        controller: controller,
        decoration:
            InputDecoration(labelText: title, labelStyle: GoogleFonts.rubik()),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ]);
  }

  Widget _title() {
    return Text('Registro de Cochera',
        style: GoogleFonts.rubik(
            textStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        )));
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
        backgroundColor: magnolia,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: magnolia),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              Text(
                'wePark',
                style: GoogleFonts.rowdies(
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    color: logoTitulos),
              ),
              const SizedBox(height: 20), 
              Text('Registro de cochera',
                  style: GoogleFonts.rubik(textStyle: secondaryTextStyle)),
              const SizedBox(height: 20),
              _entryField(
                'Nombre',
                _controllerName,
              ),
              const SizedBox(height: 20),
              _entryField('Apellido', _controllerSurname),
              const SizedBox(height: 20),
              _entryField('Nombre cochera', _controllerGarageName),
              const SizedBox(height: 20),
              _entryField('Descripcion', _description),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: TextFormField(
                  style: GoogleFonts.rubik(),
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
              const SizedBox(height: 20),
              _entryFieldNumber('CBU', _controllerCbu),
              const SizedBox(height: 20),
              imagePicker(),
              const SizedBox(height: 20),
              _errorMessage(),
              const SizedBox(height: 20),
              _errorMessage(),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget imagePicker() {
    return Column(
      children: [
        imagen != null
            ? CircleAvatar(
                radius: 64,
                backgroundImage: MemoryImage(imagen!),
              )
            : const CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/9131/9131529.png'),
              ),
        const SizedBox(height: 10), // Espacio entre la imagen y los botones
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: botonfunc, textStyle: GoogleFonts.rubik()),
              onPressed: () => selectImage(),
              child: const Text('Elegir imagen'),
            ),
            const SizedBox(width: 10), // Espacio entre los botones
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: botonfunc, textStyle: GoogleFonts.rubik()),
              onPressed: () => takeImage(),
              child: const Text('Tomar imagen'),
            ),
          ],
        ),
      ],
    );
  }

  takeImage() async {
    XFile? img = await pickImage(ImageSource.camera);
    if (img != null) {
      img.readAsBytes().then((foto) => {
            setState(() {
              imagen = foto;
              fileImagen = img;
            })
          });
    }
  }

  selectImage() async {
    XFile? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      img.readAsBytes().then((foto) => {
            setState(() {
              imagen = foto;
              fileImagen = img;
            })
          });
    }
  }
}
