import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class ImageLabelRepository {
  Future<List<Uint8List>> fetchNewMedia() async {
    List<Uint8List> thumbDataList = [];
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 10000);

      for (int i = 0; i < media.length; i++) {
        var asset = media[i];
        var thumbData = await asset.thumbDataWithSize(200, 200);
        thumbDataList.add(thumbData);
      }

      return thumbDataList;
    } else {
      PhotoManager.openSetting();
      return thumbDataList;
    }
  }
}
