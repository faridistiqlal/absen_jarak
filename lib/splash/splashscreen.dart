import 'dart:async';
import 'package:absen/halaman/hal_login.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  String deviceId = "";
  // ignore: missing_return
  @override
  void initState() {
    super.initState();
    idHp();
    startSplashScreen();
  }

  void idHp() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('IdHp', androidDeviceInfo.androidId);
    print("ID : " + pref.getString("IdHp"));
  }

  startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    return Timer(
      duration,
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) {
              return DaftarAdmin();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Color(0xFFffffff),
      body: Container(
        child: new Center(
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.only(
                  top: mediaQueryData.size.height * 0.3,
                ),
                child: Image.asset(
                  "assets/images/desa1.png",
                  width: mediaQueryData.size.height * 0.15,
                  height: mediaQueryData.size.height * 0.15,
                ),
              ),
              Padding(
                padding: new EdgeInsets.only(
                  top: mediaQueryData.size.height * 0.02,
                ),
                child: Text(
                  "Absen Online",
                  style: new TextStyle(
                    fontSize: 25.0,
                    color: Colors.grey,
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
