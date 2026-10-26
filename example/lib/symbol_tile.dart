import 'package:flutter/material.dart';

import 'icon_entry.dart';

class SymbolTile extends StatelessWidget {
  const SymbolTile({
    super.key,
    required this.entry,
    required this.iconSize,
    required this.onTap,
  });

  /// Corner radius shared by the card and its ink, so the ripple stays inside.
  static const _radius = BorderRadius.all(Radius.circular(14));

  final IconEntry entry;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurfaceVariant;
    return Tooltip(
      // Names are clipped to two lines, hovering reveals the whole one.
      message: entry.name,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: _radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: _radius,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(entry.icon, size: iconSize, color: foreground),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  entry.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10.5,
                    height: 1.2,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
