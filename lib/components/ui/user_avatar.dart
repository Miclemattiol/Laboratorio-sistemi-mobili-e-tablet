import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final Widget fallback;
  final double size;

  const ImageAvatar(
    this.imageUrl, {
    required this.fallback,
    this.size = 64,
    super.key,
  }) : imageFile = null;

  const ImageAvatar.file(
    File this.imageFile, {
    required this.fallback,
    this.size = 64,
    super.key,
  }) : imageUrl = null;

  static const BorderRadius _borderRadius = BorderRadius.all(Radius.circular(10));

  static BoxDecoration border(BuildContext context) {
    return BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: _borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(borderRadius: _borderRadius),
      child: imageFile != null
          ? Image.file(imageFile!, fit: BoxFit.cover)
          : CachedNetworkImage(
              imageUrl: imageUrl ?? "",
              placeholder: (context, url) => Container(
                decoration: border(context),
                padding: EdgeInsets.all((size - 32) / 2),
                child: const CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: border(context),
                child: fallback,
              ),
              fit: BoxFit.cover,
            ),
    );
  }
}
