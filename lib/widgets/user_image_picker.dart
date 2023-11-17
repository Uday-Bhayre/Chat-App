import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class userImagePicker extends StatefulWidget {
  userImagePicker({super.key, required this.onPickImg});
  final void Function(File) onPickImg;
  @override
  State<StatefulWidget> createState() {
    return _userImagePickerState();
  }
}

class _userImagePickerState extends State<userImagePicker> {
  File? _img;
  void _pickImage() async {
    final imgPicked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 90,
    );
    if (imgPicked == null) {
      return;
    }
    setState(() {
      _img = File(imgPicked.path);
    });
    widget.onPickImg(_img!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blueGrey,
          foregroundImage: _img != null ? FileImage(_img!) : null,
          radius: 50,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ],
    );
  }
}
