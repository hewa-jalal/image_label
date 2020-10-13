import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_label/bloc/imagelabel_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool imageLoaded = false;
  var displayFile;

  var text = '';

  // File matchLabelToText() {
  //   for (var labelImage in _photoLabelsList) {
  //     var splitLabel = labelImage.label.split(' ');
  //     if (splitLabel.contains('Chair')) {
  //       return labelImage.photoFile;
  //     }
  //   }
  //   return File(null);
  // }

  @override
  Widget build(BuildContext context) {
    final imageLabelBloc = BlocProvider.of<ImageLabelBloc>(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () => imageLabelBloc.add(LoadGallery()),
              child: Text('Bloc test'),
            ),
            SizedBox(height: 20),
            BlocBuilder<ImageLabelBloc, ImageLabelState>(
              builder: (context, state) {
                if (state is GalleryLoaded) {
                  return Expanded(
                    child: Column(
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () => imageLabelBloc.add(LabelImage()),
                          child: Text('Label the images'),
                        ),
                        Expanded(
                          child: GridView.builder(
                              itemCount: state.thumbDataList.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                              ),
                              itemBuilder: (context, index) {
                                return Image.memory(
                                  state.thumbDataList[index],
                                  fit: BoxFit.cover,
                                );
                              }),
                        ),
                      ],
                    ),
                  );
                } else if (state is ImageLabeled) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.photoLabelList.length,
                      itemBuilder: (context, index) => Expanded(
                        child: Column(
                          children: <Widget>[
                            Image.memory(
                              state.photoLabelList[index].photoMemory,
                              fit: BoxFit.cover,
                            ),
                            Text(state.photoLabelList[index].label),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Center(child: FlutterLogo());
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
