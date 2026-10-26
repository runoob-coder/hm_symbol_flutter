import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hm_symbol/hm_symbol.dart';

import 'icon_detail.dart';
import 'icon_entry.dart';
import 'symbol_tile.dart';

/// Browse and search the whole HarmonyOS Symbol set.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.themeMode,
    required this.onCycleThemeMode,
  });

  final ThemeMode themeMode;
  final VoidCallback onCycleThemeMode;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Indexed once, then kept alive so filtering stays snappy while typing.
  static final List<IndexedIcon> _allIcons =
      harmonySymbolCatalog.entries.map(IndexedIcon.new).toList()
        ..sort((a, b) => a.entry.key.compareTo(b.entry.key));

  /// One bucket per style, so switching category is a lookup, not a scan.
  static final Map<SymbolStyle, List<IndexedIcon>> _iconsByStyle = {
    for (final style in SymbolStyle.values)
      style: _allIcons
          .where((icon) => style.matches(icon.entry))
          .toList(growable: false),
  };

  /// `wifi left` is two terms, and an icon has to match both.
  static final RegExp _whitespace = RegExp(r'\s+');

  /// Below this offset the results are still near the top of the grid.
  static const double _backToTopThreshold = 600;

  /// Past this distance a scroll animation would outlast the user's patience.
  static const double _instantJumpDistance = 12000;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  /// Shared by the results [Scrollbar] and the results [GridView].
  ///
  /// Desktop and web platforms do not inherit the [PrimaryScrollController],
  /// so a scrollbar without its own controller cannot be painted there.
  final ScrollController _resultsController = ScrollController();

  SymbolStyle _style = SymbolStyle.all;
  List<IconEntry> _visibleIcons = _namesOf(_allIcons);
  double _iconSize = 32;

  /// The icons of the selected style, before the search query is applied.
  List<IndexedIcon> get _baseIcons => _iconsByStyle[_style]!;

  /// Whether the results are far enough from the top to offer a way back.
  bool get _isScrolledDown =>
      _resultsController.hasClients &&
      _resultsController.offset > _backToTopThreshold;

  static List<IconEntry> _namesOf(List<IndexedIcon> icons) => [
    for (final icon in icons) icon.entry,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _resultsController.dispose();
    super.dispose();
  }

  void _updateSearch(String value) {
    setState(() => _visibleIcons = _filter(value));
  }

  void _setStyle(SymbolStyle style) {
    if (style == _style) {
      return;
    }
    setState(() {
      _style = style;
      _visibleIcons = _filter(_searchController.text);
    });
    // The previous offset rarely means anything in another category.
    if (_resultsController.hasClients) {
      _resultsController.jumpTo(0);
    }
  }

  /// Icons of the current style matching every keyword, best match first.
  List<IconEntry> _filter(String value) {
    final query = value.trim().toLowerCase();
    final base = _baseIcons;
    if (query.isEmpty) {
      return _namesOf(base);
    }

    final terms = query.split(_whitespace);
    final matches = <({int score, IndexedIcon icon})>[];
    for (final icon in base) {
      final score = icon.score(terms);
      if (score >= 0) {
        matches.add((score: score, icon: icon));
      }
    }

    if (matches.length > 1) {
      matches.sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        return byScore != 0
            ? byScore
            : a.icon.entry.key.compareTo(b.icon.entry.key);
      });
    }
    return [for (final match in matches) match.icon.entry];
  }

  void _clearSearch() {
    _searchController.clear();
    _updateSearch('');
  }

  /// Focuses the search field and selects what is in it, so the next
  /// keystroke replaces the previous query.
  void _focusSearch() {
    _searchFocusNode.requestFocus();
    _searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _searchController.text.length,
    );
  }

  void _scrollToTop() {
    if (!_resultsController.hasClients) {
      return;
    }
    if (_resultsController.offset > _instantJumpDistance) {
      _resultsController.jumpTo(0);
      return;
    }
    _resultsController.animateTo(
      0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  /// `/`, `Ctrl/⌘ + F` jump to the search field, `Esc` clears the query.
  ///
  /// The handler sits on an ancestor [Focus], so it only runs while the search
  /// field (or anything else in this page) owns the keyboard — which also
  /// means a `/` typed into the field itself never reaches it.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      if (_searchController.text.isEmpty) {
        _searchFocusNode.unfocus();
      } else {
        _clearSearch();
      }
      return KeyEventResult.handled;
    }

    final keyboard = HardwareKeyboard.instance;
    final wantsSearch =
        (key == LogicalKeyboardKey.keyF &&
            (keyboard.isControlPressed || keyboard.isMetaPressed)) ||
        (key == LogicalKeyboardKey.slash && !_searchFocusNode.hasFocus);
    if (wantsSearch) {
      _focusSearch();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(HarmonySymbols.HarmonyOS, size: 22),
            SizedBox(width: 8),
            Flexible(
              child: Text('HarmonyOS Symbol', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Theme: ${widget.themeMode.name}',
            icon: Icon(_themeModeIcon),
            onPressed: widget.onCycleThemeMode,
          ),
        ],
      ),
      // Rebuilt from the scroll offset alone, never from the results.
      floatingActionButton: ListenableBuilder(
        listenable: _resultsController,
        builder: (context, _) =>
            _BackToTopButton(visible: _isScrolledDown, onPressed: _scrollToTop),
      ),
      body: Focus(
        onKeyEvent: _handleKeyEvent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              totalCount: _baseIcons.length,
              onChanged: _updateSearch,
              onCleared: _clearSearch,
            ),
            _Toolbar(
              style: _style,
              onStyleChanged: _setStyle,
              resultCount: _visibleIcons.length,
              totalCount: _baseIcons.length,
              iconSize: _iconSize,
              onIconSizeChanged: (value) => setState(() => _iconSize = value),
            ),
            Divider(height: 1, color: theme.dividerColor.withValues(alpha: .2)),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  IconData get _themeModeIcon => switch (widget.themeMode) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

  Widget _buildResults() {
    if (_visibleIcons.isEmpty) {
      return _EmptyState(
        query: _searchController.text.trim(),
        style: _style,
        onCleared: _clearSearch,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = _tileWidth(constraints.maxWidth);
        return Scrollbar(
          controller: _resultsController,
          thumbVisibility: true,
          child: GridView.builder(
            controller: _resultsController,
            // Four thousand tiles is far too many to keep alive.
            addAutomaticKeepAlives: false,
            // The bottom room keeps the back-to-top button off the last row.
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 76),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _maxTileWidth,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: tileWidth / (tileWidth * .3 + _iconSize + 30),
            ),
            itemCount: _visibleIcons.length,
            itemBuilder: (context, index) {
              final entry = _visibleIcons[index];
              return SymbolTile(
                entry: entry,
                iconSize: _iconSize,
                onTap: () => showSymbolDetail(context, entry),
              );
            },
          ),
        );
      },
    );
  }

  static const double _maxTileWidth = 116;

  /// Mirrors how [SliverGridDelegateWithMaxCrossAxisExtent] lays out tiles,
  /// so the aspect ratio can be derived from the real tile width.
  double _tileWidth(double availableWidth) {
    const padding = 24.0;
    const spacing = 8.0;
    final crossAxisExtent = math.max(0.0, availableWidth - padding);
    final crossAxisCount = math.max(
      1,
      (crossAxisExtent / (_maxTileWidth + spacing)).ceil(),
    );
    return (crossAxisExtent - spacing * (crossAxisCount - 1)) / crossAxisCount;
  }
}

