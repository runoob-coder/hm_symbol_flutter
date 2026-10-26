import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'icon_entry.dart';

/// Window width at which the detail panel turns into a dialog.
///
/// A phone gets a sheet pulled up from the bottom edge, where the thumb is;
/// a desktop window gets a panel in the middle of the screen, where the mouse
/// already is.
const double _desktopMinWidth = 720;

/// Height a window needs before a centred panel fits in it.
///
/// A phone in landscape is wide but short: it keeps the sheet.
const double _desktopMinHeight = 480;

/// The panel never grows past this, in either presentation.
const double _panelMaxWidth = 560;

/// Opens the detail panel of a single symbol.
///
/// Wide windows get a [Dialog], narrow ones a bottom sheet; both share
/// [_SymbolDetailBody].
Future<void> showSymbolDetail(BuildContext context, IconEntry entry) {
  final size = MediaQuery.sizeOf(context);
  if (size.width >= _desktopMinWidth && size.height >= _desktopMinHeight) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => _SymbolDetailDialog(
        entry: entry,
        // Always leave a slice of the window visible around the panel,
        // even when the browser viewport is short.
        maxHeight: math.max(320.0, size.height * .86),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: _panelMaxWidth),
    builder: (sheetContext) => _SymbolDetailBody(entry: entry),
  );
}

/// The desktop presentation: a floating panel with a close button.
class _SymbolDetailDialog extends StatelessWidget {
  const _SymbolDetailDialog({required this.entry, required this.maxHeight});

  final IconEntry entry;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      constraints: BoxConstraints(
        minWidth: 320,
        maxWidth: _panelMaxWidth,
        maxHeight: maxHeight,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Flexible(child: _SymbolDetailBody(entry: entry)),
        ],
      ),
    );
  }
}

class _SymbolDetailBody extends StatefulWidget {
  const _SymbolDetailBody({required this.entry});

  final IconEntry entry;

  @override
  State<_SymbolDetailBody> createState() => _SymbolDetailBodyState();
}

class _SymbolDetailBodyState extends State<_SymbolDetailBody> {
  double _size = 56;
  double _weight = 400;

  /// Owned here, because a bottom sheet has no [PrimaryScrollController] in
  /// scope for a [Scrollbar] to attach to.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// `Esc` closes the panel, for the sheet and the dialog alike.
  ///
  /// The handler sits on the panel itself and takes the autofocus, so it also
  /// wins over the home page shortcut that clears the search query.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 380;
                    final info = _SymbolMeta(
                      entry: widget.entry,
                      stacked: stacked,
                      onCopied: _showCopiedMessage,
                    );
                    final preview = _SymbolPreview(
                      entry: widget.entry,
                      size: _size,
                      weight: _weight,
                    );
                    if (stacked) {
                      return Column(
                        children: [preview, const SizedBox(height: 16), info],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        preview,
                        const SizedBox(width: 20),
                        Expanded(child: info),
                      ],
                    );
                  },
                ),
                const Divider(height: 36),
                _ControlSlider(
                  label: 'Size',
                  value: _size,
                  min: 16,
                  max: 128,
                  onChanged: (value) => setState(() => _size = value),
                  display: '${_size.round()} px',
                ),
                _ControlSlider(
                  label: 'Weight',
                  value: _weight,
                  min: 100,
                  max: 700,
                  divisions: 12,
                  onChanged: (value) => setState(() => _weight = value),
                  display: _weight.round().toString(),
                ),
                const SizedBox(height: 4),
                Text(
                  'The font is variable: size and weight are handled by Flutter, '
                  'there is no need for separate assets.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCopiedMessage(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied “$value”'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SymbolPreview extends StatelessWidget {
  const _SymbolPreview({
    required this.entry,
    required this.size,
    required this.weight,
  });

  final IconEntry entry;
  final double size;
  final double weight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Icon(
        entry.icon,
        size: size.clamp(16, 128),
        weight: weight,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

class _SymbolMeta extends StatelessWidget {
  const _SymbolMeta({
    required this.entry,
    required this.stacked,
    required this.onCopied,
  });

  final IconEntry entry;
  final bool stacked;
  final ValueChanged<String> onCopied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          entry.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaChip(label: entry.unicode),
            _MetaChip(label: entry.isFilled ? 'Filled' : 'Outline'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Rendering check',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final swatch in _swatches)
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.4,
                  child: Container(
                    margin: EdgeInsets.only(
                      right: swatch == _swatches.last ? 0 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: swatch.$1,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(entry.icon, size: 20, color: swatch.$2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _copy(entry.snippet),
              icon: const Icon(Icons.code_rounded, size: 18),
              label: const Text('Copy code'),
            ),
            OutlinedButton.icon(
              onPressed: () => _copy(entry.name),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy name'),
            ),
          ],
        ),
        if (stacked) const SizedBox(height: 8),
      ],
    );
  }

  static const _swatches = [
    (Colors.white, Colors.black),
    (Color(0xFF007DFF), Colors.white),
    (Color(0xFF1A1A1A), Colors.white),
  ];

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    onCopied(value);
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontFamily: 'monospace',
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _ControlSlider extends StatelessWidget {
  const _ControlSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.display,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String display;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          child: Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value,
            label: display,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            display,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
