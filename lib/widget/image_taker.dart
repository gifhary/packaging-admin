import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class ImageTaker extends StatelessWidget {
  final Uint8List imageFile;
  final String imageUrl;
  final Function(Uint8List)? onImagePicked;

  const ImageTaker(
      {Key? key,
      required this.imageFile,
      required this.imageUrl,
      this.onImagePicked})
      : super(key: key);

  _getCustomerSignature() {
    ImagePickerWeb.getImageAsBytes().then((value) {
      if (value != null) onImagePicked!(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _getCustomerSignature,
      child: Container(
        decoration: BoxDecoration(
            color: imageFile.isNotEmpty || imageUrl.isNotEmpty
                ? Colors.white
                : Colors.grey.withOpacity(0.2),
            border: Border.all(color: const Color.fromRGBO(160, 152, 128, 1))),
        width: 250,
        height: 150,
        child: imageFile.isNotEmpty
            ? Image.memory(
                imageFile,
                fit: BoxFit.contain,
              )
            : imageUrl.isNotEmpty
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      ),
                      Icon(
                        Icons.edit,
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file),
                      Text(
                        'upload stamp and signature',
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
      ),
    );
  }
}
