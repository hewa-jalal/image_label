import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_label/models/photo_label.dart';
import 'package:image_label/repository/image_label_repository.dart';
import 'package:photo_manager/photo_manager.dart';

import 'bloc/imagelabel_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImageLabelBloc(ImageLabelRepository()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaGrid(),
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
  List<PhotoLabel> _photoLabelsList = [];
  var _indexTest = 0;

  bool imageLoaded = false;
  File pickedImage;
  var displayFile;

  var text = '';

  @override
  void initState() {
    super.initState();
    // _fetchNewMedia();
  }

  void _fetchNewMedia() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
          onlyAll: true, type: RequestType.image);
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 10000);

      List<Widget> temp = [];
      for (int i = 0; i < media.length; i++) {
        var asset = media[i];
        temp.add(
          FutureBuilder<Uint8List>(
            future: asset.thumbDataWithSize(200, 200),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return Column(
                  children: <Widget>[
                    // Text(
                    //   i.toString(),
                    //   style: TextStyle(
                    //     color: Colors.red,
                    //     fontSize: 20,
                    //   ),
                    // ),
                    Expanded(
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
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  Future pickImage() async {
    for (int i = 0; i < _mediaList.length; i++) {
      // _indexTest++;

      final newFile = await _mediaList[i].file;
      final visionImage = FirebaseVisionImage.fromFile(newFile);
      final labeler = FirebaseVision.instance.imageLabeler();

      final imageLabels = await labeler.processImage(visionImage);
      for (final label in imageLabels) {
        // final confidence = label.confidence;
        setState(() => text = "$text ${label.text} ");
      }
      _photoLabelsList.add(PhotoLabel(text, _mediaList[i], newFile));
      text = '';
      labeler.close();
    }
  }

  File matchLabelToText() {
    for (var labelImage in _photoLabelsList) {
      var splitLabel = labelImage.label.split(' ');
      if (splitLabel.contains('Chair')) {
        return labelImage.photoFile;
      }
    }
    return File(null);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ImageLabelBloc>(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () => bloc.add(LoadGallery()),
              child: Text('Bloc test'),
            ),
            // SizedBox(
            //   height: 100,
            //   child: SingleChildScrollView(
            //     child: Text(text),
            //   ),
            // ),
            SizedBox(height: 20),
            BlocBuilder<ImageLabelBloc, ImageLabelState>(
              builder: (context, state) {
                if (state is GalleryLoaded) {
                  return Expanded(
                    child: GridView.builder(
                        itemCount: state.thumbDataList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemBuilder: (context, index) {
                          return Image.memory(
                            state.thumbDataList[index],
                            fit: BoxFit.cover,
                          );
                        }),
                  );
                }
                return Container(color: Colors.red);
              },
            ),
            SizedBox(height: 20),
            _photoLabelsList.length != 0
                ? Expanded(
                    child: ListView(
                      children: [
                        Image.file(
                          _photoLabelsList[0].photoFile,
                          width: 100,
                          height: 100,
                        ),
                        Text(_photoLabelsList[1].label),
                        Center(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                displayFile = matchLabelToText();
                              });

                              print('displayFile $displayFile');
                            },
                            child: Text(
                              'photo label length ${_photoLabelsList.length}',
                            ),
                          ),
                        ),
                        displayFile != null
                            ? Expanded(
                                child: Image.file(
                                  displayFile,
                                  width: 100,
                                  height: 100,
                                ),
                              )
                            : Container()
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
