import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'screens/model_check.dart';
import 'screens/random_universe.dart';
import 'screens/universe.dart';

enum UniverseType { universe, randomUniverse, modelCheck }

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
  UniverseType _selectedUniverseType = UniverseType.universe;

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

  Widget _buildUniverse() {
    switch (_selectedUniverseType) {
      case UniverseType.universe:
        return Universe(elapsedSeconds: elapsedSeconds);
      case UniverseType.randomUniverse:
        return RandomUniverse(elapsedSeconds: elapsedSeconds);
      case UniverseType.modelCheck:
        return const ModelCheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planetarium',
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text(_selectedUniverseType.name)),
        body: Stack(
          children: [
            _buildUniverse(),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<UniverseType>(
                    value: _selectedUniverseType,
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.white,
                    underline: const SizedBox.shrink(),
                    onChanged: (UniverseType? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedUniverseType = newValue;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: UniverseType.universe,
                        child: Text('Universe'),
                      ),
                      DropdownMenuItem(
                        value: UniverseType.randomUniverse,
                        child: Text('Random Universe'),
                      ),
                      DropdownMenuItem(
                        value: UniverseType.modelCheck,
                        child: Text('Model Check'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
