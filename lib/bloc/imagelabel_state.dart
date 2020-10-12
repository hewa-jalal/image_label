part of 'imagelabel_bloc.dart';

@immutable
abstract class ImageLabelState extends Equatable {}

class ImageLabelInitial extends ImageLabelState {
  @override
  List<Object> get props => [];
}

class GalleryLoaded extends ImageLabelState {
  final List<Uint8List> thumbDataList;

  GalleryLoaded(this.thumbDataList);
  @override
  List<Object> get props => [];
}