import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const UserAvatar(
    this.imageUrl, {
    this.size = 64,
    super.key,
  });

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
      child: CachedNetworkImage(
        imageUrl: imageUrl ?? "",
        placeholder: (context, url) => Container(
          decoration: border(context),
          padding: EdgeInsets.all((size - 32) / 2),
          child: const CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: border(context),
          child: const Icon(Icons.person),
        ),
        fit: BoxFit.cover,
      ),
    );
  }
}
