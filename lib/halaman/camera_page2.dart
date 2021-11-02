import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CameraPage2 extends StatefulWidget {
  @override
  _CameraPage2State createState() => _CameraPage2State();
}

class _CameraPage2State extends State<CameraPage2> {
  // File imageFile;
  CameraController controller;

  Future<void> initializeCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.low);
    await controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Future getImageGallery() async {
  //   var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

  //   final tempDir = await getTemporaryDirectory();
  //   final path = tempDir.path;

  //   int rand = new Math.Random().nextInt(100000);

  //   Img.Image image = Img.decodeImage(imageFile.readAsBytesSync());
  //   Img.Image smallerImg = Img.copyResize(image, width: 100, height: 100);

  //   var compressImg = new File("$path/image_$rand.jpg")
  //     ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 1000));

  //   setState(
  //     () {
  //       _image = compressImg;
  //     },
  //   );
  // }

  Future<File> takePicture() async {
    DateFormat dateFormat = DateFormat("yyyy_MM_dd_HH_mm_ss");
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
      backgroundColor: Colors.black,
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
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width /
                                    controller.value.aspectRatio,
                                child: CameraPreview(controller),
                              ),
                              Container(
                                width: 70,
                                height: 70,
                                margin: EdgeInsets.only(top: 50),
                                child: RaisedButton(
                                  onPressed: () async {
                                    if (!controller.value.isTakingPicture) {
                                      File result = await takePicture();
                                      Navigator.pop(context, result);
                                    }
                                    // upload(imageFile);
                                  },
                                  shape: CircleBorder(),
                                  color: Colors.blue,
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
