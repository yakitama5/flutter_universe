import 'package:flutter/material.dart';

/// アプリケーションのメインウィジェット
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rocket Game',
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text('Rocket Game')),
      ),
    );
  }
}
