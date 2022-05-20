import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewerPage extends StatefulWidget {
  const ViewerPage({
    Key? key,
    required this.dirPath,
  }) : super(key: key);

  final String dirPath;

  @override
  State<StatefulWidget> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  List<File> _files = <File>[];
  int _chosenIndex = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _files = Directory(widget.dirPath)
        .listSync()
        .where(_isImageFile)
        .map((entity) => entity as File)
        .toList();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(children: [
        Expanded(
            flex: 16,
            child: Container(
              alignment: Alignment.center,
              height: 160,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _files
                      .asMap()
                      .entries
                      .map((entry) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _chosenIndex = entry.key;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            width: 140,
                            child: Image.file(entry.value),
                          )))
                      .toList()),
            )),
        Expanded(
            flex: 84,
            child: Stack(children: [
              Container(
                alignment: Alignment.center,
                child: Image.file(_files[_chosenIndex]),
              ),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: _TapNavigation(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          action: () {
                            setState(() {
                              if (_chosenIndex > 0) {
                                _chosenIndex--;
                              }
                            });
                          },
                          fade: Fade.left)),
                  const Expanded(flex: 4, child: SizedBox()),
                  Expanded(
                      flex: 2,
                      child: _TapNavigation(
                        icon: const Icon(Icons.arrow_forward,
                            color: Colors.white),
                        action: () {
                          setState(() {
                            if (_chosenIndex < _files.length - 1) {
                              _chosenIndex++;
                            }
                          });
                        },
                        fade: Fade.right,
                      )),
                ],
              )
            ]))
      ]),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  bool _isImageFile(FileSystemEntity entity) =>
      entity is File &&
      (entity.path.endsWith("png") ||
          entity.path.endsWith("jpg") ||
          entity.path.endsWith("gif"));
}

class _TapNavigation extends StatelessWidget {
  const _TapNavigation(
      {Key? key,
      required this.icon,
      required this.action,
      this.fade = Fade.none})
      : super(key: key);

  final Icon icon;
  final Function action;
  final Fade fade;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          action();
        },
        child: Container(
          alignment: Alignment.center,
          decoration: fade.decoration,
          child: icon,
        ));
  }
}

enum Fade {
  right(BoxDecoration(
      gradient: LinearGradient(
          begin: FractionalOffset.centerLeft,
          end: FractionalOffset.centerRight,
          colors: [Colors.transparent, Colors.black26]))),
  left(BoxDecoration(
      gradient: LinearGradient(
          begin: FractionalOffset.centerRight,
          end: FractionalOffset.centerLeft,
          colors: [Colors.transparent, Colors.black26]))),
  none(null);

  const Fade(this.decoration);

  final Decoration? decoration;
}
