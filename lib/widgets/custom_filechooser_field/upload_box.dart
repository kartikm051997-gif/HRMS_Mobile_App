import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadBox extends StatelessWidget {
  final Function(List<PlatformFile>) onFilesPicked;

  const UploadBox({super.key, required this.onFilesPicked});

  Future<void> _pickFiles() async {
    FilePickerResult? result =
    await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      onFilesPicked(result.files);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFiles,
      child: DottedBorder(
        color: Colors.blue,
        strokeWidth: 2,
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [8, 4],
        child: Container(
          height: 150,
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.upload_file, size: 40, color: Colors.blue),
              SizedBox(height: 10),
              Text(
                "Drop files here to upload",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
