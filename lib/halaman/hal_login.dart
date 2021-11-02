import 'dart:async';
import 'package:absen/style/constants.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DaftarAdmin extends StatefulWidget {
  @override
  _DaftarAdminState createState() => _DaftarAdminState();
}

class _DaftarAdminState extends State<DaftarAdmin> {
  // ignore: cancel_subscriptions
  StreamSubscription<DataConnectionStatus> listener;

  checkInternet() async {
    print("The statement 'this machine is connected to the Internet' is: ");
    print(await DataConnectionChecker().hasConnection);
    print("Current status: ${await DataConnectionChecker().connectionStatus}");
    print("Last results: ${DataConnectionChecker().lastTryResults}");
    listener = DataConnectionChecker().onStatusChange.listen(
      (status) {
        switch (status) {
          case DataConnectionStatus.connected:
            print('Data connection is available.');
            break;
          case DataConnectionStatus.disconnected:
            print('You are disconnected from the internet.');
            break;
        }
      },
    );
    return await DataConnectionChecker().connectionStatus;
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _obscureText = true;
  String id = "";
  String nipku = "";
  int jmlData = 0;
  String kirimID = "";
  bool _loading = false;
  // ignore: unused_field
  bool _sudahlogin = false;

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

  TextEditingController nip = new TextEditingController();
  TextEditingController pass = new TextEditingController();
  TextEditingController nipLogin = new TextEditingController();
  TextEditingController passLogin = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _cekID();
    postID();
    //cekInternet();
    _cekLogin();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggle() {
    setState(
      () {
        _obscureText = !_obscureText;
      },
    );
  }

  Future _cekID() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString("IdHp") != null) {
      setState(
        () {
          id = pref.getString("IdHp");
        },
      );
    }
  }

  void postID() async {
    setState(
      () {
        _loading = true;
      },
    );
    SharedPreferences pref = await SharedPreferences.getInstance();
    final response = await http.post(
      "http://118.97.18.62/webservice/php_example.php",
      body: {
        "action": 'cek_hp',
        "id_hp": pref.getString("IdHp"),
      },
    );
    var idandroid = json.decode(response.body);
    if (idandroid.length >= 1) {
      if (this.mounted) {
        setState(
          () {
            jmlData = idandroid.length;
            _loading = false;
          },
        );
      }
      print("jadi login");
      print("id : " + id);
      print(idandroid);
      print(idandroid.length);
    } else {
      if (this.mounted) {
        setState(
          () {
            _loading = false;
          },
        );
      }
      print("daftar");
      print("id :" + id);
      print(idandroid);
      print(idandroid.length);
    }
  }

  void daftarID() async {
    // ignore: unused_local_variable
    SharedPreferences pref = await SharedPreferences.getInstance();
    final response = await http.post(
      "http://118.97.18.62/webservice/php_example.php",
      body: {
        "action": 'insert_hp',
        "idphone": id,
        "nipe": nip.text,
        "passworte": pass.text,
      },
    );
    var kirimID = json.decode(response.body);
    print(kirimID);
    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/DaftarAdmin');
      print(kirimID);
    } else {
      SnackBar snackBar = SnackBar(
        duration: Duration(seconds: 5),
        content: Text(
          'Password atau user salah',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'ULANGI',
          textColor: Colors.white,
          onPressed: () {
            print('SALAH');
          },
        ),
      );
      scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  void cekInternet() async {
    DataConnectionStatus status = await checkInternet();
    if (status == DataConnectionStatus.connected) {
      print("connect");
    } else {
      print("tidak connect");
      Alert(
        context: context,
        title: "Internet tidak ada",
        desc: "Periksa jaringan koneksi anda",
        type: AlertType.error,
        style: alertStyle,
        buttons: [
          DialogButton(
            child: Text(
              "ULANGI",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/DaftarAdmin'),
            color: Colors.red,
            radius: BorderRadius.circular(15.0),
          ),
        ],
      ).show();
    }
  }

  Future _cekLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("_sudahlogin") == true) {
      _sudahlogin = true;
      Navigator.pushReplacementNamed(context, '/HalAbsen');
    } else {
      _sudahlogin = false;
    }
  }

  void _login() async {
    setState(
      () {
        _loading = true;
      },
    );
    Future.delayed(
      Duration(seconds: 2),
      () async {
        final response = await http.post(
          "http://118.97.18.62/webservice/php_example.php",
          body: {
            "action": 'login_absen',
            "nipe": nipLogin.text,
            "passworte": passLogin.text,
          },
        );
        var loginuser = json.decode(response.body);
        if (loginuser.length >= 1) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setBool("_sudahlogin", true);
          pref.setString('nip', loginuser[0]['nip']);
          pref.setString('idphone', loginuser[0]['idphone']);
          pref.setString('lat_pusat', loginuser[0]['lat_pusat']);
          pref.setString('lot_pusat', loginuser[0]['lot_pusat']);
          pref.setString('skpd', loginuser[0]['skpd']);
          pref.setString('noper', loginuser[0]['noper']);
          setState(
            () {
              loginuser = loginuser;
            },
          );
          print(loginuser);
          setState(
            () {
              _loading = false;
            },
          );

          Navigator.of(context).pushNamedAndRemoveUntil(
            '/HalAbsen',
            ModalRoute.withName('/HalAbsen'),
          );
        } else {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setBool("_sudahlogin", false);
          setState(
            () {
              _loading = false;
            },
          );
          print(loginuser);
          SnackBar snackBar = SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              'Password atau user salah',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'ULANGI',
              textColor: Colors.white,
              onPressed: () {
                print('SALAH');
              },
            ),
          );
          scaffoldKey.currentState.showSnackBar(snackBar);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    if (jmlData >= 1) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.blue[400],
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          color: Colors.blue[400],
          opacity: 0.5,
          progressIndicator:
              CircularProgressIndicator(backgroundColor: Colors.red),
          child: Container(
            width: mediaQueryData.size.width,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: mediaQueryData.size.height * 0.03,
                vertical: mediaQueryData.size.height * 0.1,
              ),
              child: Column(
                children: <Widget>[
                  _logo(),
                  SizedBox(
                    height: mediaQueryData.size.height * 0.03,
                  ),
                  _inputNIPLogin(),
                  SizedBox(
                    height: mediaQueryData.size.height * 0.03,
                  ),
                  _inputPasswordLogin(),
                  SizedBox(
                    height: mediaQueryData.size.height * 0.08,
                  ),
                  _loginButton(),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.blue[400],
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          color: Colors.blue[400],
          opacity: 1,
          progressIndicator:
              CircularProgressIndicator(backgroundColor: Colors.red),
          child: Container(
            width: mediaQueryData.size.width,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: mediaQueryData.size.height * 0.03,
                vertical: mediaQueryData.size.height * 0.1,
              ),
              child: Column(
                children: <Widget>[
                  _logo(),
                  SizedBox(
                    height: mediaQueryData.size.height * 0.03,
                  ),
                  _inputNIP(),
                  SizedBox(
                    height: mediaQueryData.size.height * 0.03,
                  ),
                  _inputPassword(),
                  SizedBox(
                    height: mediaQueryData.size.height * 0.08,
                  ),
                  _loginButton2(),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _logo() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        "assets/images/desa1.png",
        width: mediaQueryData.size.height * 0.2,
        height: mediaQueryData.size.height * 0.2,
      ),
    );
  }

  Widget _inputNIP() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: mediaQueryData.size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Username',
            style: kLabelStyle,
          ),
          SizedBox(height: mediaQueryData.size.height * 0.01),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: mediaQueryData.size.height * 0.07,
            child: TextField(
              controller: nip,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
                fontSize: 15,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(top: mediaQueryData.size.height * 0.02),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
                hintText: 'Masukan username',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputNIPLogin() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: mediaQueryData.size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Username',
            style: kLabelStyle,
          ),
          SizedBox(height: mediaQueryData.size.height * 0.01),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: mediaQueryData.size.height * 0.07,
            child: TextField(
              controller: nipLogin,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
                fontSize: 15,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(top: mediaQueryData.size.height * 0.02),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
                hintText: 'Masukan username',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputPassword() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: mediaQueryData.size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Password',
            style: kLabelStyle,
          ),
          SizedBox(height: mediaQueryData.size.height * 0.01),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: mediaQueryData.size.height * 0.07,
            child: TextFormField(
              controller: pass,
              obscureText: _obscureText,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
                fontSize: 15,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(top: mediaQueryData.size.height * 0.02),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  color: Colors.grey,
                  iconSize: 20.0,
                  onPressed: _toggle,
                ),
                hintText: 'Masukan Password',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputPasswordLogin() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: mediaQueryData.size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Password',
            style: kLabelStyle,
          ),
          SizedBox(height: mediaQueryData.size.height * 0.01),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: mediaQueryData.size.height * 0.07,
            child: TextFormField(
              controller: passLogin,
              obscureText: _obscureText,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
                fontSize: 15,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(top: mediaQueryData.size.height * 0.02),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  color: Colors.grey,
                  iconSize: 20.0,
                  onPressed: _toggle,
                ),
                hintText: 'Masukan Password',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginButton() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: mediaQueryData.size.width,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          cekInternet();
          _login();
        },
        padding: EdgeInsets.all(mediaQueryData.size.height * 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors.green,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _loginButton2() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: mediaQueryData.size.width,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          cekInternet();
          postID();
          daftarID();
        },
        padding: EdgeInsets.all(mediaQueryData.size.height * 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors.orange[600],
        child: Text(
          'DAFTAR',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }
}
