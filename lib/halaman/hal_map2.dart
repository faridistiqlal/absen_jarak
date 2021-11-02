import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:absen/halaman/camera_page2.dart';
import 'package:absen/style/size_config.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

class MapSample2 extends StatefulWidget {
  @override
  State<MapSample2> createState() => MapSample2State();
}

class MapSample2State extends State<MapSample2> {
  final Set<Marker> _markers = {};
  // ignore: unused_field
  final LatLng _currentPosition = LatLng(-6.92319288, 110.2039357);
  // ignore: unused_field
  String _timeString;
  Position _position;
  Position _position2;
  StreamSubscription<Position> _streamSubscription;
  Address _address;
  Address _address2;
  // ignore: non_constant_identifier_names
  String lat_pusat = "";
  // ignore: non_constant_identifier_names
  String lot_pusat = " ";
  String jarak = "";
  double jarak2;
  String nip = "";
  String jmlKondisi = "";
  int jmlKondisi2 = 0;
  File imageFile;

  Future upload(File imageFile) async {
    var stream =
        // ignore: deprecated_member_use
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse("http://118.97.18.62/webservice/upload_image.php");

    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = new http.MultipartFile("file", stream, length,
        filename: basename(imageFile.path));

    request.files.add(multipartFile);
    var response = await request.send();

    if (response.statusCode == 200) {
      print("Image Uploaded");
      print(imageFile);
    } else {
      print("Upload Failed");
    }
    response.stream.transform(utf8.decoder).listen(
      (value) {
        print(value);
      },
    );
  }

