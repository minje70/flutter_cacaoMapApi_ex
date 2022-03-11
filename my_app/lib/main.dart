import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart';
import 'dart:convert';

class RestourantData {
  const RestourantData(
      {required this.place_name,
      required this.place_url,
      required this.address_name,
      required this.category_group_code,
      required this.category_group_name,
      required this.id,
      required this.road_address_name,
      required this.x,
      required this.y});
  final String place_name;
  final String place_url;
  final String address_name;
  final String road_address_name;
  final String category_group_code;
  final String category_group_name;
  final String x;
  final String y;
  final String id;

  factory RestourantData.fromJson(dynamic data) {
    return RestourantData(
        place_name: data['place_name'],
        place_url: data['place_url'],
        address_name: data['address_name'],
        category_group_code: data['category_group_code'],
        category_group_name: data['category_group_name'],
        id: data['id'],
        road_address_name: data['road_address_name'],
        x: data['x'],
        y: data['y']);
  }
}

class CacaoMapData {
  const CacaoMapData({required this.list});
  final List<RestourantData> list;

  factory CacaoMapData.fromJson(Map<String, dynamic> data) {
    final list = data['documents'] as List<dynamic>;
    final result = list.map((e) {
      return RestourantData.fromJson(e);
    }).toList();
    return CacaoMapData(list: result);
  }
}

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

  void _setDeviceLocation() async {
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

    _setDeviceLocation();
  }

  @override
  Widget build(BuildContext context) {
    void _getCacaoMapData() async {
      _locationData = await location.getLocation();
      final uri = Uri.parse(
          'https://dapi.kakao.com/v2/local/search/keyword.json?y=${_locationData!.latitude}&x=${_locationData!.longitude}&radius=20000&category_group_code=FD6&query=맛집');
      final json = await get(
        uri,
        headers: {
          'Authorization': 'KakaoAK 1fa8220646b4c48f8c3ae4bbe3bf7234',
        },
      );
      final parsedJson = jsonDecode(json.body);
      final cacaoMapData = CacaoMapData.fromJson(parsedJson);
      print('place : ${cacaoMapData.list[0].address_name}');
      cacaoMapData.list.forEach((element) {
        print('title: ${element.place_name}');
      });
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
          child: Text('카카오 API 요청'),
          onPressed: _getCacaoMapData,
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
