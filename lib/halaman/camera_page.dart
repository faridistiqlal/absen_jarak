import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as Math;
import 'package:image/image.dart' as Img; //NOTE image

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File imageFile;
  File _image;
  CameraController controller;

  Future<void> initializeCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    await controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future getImageGallery() async {
    // ignore: deprecated_member_use
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    int rand = new Math.Random().nextInt(100000);

    Img.Image image = Img.decodeImage(imageFile.readAsBytesSync());
    Img.Image smallerImg = Img.copyResize(image, width: 100, height: 100);

    var compressImg = new File("$path/image_$rand.jpg")
      ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 1000));

    setState(
      () {
        _image = compressImg;
      },
    );
  }

  Future<File> takePicture() async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd-HH-mm-ss");
    //int rand = new Math.Random().nextInt(100000);
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/Guided.Camera';
    await Directory(directoryPath).create(recursive: true);
    //String filePath = '$directoryPath/$rand.jpg';
    String filePath = '$directoryPath/${dateFormat.format(DateTime.now())}.jpg';

    try {
      await controller.takePicture(filePath);
    } catch (e) {
      return null;
    }
    return File(filePath);
  }

  Future upload(File imageFile) async {
    var stream =
        // ignore: deprecated_member_use
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    // var uri = Uri.parse(
    //     "http://192.168.98.173/desa/webservice/android/kabar/postberita");

    var uri = Uri.parse("http://118.97.18.62/webservice/upload_image.php");

    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = new http.MultipartFile("file", stream, length,
        filename: basename(imageFile.path));

    request.files.add(multipartFile);
    var response = await request.send();

    if (response.statusCode == 200) {
      print("Image Uploaded");
      print(imageFile);
      //print(multipartFile);
      // Navigator.of(this.context).pushNamedAndRemoveUntil(
      //     '/CameraPage', ModalRoute.withName('/CameraPage'));
    } else {
      print("Upload Failed");
    }
    response.stream.transform(utf8.decoder).listen(
      (value) {
        print(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: initializeCamera(),
          builder: (_, snapshot) =>
              (snapshot.connectionState == ConnectionState.done)
                  ? Stack(
                      children: [
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 100,
                                height: 150,
                                child: CameraPreview(controller),
                              ),
                              // Container(
                              //   color: Colors.grey,
                              //   width: 100,
                              //   height: 150,
                              //   child: (imageFile != null)
                              //       ? Image.file(imageFile)
                              //       : SizedBox(),
                              // ),
                              Container(
                                width: 70,
                                height: 70,
                                margin: EdgeInsets.only(top: 50),
                                child: RaisedButton(
                                  onPressed: () async {
                                    if (!controller.value.isTakingPicture) {
                                      File result = await takePicture();
                                      setState(
                                        () {
                                          imageFile = result;
                                        },
                                      );
                                    }
                                    upload(imageFile);
                                  },
                                  shape: CircleBorder(),
                                  color: Colors.blue,
                                ),
                              ),
                              Container(
                                width: 70,
                                height: 70,
                                margin: EdgeInsets.only(top: 50),
                                child: RaisedButton(
                                  onPressed: () async {
                                    upload(imageFile);
                                  },
                                  shape: CircleBorder(),
                                  color: Colors.orange,
                                ),
                              ),
                              Center(
                                child: _image == null
                                    ? new Text("Gambar belum di pilih !")
                                    : new Image.file(_image),
                              ),
                              Row(
                                children: <Widget>[
                                  RaisedButton(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.white,
                                    ),
                                    onPressed: getImageGallery,
                                    color: Color(0xFFee002d),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(17.0),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 30,
                                height: 30,
                                margin: EdgeInsets.only(top: 50),
                                child: RaisedButton(
                                  onPressed: () async {
                                    upload(_image);
                                  },
                                  shape: CircleBorder(),
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      ),
                    ),
        ),
      ),
    );
  }
}
