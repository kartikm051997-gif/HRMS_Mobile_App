import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';

class DocumentUploadField extends StatefulWidget {
  final String labelText;
  final bool isMandatory;
  final File? selectedFile;
  final Function(File?) onFilePicked;
  final List<String> allowedExtensions;

  const DocumentUploadField({
    super.key,
    required this.labelText,
    this.isMandatory = false,
    this.selectedFile,
    required this.onFilePicked,
    this.allowedExtensions = const ['pdf', 'doc', 'docx'],
  });

  @override
  State<DocumentUploadField> createState() => _DocumentUploadFieldState();
}

class _DocumentUploadFieldState extends State<DocumentUploadField> {
  bool _isLoading = false;

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: false,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        widget.onFilePicked(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeFile() {
    widget.onFilePicked(null);
  }

  String _getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  IconData _getFileIcon(String fileName) {
    final extension = _getFileExtension(fileName);
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String fileName) {
    final extension = _getFileExtension(fileName);
    switch (extension) {
      case 'pdf':
        return Colors.red[600]!;
      case 'doc':
      case 'docx':
        return Colors.blue[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        RichText(
          text: TextSpan(
            text: widget.labelText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.blackColor,
              fontFamily: AppFonts.poppins,
            ),
            children:
                widget.isMandatory
                    ? [
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]
                    : [],
          ),
        ),
        const SizedBox(height: 8),

        // Upload Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // File Display Area
              if (widget.selectedFile != null) ...[
                // Selected File Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                  ),
                  child: Row(
                    children: [
                      // File Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Icon(
                          _getFileIcon(widget.selectedFile!.path),
                          size: 32,
                          color: _getFileIconColor(widget.selectedFile!.path),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // File Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedFile!.path.split('/').last,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontFamily: AppFonts.poppins,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_getFileExtension(widget.selectedFile!.path).toUpperCase()} File',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Remove Button
                      IconButton(
                        onPressed: _removeFile,
                        icon: Icon(
                          Icons.close,
                          color: Colors.red[600],
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
              ] else ...[
                // Empty State
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: Colors.blue[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No file selected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose a file to upload',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
              ],

              // Upload Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                  onTap: _isLoading ? null : _pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading) ...[
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Uploading...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            widget.selectedFile != null
                                ? Icons.swap_horiz
                                : Icons.upload_file,
                            size: 20,
                            color: const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.selectedFile != null
                                ? 'Change File'
                                : 'Select File',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Helper Text
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            widget.selectedFile == null
                ? 'Accepted formats: ${widget.allowedExtensions.join(", ")}'
                : 'File uploaded successfully',
            style: TextStyle(
              fontSize: 12,
              color:
                  widget.selectedFile == null
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF059669),
              fontWeight: FontWeight.w400,
              fontFamily: AppFonts.poppins,
            ),
          ),
        ),
      ],
    );
  }
}
