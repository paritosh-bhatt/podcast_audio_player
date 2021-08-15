import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:pod_player/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Qalam Podcast",
    home: HomePage(),
  ));
}
