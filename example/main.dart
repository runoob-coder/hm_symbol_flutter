import 'package:flutter/material.dart';
import 'package:hm_symbol/hm_symbol.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Icon(HarmonySymbols.HarmonyOS, size: 68)),
      ),
    );
  }
}
