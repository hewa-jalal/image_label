import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaGrid(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool imageLoaded = false;
  File pickedImage;
  var text = '';

  final _picker = ImagePicker();

  Future pickImage() async {
    text = '';
    var awaitImage = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = File(awaitImage.path);
      imageLoaded = true;
    });
    final visionImage = FirebaseVisionImage.fromFile(pickedImage);
    final labeler = FirebaseVision.instance.imageLabeler();

    final imageLabels = await labeler.processImage(visionImage);
    for (final label in imageLabels) {
      final confidence = label.confidence;
      setState(() {
        text = "$text ${label.text} ";

        print(text);
      });
    }

    labeler.close();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Pick image'),
              ),
              pickedImage != null
                  ? Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height / 1.5,
                          child: Image.file(pickedImage),
                        ),
                        Text(
                          text,
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        )
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class MediaGrid extends StatefulWidget {
  @override
  _MediaGridState createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  List<Widget> _mediaListWidget = [];
  List<AssetEntity> _mediaList = [];
  var _indexTest = 0;
  int currentPage = 0;
  int lastPage = 1;

  bool imageLoaded = false;
  File pickedImage;
  var text = '';

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  void _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
          onlyAll: true, type: RequestType.image);
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 10000);

      List<Widget> temp = [];
      for (int i = 0; i < media.length - 1; i++) {
        var asset = media[i];
        temp.add(
          FutureBuilder(
            future: asset.thumbDataWithSize(200, 200),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return Column(
                  children: <Widget>[
                    Text(i.toString(),
                        style: TextStyle(color: Colors.red, fontSize: 20)),
                    Positioned.fill(
                      child: Image.memory(
                        snapshot.data,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                );
              return Container();
            },
          ),
        );
      }

      setState(() {
        _mediaList.addAll(media);
        _mediaListWidget.addAll(temp);
        // currentPage++;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  Future pickImage() async {
    for (int i = 0; i < _mediaList.length - 1; i++) {
      _indexTest++;
      print('I loop $i');
      print('length ${_mediaList.length}');

      final newFile = await _mediaList[_indexTest].file;
      final visionImage = FirebaseVisionImage.fromFile(newFile);
      final labeler = FirebaseVision.instance.imageLabeler();

      final imageLabels = await labeler.processImage(visionImage);
      for (final label in imageLabels) {
        // final confidence = label.confidence;
        setState(() => text = "$text ${label.text} ");
      }

      labeler.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick image'),
            ),
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                child: Text(text),
              ),
            ),
            Expanded(
              child: GridView.builder(
                  itemCount: _mediaList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (context, index) {
                    return _mediaListWidget[index];
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
