import 'package:flutter/material.dart';

import 'homepage.dart';

void main() {
  runApp(DogEncyclopediaApp());
}

class DogEncyclopediaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}