/// Floats above the grid once the results have been scrolled a while.
class _BackToTopButton extends StatelessWidget {
  const _BackToTopButton({required this.visible, required this.onPressed});

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 180);
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, .5),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: FloatingActionButton.small(
            tooltip: 'Back to top',
            onPressed: onPressed,
            child: const Icon(Icons.arrow_upward_rounded),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.totalCount,
    required this.onChanged,
    required this.onCleared,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int totalCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search $totalCount icons, e.g. wifi, arrow left',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: .45,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close),
                      onPressed: onCleared,
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.style,
    required this.onStyleChanged,
    required this.resultCount,
    required this.totalCount,
    required this.iconSize,
    required this.onIconSizeChanged,
  });

  final SymbolStyle style;
  final ValueChanged<SymbolStyle> onStyleChanged;
  final int resultCount;
  final int totalCount;
  final double iconSize;
  final ValueChanged<double> onIconSizeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 16, 4),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SegmentedButton<SymbolStyle>(
            segments: [
              for (final option in SymbolStyle.values)
                ButtonSegment(
                  value: option,
                  icon: Icon(switch (option) {
                    SymbolStyle.all => HarmonySymbols.square_grid_2x2,
                    SymbolStyle.outline => HarmonySymbols.circle,
                    SymbolStyle.fill => HarmonySymbols.circle_fill,
                  }, size: 18),
                  label: Text(option.label),
                ),
            ],
            selected: {style},
            onSelectionChanged: (selection) => onStyleChanged(selection.first),
            showSelectedIcon: false,
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Text(
            '$resultCount / $totalCount icons',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.straighten, size: 16),
              SizedBox(
                width: 132,
                child: Slider(
                  min: 16,
                  max: 72,
                  divisions: 14,
                  value: iconSize,
                  label: iconSize.round().toString(),
                  onChanged: onIconSizeChanged,
                ),
              ),
              SizedBox(
                width: 22,
                child: Text(
                  iconSize.round().toString(),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.query,
    required this.style,
    required this.onCleared,
  });

  final String query;
  final SymbolStyle style;
  final VoidCallback onCleared;

  /// Headline of the empty state, mentioning the category when there is one.
  String get _title {
    if (query.isEmpty) {
      return 'No icons to show';
    }
    final kind = style == SymbolStyle.all
        ? 'icon'
        : '${style.label.toLowerCase()} icon';
    return 'No $kind named “$query”';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              _title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              style == SymbolStyle.all
                  ? 'Try fewer keywords, they are matched against the icon name.'
                  : 'Try fewer keywords, or switch back to the All category.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onCleared,
                icon: const Icon(Icons.close),
                label: const Text('Clear search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
