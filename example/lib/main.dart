import 'package:flutter/material.dart';

import 'drawing_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LayoutBuilder(builder: (context, constraints) {
        return DrawingPage(
          canvasSize: constraints.biggest,
          // outCallback: () {
          //   print('STOP: Drawing out of the canvas');
          // },
        );
      }),
    );
  }
}
