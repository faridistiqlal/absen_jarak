// ignore: unused_import
import 'dart:async';
import 'package:absen/halaman/hal_login.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

class HalAbsen extends StatefulWidget {
  @override
  _HalAbsenState createState() => _HalAbsenState();
}

class _HalAbsenState extends State<HalAbsen> {
  String nip = "";
  // ignore: non_constant_identifier_names
  String lat_pusat = "";
  // ignore: non_constant_identifier_names
  String lot_pusat = " ";
  String idphone = "";
  String deviceid = "";
  String skpd = "";
  String noper = "";
  String _timeString;

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
    alertAlignment: Alignment.center,
  );

  void initState() {
    super.initState();
    _cekLogin();
    _cekUser();
    initializeDateFormatting();
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  // ignore: unused_field
  bool _sudahlogin = false;
  Future _cekLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("_sudahlogin") == false) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => new DaftarAdmin()));
    }
  }

  Future _cekUser() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('device', androidDeviceInfo.androidId);
    if (pref.getString("nip") != null) {
      setState(
        () {
          nip = pref.getString("nip");
          lat_pusat = pref.getString("lat_pusat");
          lot_pusat = pref.getString("lot_pusat");
          idphone = pref.getString("idphone");
          deviceid = pref.getString("device");
          skpd = pref.getString("skpd");
          noper = pref.getString("noper");
        },
      );
      print("device " + deviceid);
      print("session " + idphone);
    }
  }

  Future _cekLogout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("_sudahlogin") == null) {
      _sudahlogin = false;
      Navigator.pushReplacementNamed(context, '/DaftarAdmin');
    } else {
      _sudahlogin = true;
    }
  }

  void _getTime() {
    initializeDateFormatting('id_ID', null);
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (this.mounted) {
      setState(
        () {
          _timeString = formattedDateTime;
        },
      );
    }
  }

  Future _cekID() async {
    if (idphone == deviceid) {
      print("sama");
      Navigator.pushNamed(context, '/MapSample');
    } else {
      print("beda");
      Alert(
        context: this.context,
        title: "ID tidak sama",
        desc: "Device id berbeda",
        type: AlertType.warning,
        style: alertStyle,
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(this.context),
            color: Colors.orange,
            radius: BorderRadius.circular(15.0),
          ),
        ],
      ).show();
    }
    print(_cekID);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat(
      'EEEEE dd MMMM yyyy HH:mm:ss',
      'id_ID',
    ).format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Color primaryColor = Colors.blue[400];
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "SABAR ",
          style: TextStyle(
              color: Colors.white, fontSize: 23.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[400],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipPath(
                  clipper: CustomShapeClipper(),
                  child: Container(
                    height: mediaQueryData.size.height * 0.3,
                    decoration: BoxDecoration(color: primaryColor),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: mediaQueryData.size.height * 0.03,
                      vertical: mediaQueryData.size.height * 0.025),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "NIP " + nip,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 27.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: mediaQueryData.size.height * 0.02),
                          Text(
                            _timeString,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: mediaQueryData.size.height * 0.15,
                    right: mediaQueryData.size.height * 0.02,
                    left: mediaQueryData.size.height * 0.02,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0.0, 3.0),
                            blurRadius: 15.0),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: mediaQueryData.size.height * 0.05,
                            vertical: mediaQueryData.size.height * 0.03,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Material(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color: Colors.blue,
                                    child: IconButton(
                                      padding: EdgeInsets.all(
                                          mediaQueryData.size.height * 0.02),
                                      icon: Icon(Icons.check),
                                      color: Colors.white,
                                      iconSize: 30.0,
                                      onPressed: () {
                                        _cekID();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          mediaQueryData.size.height * 0.01),
                                  Text(
                                    'Masuk',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0),
                                  )
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Material(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color: Colors.green,
                                    child: IconButton(
                                      padding: EdgeInsets.all(15.0),
                                      icon: Icon(Icons.assignment),
                                      color: Colors.white,
                                      iconSize: 30.0,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/HalLaporan');
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          mediaQueryData.size.height * 0.01),
                                  Text('Laporan',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Material(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color: Colors.red,
                                    child: IconButton(
                                      padding: EdgeInsets.all(
                                          mediaQueryData.size.height * 0.02),
                                      icon: Icon(Icons.exit_to_app),
                                      color: Colors.white,
                                      iconSize: 30.0,
                                      onPressed: () async {
                                        SharedPreferences pref =
                                            await SharedPreferences
                                                .getInstance();
                                        pref.clear();
                                        DeviceInfoPlugin deviceInfo =
                                            DeviceInfoPlugin();
                                        AndroidDeviceInfo androidDeviceInfo =
                                            await deviceInfo.androidInfo;
                                        pref.setString("IdHp",
                                            androidDeviceInfo.androidId);
                                        _cekLogout();
                                        // Alert(
                                        //   style: alertStyle,
                                        //   context: context,
                                        //   title:
                                        //       "Apakah anda yakin ingin keluar?",
                                        //   buttons: [
                                        //     DialogButton(
                                        //       child: Text(
                                        //         "Tidak",
                                        //         style: TextStyle(
                                        //             color: Colors.white,
                                        //             fontSize: 20),
                                        //       ),
                                        //       onPressed: () =>
                                        //           Navigator.pop(context),
                                        //       color: Colors.green,
                                        //     ),
                                        //     DialogButton(
                                        //       child: Text(
                                        //         "Ya",
                                        //         style: TextStyle(
                                        //             color: Colors.white,
                                        //             fontSize: 20),
                                        //       ),
                                        //       onPressed: () async {
                                        //         SharedPreferences pref =
                                        //             await SharedPreferences
                                        //                 .getInstance();
                                        //         pref.clear();
                                        //         DeviceInfoPlugin deviceInfo =
                                        //             DeviceInfoPlugin();
                                        //         AndroidDeviceInfo
                                        //             androidDeviceInfo =
                                        //             await deviceInfo
                                        //                 .androidInfo;
                                        //         pref.setString(
                                        //             "IdHp",
                                        //             androidDeviceInfo
                                        //                 .androidId);
                                        //         _cekLogout();
                                        //       },
                                        //       color: Colors.red,
                                        //     )
                                        //   ],
                                        // ).show();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          mediaQueryData.size.height * 0.01),
                                  Text(
                                    'Log Out',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mediaQueryData.size.height * 0.03,
                vertical: mediaQueryData.size.height * 0.02,
              ),
              child: Text(
                'Ketentuan Absen Online',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ),
            ),
            lokasi(),
            internet(),
            gps(),
            sabar(),
          ],
        ),
      ),
    );
  }

  Widget lokasi() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: mediaQueryData.size.height * 0.03,
        vertical: mediaQueryData.size.height * 0.01,
      ),
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          size: 30,
          color: Colors.red,
        ),
        subtitle: new Text(
          "Absen harus berada di radius 30 m dari titik pusat yang di sepakati",
          style: new TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
        ),
        title: new Text(
          "Radius",
          style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget internet() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Padding(
      //color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: mediaQueryData.size.height * 0.03,
        vertical: mediaQueryData.size.height * 0.01,
      ),
      child: ListTile(
        leading: Icon(
          Icons.signal_cellular_4_bar,
          size: 30,
          color: Colors.green,
        ),
        subtitle: new Text(
          "Pastikan data internet/Wifi anda aktif ketika melakukan absen",
          style: new TextStyle(fontSize: 12.0, color: Colors.grey),
        ),
        title: new Text(
          "Internet",
          style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget gps() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: mediaQueryData.size.height * 0.03,
        vertical: mediaQueryData.size.height * 0.01,
      ),
      child: ListTile(
        leading: Icon(
          Icons.gps_fixed,
          size: 30,
          color: Colors.blue,
        ),
        subtitle: new Text(
          "Pastikan GPS anda di aktifkan ketika melakukan absen",
          style: new TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
        ),
        title: new Text(
          "Gps",
          style: new TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget sabar() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: mediaQueryData.size.height * 0.03,
        vertical: mediaQueryData.size.height * 0.01,
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            //Navigator.pushNamed(context, '/MyApp');
          },
          child: Icon(
            Icons.transfer_within_a_station,
            size: 30,
            color: Colors.orange,
          ),
        ),
        subtitle: new Text(
          "Saat absen mohon sabar untuk menunggu titik gps ke titik pusat, hal ini juga di pengaruhi internet anda",
          style: new TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
        ),
        title: new Text(
          "Sabar",
          style: new TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, 390.0 - 200);
    path.quadraticBezierTo(size.width / 2, 280, size.width, 390.0 - 200);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
