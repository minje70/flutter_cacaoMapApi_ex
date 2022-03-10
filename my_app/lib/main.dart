import 'package:flutter/material.dart';
import 'package:location/location.dart';

class test extends StatefulWidget {
  test({Key? key}) : super(key: key);

  @override
  State<test> createState() => _testState();
}

class _testState extends State<test> {
  Location location = new Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  void _tmp() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }

  @override
  void initState() {
    super.initState();

    _tmp();
  }

  @override
  Widget build(BuildContext context) {
    void _getNewLocation() async {
      _locationData = await location.getLocation();
    }

    void _buttonAction() {
      if (_locationData != null &&
          _locationData!.longitude != null &&
          _locationData!.latitude != null) {
        final snackBar = SnackBar(
          dismissDirection: DismissDirection.up,
          duration: Duration(milliseconds: 1000),
          content: Text(
              'lat: ${_locationData!.latitude} lon: ${_locationData!.longitude}'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('새 위치 받기'),
          onPressed: _getNewLocation,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _buttonAction,
        child: Icon(Icons.gps_fixed),
      ),
    );
  }
}

void main() async {
  runApp(
    MaterialApp(
      home: test(),
    ),
  );
}
