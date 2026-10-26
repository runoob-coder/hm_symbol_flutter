import 'package:flutter/widgets.dart';

typedef IconEntry = MapEntry<String, IconData>;

/// The glyph styles the catalog is split into.
///
/// HarmonyOS names a filled symbol with a `fill` token — `heart_fill`,
/// `wifi_fill_mirroring`, `circle_filled_and_circle` — every other symbol is
/// drawn as an outline.
enum SymbolStyle {
  /// Every symbol.
  all('All'),

  /// Symbols drawn as outlines, e.g. `heart`.
  outline('Outline'),

  /// Symbols drawn as solid shapes, e.g. `heart_fill`.
  fill('Fill');

  const SymbolStyle(this.label);

  /// Human readable name, used by the gallery filter.
  final String label;

  /// Whether [entry] belongs to this style.
  bool matches(IconEntry entry) => switch (this) {
    SymbolStyle.all => true,
    SymbolStyle.outline => !entry.isFilled,
    SymbolStyle.fill => entry.isFilled,
  };
}

/// A catalog entry plus the strings the search needs.
///
/// Lower-casing and tokenising every name once keeps typing cheap: a keystroke
/// only compares strings, it never allocates them again.
final class IndexedIcon {
  IndexedIcon(this.entry)
    : lower = entry.key.toLowerCase(),
      tokens = entry.key.split('_');

  final IconEntry entry;

  /// The name in lower case, e.g. `wifi_fill`.
  final String lower;

  /// The words of the name, e.g. `[wifi, fill]`.
  final List<String> tokens;

  /// How well [terms] describe this icon, or `-1` when a term is missing.
  ///
  /// An exact name beats a name prefix, which beats a word prefix, which beats
  /// a match anywhere in the name — so `wifi` ranks above `wifi_slash`.
  int score(List<String> terms) {
    var total = 0;
    for (final term in terms) {
      final termScore = _scoreTerm(term);
      if (termScore < 0) {
        return -1;
      }
      total += termScore;
    }
    return total;
  }

  int _scoreTerm(String term) {
    if (lower == term) {
      return 8;
    }
    if (lower.startsWith(term)) {
      return 6;
    }
    if (tokens.any((token) => token.startsWith(term))) {
      return 4;
    }
    return lower.contains(term) ? 1 : -1;
  }
}

extension IconEntryX on IconEntry {
  String get name => key;

  IconData get icon => value;

  /// The font code point, e.g. `U+F0000`.
  String get unicode =>
      'U+${value.codePoint.toRadixString(16).toUpperCase().padLeft(5, '0')}';

  /// Ready to paste Flutter code, e.g. `Icon(HarmonySymbols.wifi)`.
  String get snippet => 'Icon(HarmonySymbols.$name)';

  /// Whether the symbol is the filled variant of its outline shape.
  bool get isFilled => _fillToken.hasMatch(name);
}

/// Matches the `fill` / `filled` tokens HarmonyOS uses for solid glyphs.
final RegExp _fillToken = RegExp(r'(^|_)(fill|filled)(_|$)');
