import 'package:absen/style/constants.dart';
import "package:flutter/material.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HalLaporan extends StatefulWidget {
  @override
  _HalLaporanState createState() => _HalLaporanState();
}

class _HalLaporanState extends State<HalLaporan> {
  String _mySelection;
  String _mySelection2;
  String bulan;
  String tahun;
  String nip;

  List<dynamic> databulan = List();
  List<dynamic> dataskpd = List();
  List<dynamic> datalist = List();

  Future<String> getBulan() async {
    var res = await http.get(
        Uri.encodeFull("http://118.97.18.62/webservice/ambil_tahun.php"),
        headers: {"Accept": "application/json"});

    Map<String, dynamic> resBody = json.decode(res.body);
    setState(
      () {
        databulan = resBody["data"];
        print(databulan[0]["bulan"]);
        print(databulan[0]["tahun"]);
      },
    );
    print(resBody);

    return "Sucess";
  }

  Future<String> getSkpd() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var res = await http.post(
      Uri.encodeFull(
          "http://118.97.18.62/webservice/laporan_absen_mahmudi.php"),
      headers: {"Accept": "application/json"},
      body: {
        "kirimnip": pref.getString("nip"),
        "kirimskpd": pref.getString("skpd"),
      },
    );

    Map<String, dynamic> resBody = json.decode(res.body);
    setState(
      () {
        dataskpd = resBody["data"];
        print(dataskpd[0]["nip"]);
      },
    );
    print(resBody);

    return "Sucess";
  }

  Future<List> getList() async {
    if (this.mounted) {
      setState(
        () {
          nip = _mySelection2;
          bulan = _mySelection.substring(0, 2);
          tahun = _mySelection.substring(_mySelection.length - 4);
        },
      );
    }

    var res = await http.post(
      Uri.encodeFull("http://118.97.18.62/webservice/ambil_absen_perbulan.php"),
      headers: {"Accept": "application/json"},
      body: {
        "nip": nip,
        "bulan": bulan,
        "tahun": tahun,
      },
    );
    Map<String, dynamic> jsonData = json.decode(res.body);
    if (this.mounted) {
      setState(
        () {
          datalist = json.decode(res.body)['data'];
        },
      );
    }
    print(jsonData);
    return datalist;
  }

  @override
  void initState() {
    super.initState();
    this.getBulan();
    this.getSkpd();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return new Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Laporan"),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: mediaQueryData.size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.blue[400],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: mediaQueryData.size.height * 0.02,
                    left: mediaQueryData.size.height * 0.02,
                    right: mediaQueryData.size.height * 0.02,
                  ),
                  child: Container(
                    padding: new EdgeInsets.only(
                      left: mediaQueryData.size.height * 0.02,
                      right: mediaQueryData.size.height * 0.03,
                    ),
                    alignment: Alignment.center,
                    decoration: kBoxDecorationStyle2,
                    height: mediaQueryData.size.height * 0.07,
                    child: DropdownButton(
                      underline: SizedBox(),
                      hint: Text('Pilih Bulan'),
                      isExpanded: true,
                      items: databulan.map(
                        (item) {
                          return new DropdownMenuItem(
                            child:
                                new Text(item['bulan'] + ' ' + item['tahun']),
                            value: item['bulan'] + item['tahun'].toString(),
                          );
                        },
                      ).toList(),
                      onChanged: (newVal) {
                        if (this.mounted) {
                          setState(
                            () {
                              print(newVal);
                              print(newVal.substring(0, 2));
                              print(newVal.substring(newVal.length - 4));
                              _mySelection = newVal;
                            },
                          );
                        }
                      },
                      value: _mySelection,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: mediaQueryData.size.height * 0.02,
                    left: mediaQueryData.size.height * 0.02,
                    right: mediaQueryData.size.height * 0.02,
                  ),
                  child: Container(
                    padding: new EdgeInsets.only(
                        left: mediaQueryData.size.height * 0.02,
                        right: mediaQueryData.size.height * 0.03),
                    alignment: Alignment.center,
                    decoration: kBoxDecorationStyle2,
                    height: mediaQueryData.size.height * 0.07,
                    child: DropdownButton(
                      underline: SizedBox(),
                      hint: Text('Pilih NIP'),
                      isExpanded: true,
                      items: dataskpd.map(
                        (item) {
                          return new DropdownMenuItem(
                            child: new Text(
                              item['nip'] + ' ' + item['nama'],
                            ),
                            value: item['nip'].toString(),
                          );
                        },
                      ).toList(),
                      onChanged: (newVal2) {
                        if (this.mounted) {
                          setState(
                            () {
                              print(newVal2);
                              _mySelection2 = newVal2;
                            },
                          );
                        }
                      },
                      value: _mySelection2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: mediaQueryData.size.height * 0.2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(mediaQueryData.size.height * 0.01),
                  child: new Container(
                    alignment: Alignment.centerLeft,
                    padding: new EdgeInsets.all(10.0),
                    child: Text(
                      "Laporan Absen Bulanan",
                      style: new TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
                _mySelection2 != null
                    ? Flexible(
                        child: FutureBuilder(
                          future: getList(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) print(snapshot.error);
                            return snapshot.hasData
                                ? new ItemList(
                                    list: snapshot.data,
                                  )
                                : new Center(
                                    child: CircularProgressIndicator(),
                                  );
                          },
                        ),
                      )
                    : Container(
                        padding: new EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.2),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              new Icon(
                                Icons.calendar_today,
                                size: 150,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ItemList extends StatelessWidget {
  List list;
  ItemList({this.list});
  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, i) {
        return new Container(
          padding: const EdgeInsets.all(0.5),
          child: new Card(
            child: new ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.blue[400],
                  child: Icon(Icons.person, size: 20.0, color: Colors.white)),
              title: Text(
                list[i]['status_absen'],
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0),
              ),
              subtitle: Row(children: <Widget>[
                Text(
                  "Tgl : " + list[i]['tgl_absen'],
                ),
                Container(
                  height: 10,
                  child: VerticalDivider(color: Colors.grey),
                ),
                Text(
                  "Jam : " + list[i]['jam'],
                )
              ]),
              trailing: Icon(Icons.check, size: 20.0, color: Colors.green),
            ),
          ),
        );
      },
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
