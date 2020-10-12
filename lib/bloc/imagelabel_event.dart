part of 'imagelabel_bloc.dart';

@immutable
abstract class ImageLabelEvent extends Equatable {}

class LoadGallery extends ImageLabelEvent {
  @override
  List<Object> get props => [];
}
