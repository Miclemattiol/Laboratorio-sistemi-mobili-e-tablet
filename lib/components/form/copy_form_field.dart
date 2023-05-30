import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/main.dart';

class CopyFormField extends StatefulWidget {
  final InputDecoration? decoration;
  final String textToCopy;
  final Duration fadeDuration;

  const CopyFormField(
    this.textToCopy, {
    this.decoration,
    this.fadeDuration = const Duration(milliseconds: 500),
    super.key,
  });

  @override
  State<CopyFormField> createState() => _CopyFormFieldState();
}

class _CopyFormFieldState extends State<CopyFormField> {
  Timer? _copyTimer;
  bool _copied = false;

  void _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.textToCopy));

    if (!mounted) return;
    setState(() => _copied = true);
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(milliseconds: 1500), () => setState(() => _copied = false));
  }

  @override
  void dispose() {
    super.dispose();
    _copyTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _copy(context),
      child: InputDecorator(
        decoration: widget.decoration ?? const InputDecoration(),
        child: PadRow(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  AnimatedOpacity(
                    opacity: _copied ? 0 : 1,
                    duration: _copied ? Duration.zero : widget.fadeDuration,
                    child: Text(widget.textToCopy, overflow: TextOverflow.ellipsis),
                  ),
                  AnimatedOpacity(
                    opacity: _copied ? 1 : 0,
                    duration: _copied ? Duration.zero : widget.fadeDuration,
                    child: Text(localizations(context).copied),
                  ),
                ],
              ),
            ),
            const Icon(Icons.copy)
          ],
        ),
      ),
    );
  }
}
