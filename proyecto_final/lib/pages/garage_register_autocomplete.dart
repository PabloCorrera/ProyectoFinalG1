import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:proyecto_final/services/network_utility.dart';
import 'package:proyecto_final/models/place_auto_comlate_response.dart';
import 'package:proyecto_final/models/place_auto_comlate_response.dart';
import 'package:proyecto_final/models/autocomplete_prediction.dart';
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

  Future<String> showGoogleAutoComplete() async {
    try {
      const kGoogleApiKey = apiKey;
      String calle = "no encontrada";
      Prediction? p = await PlacesAutocomplete.show(
          offset: 0,
          radius: 1000,
          strictbounds: false,
          region: "ar",
          context: context,
          apiKey: kGoogleApiKey,
          mode: Mode.overlay, // Mode.fullscreen
          language: "es",
          types: ["(address)"],
          hint: "Search place",
          components: [new Component(Component.country, 'ar')]);

      return calle = p!.description!;
    } catch (e) {
      String calle = "no encontrada";
      print("Error al obtener predicciones de lugares: $e");
      return calle; // Devolver null en caso de error
    }
  }

  TextEditingController _controllerGarageAdress = TextEditingController();
  bool showSourceField = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: defaultPadding),
          child: CircleAvatar(
            backgroundColor: secondaryColor10LightTheme,
            child: SvgPicture.asset(
              "assets/icons/location.svg",
              height: 16,
              width: 16,
              color: secondaryColor40LightTheme,
            ),
          ),
        ),
        title: const Text(
          "Buscar direccion",
          style: TextStyle(color: textColorLightTheme),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: secondaryColor10LightTheme,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close, color: Colors.black),
            ),
          ),
          const SizedBox(width: defaultPadding)
        ],
      ),
      body: Column(
        children: [
          Form(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: TextFormField(
                controller: _controllerGarageAdress,
                onTap: () async {
                  String selectedPlace = await showGoogleAutoComplete();
                  _controllerGarageAdress.text = selectedPlace;

                  setState(() {
                    showSourceField = true;
                  });
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search your location",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SvgPicture.asset(
                      "assets/icons/location_pin.svg",
                      color: secondaryColor40LightTheme,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            height: 4,
            thickness: 4,
            color: secondaryColor5LightTheme,
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: SvgPicture.asset(
                "assets/icons/location.svg",
                height: 16,
              ),
              label: const Text("Usar mi ubicacion Actual"),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor10LightTheme,
                foregroundColor: textColorLightTheme,
                elevation: 0,
                fixedSize: const Size(double.infinity, 40),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          const Divider(
            height: 4,
            thickness: 4,
            color: secondaryColor5LightTheme,
          ),
          Expanded(
              child: ListView.builder(
            itemCount: placePredictions.length,
            itemBuilder: (context, index) => LocationListTile(
              press: () {},
              location: placePredictions[index].description!,
            ),
          ))
        ],
      ),
    );
  }
}

