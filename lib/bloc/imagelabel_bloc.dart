import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_label/models/photo_label.dart';
import 'package:image_label/repository/image_label_repository.dart';
import 'package:meta/meta.dart';

part 'imagelabel_event.dart';
part 'imagelabel_state.dart';

class ImageLabelBloc extends Bloc<ImageLabelEvent, ImageLabelState> {
  ImageLabelBloc(this._imageLabelRepository) : super(ImageLabelInitial());

  final ImageLabelRepository _imageLabelRepository;

  @override
  Stream<ImageLabelState> mapEventToState(
    ImageLabelEvent event,
  ) async* {
    if (event is LoadGallery) {
      final List<Uint8List> list = await _imageLabelRepository.fetchNewMedia();
      yield (GalleryLoaded(list));
    } else if (event is LabelImage) {
      final photoLabelList = await _imageLabelRepository.labelImage();
      yield (ImageLabeled(photoLabelList));
    }
  }
}
