import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:image/image.dart' as img;

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Set<Marker> _markers = {};
  // ignore: unused_field
  String _timeString;
  Position _position;
  Position _position2;
  StreamSubscription<Position> _streamSubscription;
  StreamSubscription<Position> _streamSubscription2;
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
  bool _loading = false;
  File imageFile;
  CameraController controller;

  Future<void> initializeCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.low);
    await controller.initialize();
  }

  Future<File> takePicture() async {
    DateFormat dateFormat = DateFormat("yyyy_MM_dd_HH_mm_ss");
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/Guided.Camera';
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${dateFormat.format(DateTime.now())}.jpg';

    try {
      await controller.takePicture(filePath);
    } catch (e) {
      return null;
    }
    return File(filePath);
  }

  Future upload(File imageFile) async {
    final img.Image capturedImage =
        img.decodeImage(await File(imageFile.path).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage);
    await File(imageFile.path).writeAsBytes(img.encodeJpg(orientedImage));
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
      print(length);
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
    constraints: BoxConstraints.expand(
      width: 300,
    ),
    overlayColor: Color(0x55000000),
    alertElevation: 0,
    alertAlignment: Alignment.center,
  );

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
  void dispose() {
    _streamSubscription.cancel();
    _streamSubscription2.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    marker();
    _currentLocation2();
    // ignore: unused_local_variable
    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _streamSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        if (this.mounted) {
          print("lokasi kantor");
          setState(
            () {
              print(position);
              _position = position;
              final coordinates = new Coordinates(
                position.latitude,
                position.longitude,
              );
              convertCoordinatesToAddress(coordinates).then(
                (value) => _address = value,
              );
            },
          );
        }
      },
    );

    // ignore: unused_local_variable
    var locationOptions2 =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _streamSubscription2 = Geolocator.getPositionStream().listen(
      (Position position2) {
        if (this.mounted) {
          print("lokasi absen");
          setState(
            () {
              print(position2);
              _position2 = position2;
              final coordinates = new Coordinates(
                double.parse(lat_pusat),
                double.parse(lot_pusat),
              );
              convertCoordinatesToAddress(coordinates).then(
                (value) => _address2 = value,
              );
            },
          );
        }
      },
    );
    _cekUser();
    _kondisiAbsen();
    super.initState();
  }

  Future<Address> convertCoordinatesToAddress(Coordinates coordinates) async {
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return addresses.first;
  }

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
        },
      );
      print("reguler");
    }
  }

  void absenNew() async {
    setState(
      () {
        initializeCamera();
        _loading = true;
      },
    );
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
        },
      );
    }

    if (distanceInMeters <= 30) {
      print(distanceInMeters);
      print("masuk");
      Future.delayed(
        Duration(seconds: 1),
        () async {
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
          if (!controller.value.isTakingPicture) {
            File result = await takePicture();
            setState(
              () {
                imageFile = result;
              },
            );
          }
          upload(imageFile);
          setState(
            () {
              _loading = false;
            },
          );
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                onPressed: () => Navigator.pop(this.context),
                color: Colors.green,
                radius: BorderRadius.circular(15.0),
              ),
            ],
          ).show();
        },
      );
    } else {
      print(distanceInMeters);
      print("keluar");
      setState(
        () {
          _loading = false;
        },
      );
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
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
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        centerTitle: true,
        title: Text('Absen Online'),
        backgroundColor: Colors.blue[400],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        color: Colors.blue[400],
        opacity: 0.5,
        progressIndicator:
            CircularProgressIndicator(backgroundColor: Colors.red),
        child: Stack(
          children: <Widget>[
            _googleMap(),
            _tombolAbsen(),
            Column(
              children: <Widget>[
                _lokasiAbsen(),
                _lokasiAnda(),
              ],
            ),
          ],
        ),
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

  void _currentLocation2() async {
    final GoogleMapController controller = await _controller.future;
    if (this.mounted) {
      setState(
        () {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                bearing: 0,
                target: LatLng(
                  double.parse(lat_pusat),
                  double.parse(lot_pusat),
                ),
                zoom: 25.0,
              ),
            ),
          );
        },
      );
    }
  }

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-6.92319288, 110.2039357),
    zoom: 14.4746,
  );

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
              borderRadius: BorderRadius.circular(10.0),
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
            },
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
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
    MediaQueryData mediaQueryData = MediaQuery.of(this.context);
    return Padding(
      padding: EdgeInsets.only(top: 10.0, right: 15.0, left: 15.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: double.infinity,
        height: mediaQueryData.size.height * 0.17,
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
              "${_address2?.addressLine ?? 'memuat'} ${_address2?.featureName ?? 'alamat...'}",
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
    MediaQueryData mediaQueryData = MediaQuery.of(this.context);
    return Padding(
      padding: EdgeInsets.only(top: 10.0, right: 15.0, left: 15.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: double.infinity,
        height: mediaQueryData.size.height * 0.17,
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
              "${_address?.addressLine ?? 'memuat'} ${_address?.featureName ?? 'alamat...'}",
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
}
