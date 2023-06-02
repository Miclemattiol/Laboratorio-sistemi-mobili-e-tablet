import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageAvatar extends StatelessWidget {
  final dynamic image;
  final Widget fallback;
  final double size;
  final bool enabled;
  final double progressSize;
  final double? progress;
  final void Function()? onTap;

  const ImageAvatar(
    this.image, {
    required this.fallback,
    this.size = 64,
    this.onTap,
    this.enabled = true,
    this.progressSize = 32,
    this.progress,
    super.key,
  }) : assert(image is File || image is String?);

  static const BorderRadius _borderRadius = BorderRadius.all(Radius.circular(10));

  BoxDecoration _border(BuildContext context) {
    return BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(enabled ? 1 : .25)),
      borderRadius: _borderRadius,
    );
  }

  Widget _mainWidget() {
    final image = this.image;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(borderRadius: _borderRadius),
        child: image is File
            ? Image.file(image, fit: BoxFit.cover)
            : CachedNetworkImage(
                imageUrl: (image as String?) ?? "",
                placeholder: (context, url) => Container(
                  decoration: _border(context),
                  padding: EdgeInsets.all((size - progressSize) / 2),
                  child: const CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: _border(context),
                  child: fallback,
                ),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _progressWidget(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: _border(context).copyWith(color: Colors.black26),
      child: Padding(
        padding: EdgeInsets.all((size - progressSize) / 2),
        child: CircularProgressIndicator(value: progress),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (progress == null || progress == 0) {
      return _mainWidget();
    } else {
      return Stack(
        children: [
          _mainWidget(),
          _progressWidget(context),
        ],
      );
    }
  }
}
