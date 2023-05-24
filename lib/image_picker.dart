import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImage(BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  final source = await showModalBottomSheet(
    context: context,
    builder: (context) => CustomBottomSheet(
      padding: EdgeInsets.zero,
      spacing: 0,
      body: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text("Scatta foto"),
          onTap: () => Navigator.of(context).pop<ImageSource>(ImageSource.camera),
        ),
        ListTile(
          leading: const Icon(Icons.image),
          title: const Text("Scegli foto"),
          onTap: () => Navigator.of(context).pop<ImageSource>(ImageSource.gallery),
        )
      ],
    ),
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
