import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

class PhotoLabel {
  final String label;
  final AssetEntity assetEntity;
  final File photoFile;

  PhotoLabel(this.label, this.assetEntity, this.photoFile);
}
