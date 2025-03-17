import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:zoom_flutter_hello_world/videochat.dart';

class ZoomVideoSdkProvider extends StatelessWidget {
  const ZoomVideoSdkProvider({super.key});

  @override
  Widget build(BuildContext context) {
    var zoom = ZoomVideoSdk();
    InitConfig initConfig = InitConfig(
      domain: "zoom.us",
      enableLog: true,
    );
    zoom.initSdk(initConfig);
    return const Videochat();
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Zoom Flutter Hello World',
      home: const SafeArea(
        child: ZoomVideoSdkProvider(),
      ),
    ),
  );
}
