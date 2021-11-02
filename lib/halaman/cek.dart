// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:geocoder/geocoder.dart';
// import 'package:geolocator/geolocator.dart';

// class GetLocationPage extends StatefulWidget {
//   @override
//   _GetLocationPageState createState() => _GetLocationPageState();
// }

// class _GetLocationPageState extends State<GetLocationPage> {
//   String latitudeData = "";
//   String longitudeData = "";
//   String alamat1 = "";
//   String alamat2 = "";
//   String jarak = "";

//   Position _position;
//   StreamSubscription<Position> _streamSubscription;
//   Address _address;

//   @override
//   void initState() {
//     super.initState();
//     getCurrentLocation();
//     getAddressBasedOnLocation();
//     getDistance();
//     // ignore: unused_local_variable
//     var locationOptions =
//         LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
//     _streamSubscription = Geolocator.getPositionStream().listen(
//       (Position position) {
//         setState(
//           () {
//             print(position);
//             _position = position;

//             final coordinates =
//                 new Coordinates(position.latitude, position.longitude);
//             convertCoordinatesToAddress(coordinates)
//                 .then((value) => _address = value);
//           },
//         );
//       },
//     );
//   }

//   getCurrentLocation() async {
//     final geoposition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(
//       () {
//         latitudeData = '${geoposition.latitude}';
//         longitudeData = '${geoposition.longitude}';
//       },
//     );
//   }

//   getDistance() async {
//     final geoposition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(
//       () {
//         latitudeData = '${geoposition.latitude}';
//         longitudeData = '${geoposition.longitude}';
//       },
//     );

//     double distanceInMeters = Geolocator.distanceBetween(
//       -6.92319288,
//       110.2039357,
//       double.parse('${geoposition.latitude}'),
//       double.parse('${geoposition.longitude}'),
//     );
//     setState(
//       () {
//         jarak = distanceInMeters.toStringAsFixed(2);
//       },
//     );
//     print(distanceInMeters);
//   }

//   getAddressBasedOnLocation() async {
//     final coordinat = new Coordinates(-6.92319288, 110.2039357);
//     var addresses =
//         await Geocoder.local.findAddressesFromCoordinates(coordinat);

//     alamat1 = addresses.first.featureName;
//     alamat1 = addresses.first.addressLine;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _streamSubscription.cancel();
//   }

//   Future<Address> convertCoordinatesToAddress(Coordinates coordinates) async {
//     var addresses =
//         await Geocoder.local.findAddressesFromCoordinates(coordinates);
//     return addresses.first;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Column(
//         children: [
//           Text(latitudeData),
//           Text(longitudeData),
//           Text(alamat1),
//           Text(alamat2),
//           Text(
//               "Location lat: ${_position?.latitude ?? '-'} long:${_position?.longitude ?? '-'} "),
//           Text("Address from coordinate :"),
//           Text(
//               "${_address?.addressLine ?? '-'} ${_address?.featureName ?? '-'}"),
//           Text(jarak + " m"),
//         ],
//       ),
//     );
//   }
// }

// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
              Platform.isAndroid ? 'Android Device Info' : 'iOS Device Info'),
        ),
        body: ListView(
          children: _deviceData.keys.map((String property) {
            return Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    property,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                  child: Text(
                    '${_deviceData[property]}',
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
