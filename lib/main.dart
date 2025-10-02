// Main.dart //
import 'dart:io';
import 'package:window_size/window_size.dart';
import 'package:flutter/material.dart';
import 'connection_checker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(600, 400));
    setWindowMaxSize(Size.infinite);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chand?",
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: "Vazir"),
      home: const ConnectionChecker(),
    );
  }
}
