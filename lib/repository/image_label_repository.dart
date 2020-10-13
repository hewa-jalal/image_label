import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_label/models/photo_label.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageLabelRepository {
  List<File> _files = [];
  List<PhotoLabel> _photoLabelsList = [];
  List<Uint8List> _thumbDataList = [];

  Future<List<Uint8List>> fetchNewMedia() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 10000);

      for (int i = 0; i < media.length - 1; i++) {
        var asset = media[i];
        var file = await asset.file;
        var thumbData = await asset.thumbDataWithSize(200, 200);
        _thumbDataList.add(thumbData);
        _files.add(file);
      }

      return _thumbDataList;
    } else {
      PhotoManager.openSetting();
      return _thumbDataList;
    }
  }

  Future<List<PhotoLabel>> labelImage() async {
    var text = '';
    for (int i = 0; i < _files.length; i++) {
      final newFile = _files[i];
      final visionImage = FirebaseVisionImage.fromFile(newFile);
      final labeler = FirebaseVision.instance.imageLabeler();

      final imageLabels = await labeler.processImage(visionImage);
      for (final label in imageLabels) {
        // final confidence = label.confidence;
        text = '$text ${label.text}';
      }
      _photoLabelsList.add(PhotoLabel(text, _thumbDataList[i]));
      text = '';
      labeler.close();
    }
    return _photoLabelsList;
  }

  Uint8List matchLabelToText() {
    for (var labelImage in _photoLabelsList) {
      var splitLabel = labelImage.label.split(' ');
      if (splitLabel.contains('Food')) {
        return labelImage.photoMemory;
      }
    }
    return null;
  }
}
