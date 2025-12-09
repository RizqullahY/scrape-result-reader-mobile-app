import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const ComicApp());
}

class ComicApp extends StatelessWidget {
  const ComicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Offline Comic Reader",
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
