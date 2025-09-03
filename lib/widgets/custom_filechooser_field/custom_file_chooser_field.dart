import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';


class CustomFileChooserField extends StatelessWidget {
  final String labelText;
  final bool isMandatory;
  final File? selectedFile;
  final Function(File?) onFilePicked;
  final List<String> allowedExtensions;

  const CustomFileChooserField({
    super.key,
    required this.labelText,
    this.isMandatory = false,
    required this.selectedFile,
    required this.onFilePicked,
    required this.allowedExtensions,
  });

  Future<void> _pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      onFilePicked(File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isMandatory)
              const Text(
                "*",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            if (isMandatory) const SizedBox(width: 3),
            Text(
              labelText,
              style:  TextStyle(
                fontSize: 14,
                color: AppColor.blackColor,
                fontFamily: AppFonts.poppins,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        GestureDetector(
          onTap: () => _pickFile(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color:
                selectedFile == null
                    ? AppColor.blackColor
                    : AppColor.primaryColor2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    side: const BorderSide(color: Colors.black54),
                    backgroundColor: Colors.grey[100],
                    textStyle: const TextStyle(fontSize: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () => _pickFile(context),
                  child: const Text(
                    "Choose File",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: AppFonts.poppins,
                      color: AppColor.blackColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedFile != null
                        ? selectedFile!.path.split('/').last
                        : "No file chosen",
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: AppFonts.poppins,
                      color: AppColor.blackColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
