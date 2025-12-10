import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// アプリケーションのメインウィジェット
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

/// アプリケーションの状態を管理するクラス
/// Tickerを使用して経過時間を利用してアニメーションを実装
class _AppState extends State<App> {
  late Ticker ticker;
  double elapsedSeconds = 0;

  @override
  void initState() {
    ticker = Ticker((elapsed) {
      setState(() {
        elapsedSeconds = elapsed.inMilliseconds.toDouble() / 1000;
      });
    });
    ticker.start();

    super.initState();
  }

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
