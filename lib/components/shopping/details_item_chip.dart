import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';

class DetailsItemChip extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final String? label;
  final void Function() onTap;

  const DetailsItemChip({
    required this.icon,
    required this.tooltip,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = label != null;
    return Material(
      color: hasData ? Theme.of(context).colorScheme.tertiary : Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(32),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: PadRow(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: hasData ? 16 : 8),
            children: [
              Icon(icon, color: hasData ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onBackground),
              if (hasData) Text(label!, style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}
