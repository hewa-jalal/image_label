import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class PhotoLabel {
  final String label;
  // final AssetEntity assetEntity;
  final Uint8List photoMemory;

  PhotoLabel(this.label, this.photoMemory);
}