  var alertStyle = AlertStyle(
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
      ),
      animationDuration: Duration(milliseconds: 100),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.black,
      ),
      constraints: BoxConstraints.expand(width: 300),
      overlayColor: Color(0x55000000),
      alertElevation: 0,
      alertAlignment: Alignment.center);

  Future _cekUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(
      () {
        lat_pusat = pref.getString("lat_pusat");
        lot_pusat = pref.getString("lot_pusat");
        nip = pref.getString("nip");
      },
    );
  }

  void marker() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(
      () {
        lat_pusat = pref.getString("lat_pusat");
        lot_pusat = pref.getString("lot_pusat");
        nip = pref.getString("nip");
      },
    );
    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: LatLng(double.parse(lat_pusat), double.parse(lot_pusat)),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  }

  @override
  void initState() {
    marker();

    // ignore: unused_local_variable
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _streamSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        if (this.mounted) {
          setState(
            () {
              print(position);
              _position = position;

              final coordinates =
                  new Coordinates(position.latitude, position.longitude);
              convertCoordinatesToAddress(coordinates)
                  .then((value) => _address = value);
            },
          );
        }
      },
    );

    // ignore: unused_local_variable
    var locationOptions2 =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _streamSubscription = Geolocator.getPositionStream().listen(
      (Position position2) {
        if (this.mounted) {
          setState(
            () {
              print(position2);
              _position2 = position2;
              final coordinates = new Coordinates(
                  double.parse(lat_pusat), double.parse(lot_pusat));
              convertCoordinatesToAddress(coordinates)
                  .then((value) => _address2 = value);
            },
          );
        }
      },
    );

    _cekUser();
    _kondisiAbsen();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  Future<Address> convertCoordinatesToAddress(Coordinates coordinates) async {
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return addresses.first;
  }

  Set<Circle> circles = Set.from(
    [
      Circle(
        circleId: CircleId('1'),
        center: LatLng(-6.92319288, 110.2039357),
        radius: 10,
        strokeWidth: 1,
        strokeColor: Colors.orange,
      )
    ],
  );

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-6.92319288, 110.2039357),
    zoom: 14.4746,
  );

  Future _kondisiAbsen() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final response = await http.post(
      "http://118.97.18.62/webservice/php_example.php",
      body: {
        "action": 'kondisi_absen',
        "nipe": pref.getString("nip"),
        "idphone": pref.getString("IdHp"),
      },
    );
    var kondisi = json.decode(response.body);
    print(kondisi);
    if (kondisi[0]['kondisi'] == 1) {
      setState(
        () {
          jmlKondisi = "ABSEN EVENT";
          jmlKondisi2 = kondisi;
        },
      );
      print("event");
    } else {
      setState(
        () {
          jmlKondisi = "ABSEN";
          // jmlKondisi2 = kondisi;
        },
      );
      print("reguler");
    }
  }

  void absenNew() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    final geoposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double distanceInMeters = Geolocator.distanceBetween(
      double.parse(lat_pusat),
      double.parse(lot_pusat),
      double.parse('${geoposition.latitude}'),
      double.parse('${geoposition.longitude}'),
    );
    if (this.mounted) {
      setState(
        () {
          jarak = distanceInMeters.toStringAsFixed(1);
          //jarak2 = distanceInMeters;
        },
      );
    }

    if (distanceInMeters <= 30) {
      print(distanceInMeters);
      print("masuk");
      final response = await http.post(
        "http://118.97.18.62/webservice/php_example.php",
        body: {
          "action": 'insert_new_absen',
          "nipe": pref.getString("nip"),
          "idphone": pref.getString("IdHp"),
          "lat": "${_position.latitude}",
          "lot": "${_position.longitude}",
          "status": jmlKondisi.toString(),
          "nostaff": '',
        },
      );
      var absennew = json.decode(response.body);
      print(absennew);
      Alert(
        context: this.context,
        title: "Absen berhasil",
        desc: "Jarak " + jarak + " m",
        type: AlertType.success,
        style: alertStyle,
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(this.context),
            color: Colors.green,
            radius: BorderRadius.circular(15.0),
          ),
        ],
      ).show();
      //absenNew();
    } else {
      print(distanceInMeters);
      print("keluar");
      Alert(
        context: this.context,
        title: "Absen Gagal",
        desc: "Jarak " + jarak + " m , terlalu jauh",
        type: AlertType.error,
        style: alertStyle,
        buttons: [
          DialogButton(
            child: Text(
              "ULANGI",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(this.context),
            color: Colors.red,
            radius: BorderRadius.circular(15.0),
          ),
        ],
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID', null);
    return new Scaffold(
      //key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Absen Online 2'),
        backgroundColor: Colors.blue[400],
      ),
      body: Stack(
        children: <Widget>[
          _googleMap(),
          _tombolAbsen(),
          _fotoAnda(),
          Column(
            children: <Widget>[
              //_waktuAbsen(),
              _lokasiAbsen(),
              //_jarakAbsen(),
              _lokasiAnda(),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _currentLocation,
        child: new Icon(Icons.gps_fixed),
      ),
    );
  }

  void _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    loc.LocationData currentLocation;
    var location = new loc.Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 25.0,
        ),
      ),
    );
  }

  Widget _googleMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: _markers,
      //circles: circles,
    );
  }

  Widget _tombolAbsen() {
    if (jmlKondisi2 == 1) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: 18.0,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RaisedButton(
            elevation: 5.0,
            onPressed: () {
              Navigator.pushNamed(this.context, '/HalAbsen');
            },
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            color: Colors.green,
            child: Text(
              'ABSEN EVENT',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(
          bottom: 18.0,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RaisedButton(
            elevation: 5.0,
            onPressed: () async {
              absenNew();
              upload(imageFile);
              //Navigator.pushNamed(context, '/HalAbsen');
            },
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            color: Colors.green,
            child: Text(
              'ABSEN',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _lokasiAbsen() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, right: 15.0, left: 15.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: double.infinity,
        height: SizeConfig.safeBlockVertical * 15,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0.0, 3.0),
                blurRadius: 15.0)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Lokasi Kantor',
              style: TextStyle(
                  color: Colors.blue.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
            Text(
              "Location lat: ${_position2?.latitude ?? '-'} log:${_position2?.longitude ?? '-'} ",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13.0,
              ),
            ),
            Text(
              "${_address2?.addressLine ?? '-'} ${_address2?.featureName ?? '-'}",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lokasiAnda() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, right: 15.0, left: 15.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: double.infinity,
        height: SizeConfig.safeBlockVertical * 15,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0.0, 3.0),
                blurRadius: 15.0)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Lokasi Anda',
              style: TextStyle(
                  color: Colors.green.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
            Text(
              "Location lat: ${_position?.latitude ?? '-'} log:${_position?.longitude ?? '-'} ",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13.0,
              ),
            ),
            Text(
              "${_address?.addressLine ?? '-'} ${_address?.featureName ?? '-'}",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fotoAnda() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.all(2.0),
        child: Container(
          padding: EdgeInsets.all(10.0),
          width: SizeConfig.safeBlockVertical * 15,
          height: SizeConfig.safeBlockVertical * 10,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0.0, 3.0),
                  blurRadius: 15.0)
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(2.0),
                width: 35,
                height: 75,
                color: Colors.grey,
                child: (imageFile != null)
                    ? Image.file(imageFile)
                    : SizedBox(
                        height: 10,
                        width: 10,
                      ),
              ),
              Container(
                height: 58,
                width: 59,
                child: RaisedButton(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    imageFile = await Navigator.push<File>(this.context,
                        MaterialPageRoute(builder: (_) => CameraPage2()));
                    setState(() {});
                  },
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
