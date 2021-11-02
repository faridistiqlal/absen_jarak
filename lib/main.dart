//ANCHOR package navigator
import 'package:absen/halaman/cek.dart';
import 'package:absen/halaman/camera_page.dart';
import 'package:absen/halaman/hal_absen.dart';
import 'package:absen/halaman/hal_laporan.dart';
import 'package:absen/halaman/hal_login.dart';
import 'package:absen/halaman/hal_map.dart';
import 'package:absen/halaman/hal_map2.dart';
import 'package:absen/splash/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light),
  );
//ANCHOR routes halaman
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Splash Screen',
      routes: <String, WidgetBuilder>{
        '/MapSample': (BuildContext context) => new MapSample(),
        '/MapSample2': (BuildContext context) => new MapSample2(),
        '/HalAbsen': (BuildContext context) => new HalAbsen(),
        '/DaftarAdmin': (BuildContext context) => new DaftarAdmin(),
        '/MyApp': (BuildContext context) => new MyApp(),
        '/CameraPage': (BuildContext context) => new CameraPage(),
        '/HalLaporan': (BuildContext context) => new HalLaporan(),
      },
      home: SplashScreenPage(),
    ),
  );
}
