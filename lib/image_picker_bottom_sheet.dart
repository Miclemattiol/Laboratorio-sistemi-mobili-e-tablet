import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final dynamic image;

  const ImagePickerBottomSheet._({
    this.image,
  }) : assert(image is File || image is String?);

  static Future<File?> pickImage(BuildContext context, {dynamic image}) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final source = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ImagePickerBottomSheet._(image: image),
    );
    if (source == null) return null;

    try {
      final file = await ImagePicker().pickImage(source: source);
      return file == null ? null : File(file.path);
    } on PlatformException catch (_) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("Impossibile accedere alla ${source == ImageSource.camera ? "fotocamera" : "galleria"}\nControlla i permessi dell'app")));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = (this.image is String && (this.image as String).isEmpty) ? null : this.image;
    return CustomBottomSheet(
      padding: EdgeInsets.zero,
      spacing: 0,
      body: [
        if (image != null)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
              child: image is File //TODO when tapping open page with the image
                  ? Image.file(image, fit: BoxFit.fitWidth)
                  : CachedNetworkImage(
                      fit: BoxFit.fitWidth,
                      imageUrl: image as String,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const SizedBox.shrink(),
                    ),
            ),
          ),
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text("Scatta foto"),
          onTap: () => Navigator.of(context).pop<ImageSource>(ImageSource.camera),
        ),
        ListTile(
          leading: const Icon(Icons.image),
          title: const Text("Scegli foto"),
          onTap: () => Navigator.of(context).pop<ImageSource>(ImageSource.gallery),
        ),
      ],
    );
  }
}
