import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_symbol/hm_symbol.dart';
import 'package:hm_symbol_example/icon_entry.dart';
import 'package:hm_symbol_example/main.dart';
import 'package:hm_symbol_example/symbol_tile.dart';

void main() {
  final total = harmonySymbolCatalog.length;

  testWidgets('shows the whole catalog and filters it by name', (tester) async {
    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pump();

    expect(find.text('HarmonyOS Symbol'), findsWidgets);
    expect(find.text('$total / $total icons'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'wifi');
    await tester.pump();

    expect(find.text('$total / $total icons'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data!.endsWith('/ $total icons'),
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'definitely-not-a-symbol');
    await tester.pump();

    expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
  });

  testWidgets('filters the catalog by symbol style', (tester) async {
    final total = harmonySymbolCatalog.length;
    final filled = harmonySymbolCatalog.entries.where((e) => e.isFilled).length;
    final outline = total - filled;

    List<SymbolTile> tiles() =>
        tester.widgetList<SymbolTile>(find.byType(SymbolTile)).toList();

    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pump();

    expect(find.text('$total / $total icons'), findsOneWidget);

    await tester.tap(find.text('Fill'));
    await tester.pumpAndSettle();

    expect(find.text('$filled / $filled icons'), findsOneWidget);
    expect(tiles(), isNotEmpty);
    expect(tiles().every((tile) => tile.entry.isFilled), isTrue);

    await tester.tap(find.text('Outline'));
    await tester.pumpAndSettle();

    expect(find.text('$outline / $outline icons'), findsOneWidget);
    expect(tiles(), isNotEmpty);
    expect(tiles().every((tile) => !tile.entry.isFilled), isTrue);

    // The category narrows the keyword search down instead of replacing it.
    await tester.enterText(find.byType(TextField), 'wifi');
    await tester.pump();

    expect(tiles(), isNotEmpty);
    expect(
      tiles().every(
        (tile) => !tile.entry.isFilled && tile.entry.name.contains('wifi'),
      ),
      isTrue,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data!.endsWith('/ $outline icons'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data!.endsWith('/ $total icons'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('keeps the category filter usable on a phone sized screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 3, 690 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final filter = tester.getRect(find.byType(SegmentedButton<SymbolStyle>));
    expect(filter.left, greaterThanOrEqualTo(0));
    expect(filter.right, lessThanOrEqualTo(360));
  });

  testWidgets('keeps the grid scrollbar attached on desktop and web', (
    tester,
  ) async {
    // Desktop and web platforms do not inherit the PrimaryScrollController, so
    // the Scrollbar used to assert that it had no ScrollPosition attached.
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await tester.pumpWidget(const SymbolGalleryApp());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(SymbolTile), findsWidgets);

      await tester.fling(find.byType(GridView), const Offset(0, -400), 800);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('ranks the exact match above longer names', (tester) async {
    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'wifi');
    await tester.pump();

    final names = tester
        .widgetList<SymbolTile>(find.byType(SymbolTile))
        .map((tile) => tile.entry.name)
        .toList();
    expect(names, isNotEmpty);
    expect(names.first, 'wifi');
    expect(names, contains('wifi_slash'));
  });

  testWidgets('jumps to the search field with the find shortcut', (
    tester,
  ) async {
    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'wifi');
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyF);
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    // The whole query is selected, so the next keystroke replaces it.
    expect(field.controller!.selection.baseOffset, 0);
    expect(field.controller!.selection.extentOffset, 4);
  });

  testWidgets('clears the query with escape', (tester) async {
    final total = harmonySymbolCatalog.length;

    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'wifi');
    await tester.pump();
    expect(find.text('$total / $total icons'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(find.text('$total / $total icons'), findsOneWidget);
  });

  testWidgets('offers a way back to the top once the grid is scrolled', (
    tester,
  ) async {
    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pump();

    double backToTopOpacity() => tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: find.byTooltip('Back to top'),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;

    expect(backToTopOpacity(), 0);

    await tester.drag(find.byType(GridView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(backToTopOpacity(), 1);

    await tester.tap(find.byTooltip('Back to top'));
    await tester.pumpAndSettle();

    expect(backToTopOpacity(), 0);
  });

  testWidgets('opens the detail sheet of a symbol', (tester) async {
    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'wifi');
    await tester.pump();

    expect(find.byType(SymbolTile), findsWidgets);
    await tester.tap(find.byType(SymbolTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Copy code'), findsOneWidget);
    expect(find.text('Copy name'), findsOneWidget);
  });

  testWidgets('opens a dialog instead of a sheet on a desktop window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'wifi');
    await tester.pump();
    await tester.tap(find.byType(SymbolTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    // A mouse needs an explicit way out; a thumb has the drag handle.
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.text('Copy code'), findsOneWidget);
  });

  testWidgets('keeps the bottom sheet on a phone sized window', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'wifi');
    await tester.pump();
    await tester.tap(find.byType(SymbolTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Copy code'), findsOneWidget);
  });

  testWidgets('closes the detail panel with escape', (tester) async {
    await tester.pumpWidget(const SymbolGalleryApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'wifi');
    await tester.pump();
    await tester.tap(find.byType(SymbolTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Copy code'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Copy code'), findsNothing);
    // Escape belonged to the panel: the page behind it kept its query.
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'wifi',
    );
  });
}
