import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PaymentImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool isFile;
  final File? imageFile;

  const PaymentImage(
    this.imageUrl, {
    this.size = 64,
    super.key,
  }) : isFile = false, imageFile = null;

  const PaymentImage.file(
    this.imageFile, {
    this.size = 64,
    super.key,
  }) : isFile = true, imageUrl = null;

  static BorderRadius get _borderRadius => BorderRadius.circular(10);

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
      decoration: BoxDecoration(borderRadius: _borderRadius),
      child: isFile ? Image.file(imageFile!, fit: BoxFit.cover) : CachedNetworkImage(
        imageUrl: imageUrl ?? "",
        placeholder: (context, url) => Container(
          decoration: border(context),
          padding: EdgeInsets.all((size - 32) / 2),
          child: const CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: border(context),
          child: const Icon(Icons.image),
        ),
        fit: BoxFit.cover,
      ),
    );
  }
}
