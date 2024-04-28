import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:proyecto_final/entities/cochera.dart';
import 'package:proyecto_final/services/database_sevice.dart';
import 'package:proyecto_final/services/network_utility.dart';
import '../models/constant.dart';

class GarageRegister extends StatelessWidget {
  GarageRegister({Key? key}) : super(key: key);
  static const String name = 'GarageRegister';

  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _controllerOwnerId = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _controllerGarageName = TextEditingController();
  final TextEditingController _controllerGarageAdress = TextEditingController();
  final TextEditingController _controllerQuantitySpaces =
      TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();
  bool showSourceField = false;
/*
  void placeAutoComplete(String query) async {
    Uri uri = Uri.http(
        "maps.googleapis.com",
        'maps/api/place/autocomplete/json', // unencoder path
        {
          "input": query,
          "key": apiKey,
        });
    String? response = await NetworkUtility.fetchUrl(uri);

    if (response != null) {
      print(response);
    }
  }
*/
  

  String? errorMessage = '';

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () {
        Cochera cochera = Cochera(
          nombre: _controllerGarageName.text,
          ownerId: _controllerOwnerId.text,
          descripcion: _description.text,
          direccion: _controllerGarageAdress.text,
        );
        // price: _controllerPrice.value);
        _databaseService.addCochera(cochera);
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
              // const SizedBox(height: 20),
              // _entryField('Nombre', _controllerOwnerId),
              const SizedBox(height: 20),
              _entryField('Nombre Estacionamiento', _controllerGarageName),
              const SizedBox(height: 20),
              _entryField('Descripcion', _description),
              const SizedBox(height: 20),
              //_entryField('Direccion', _controllerGarageAdress, ),
              Form(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _controllerGarageAdress,
                    onTap: () {
                      //showGoogleAutoComplete(context);
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: "Busca tu direccion",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SvgPicture.asset(
                          "assets/icons/location_pin.svg",
                          color: Color(0xFF585858),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    //  placeAutoComplete("cordoba");
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/location.svg",
                    height: 16,
                  ),
                  label: const Text("Usar mi ubicacion actual"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEEEEEE),
                    foregroundColor: Color(0xFF0D0D0E),
                    elevation: 0,
                    fixedSize: const Size(double.infinity, 40),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
              /*    LocationListTile(
            press: () {},
            location: "Banasree, Dhaka, Bangladesh",
          ), */
              const SizedBox(height: 20),
              _entryFieldNumber('Precio por hora', _controllerPrice),
              //const SizedBox(height: 20),
              //_entryField('Tipo del vehiculo', _controllerGarageName),
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
