import 'package:flutter/material.dart';

import 'home_page.dart';

void main() => runApp(const SymbolGalleryApp());

/// HarmonyOS brand blue, used as the seed color of the gallery theme.
const _seedColor = Color(0xFF007DFF);

/// The gallery application: a searchable showcase of every HarmonyOS Symbol.
///
/// It runs on mobile, desktop and web. See `web/` for the web specific bits.
class SymbolGalleryApp extends StatefulWidget {
  const SymbolGalleryApp({super.key});

  @override
  State<SymbolGalleryApp> createState() => _SymbolGalleryAppState();
}

class _SymbolGalleryAppState extends State<SymbolGalleryApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _cycleThemeMode() {
    setState(() {
      _themeMode = switch (_themeMode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HarmonyOS Symbol',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeMode,
      home: HomePage(themeMode: _themeMode, onCycleThemeMode: _cycleThemeMode),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
