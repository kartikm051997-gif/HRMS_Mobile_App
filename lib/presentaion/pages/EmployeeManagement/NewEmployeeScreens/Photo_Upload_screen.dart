import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';

class ProfilePhotoField extends StatefulWidget {
  final String labelText;
  final bool isMandatory;
  final File? selectedFile;
  final Function(File?) onFilePicked;
  final List<String> allowedExtensions;

  const ProfilePhotoField({
    super.key,
    required this.labelText,
    this.isMandatory = false,
    this.selectedFile,
    required this.onFilePicked,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png'],
  });

  @override
  State<ProfilePhotoField> createState() => _ProfilePhotoFieldState();
}

class _ProfilePhotoFieldState extends State<ProfilePhotoField> {
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
        widget.onFilePicked(file); // send to parent
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
    widget.onFilePicked(null); // clear photo via parent
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
              fontFamily: 'Poppins',
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

        // Upload Card
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Preview
              Container(
                width: double.infinity,
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE5E7EB),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                      ),
                      child:
                          widget.selectedFile != null
                              ? ClipOval(
                                child: Image.file(
                                  widget.selectedFile!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                ),
                              )
                              : _buildDefaultAvatar(),
                    ),
                    const SizedBox(height: 16),

                    // Remove button
                    if (widget.selectedFile != null)
                      TextButton.icon(
                        onPressed: _removeFile,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.red[600],
                        ),
                        label: Text(
                          'Remove Photo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // File Picker
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                    ),
                    onTap: _isLoading ? null : _pickFile,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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
                            Text(
                              'Uploading...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              Icons.upload_outlined,
                              size: 20,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.selectedFile != null
                                  ? 'Change Photo'
                                  : 'Choose File',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Helper text
        if (widget.selectedFile == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Accepted formats: ${widget.allowedExtensions.join(", ")}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Selected: ${widget.selectedFile!.path.split('/').last}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF059669),
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.poppins,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return const Center(
      child: Icon(Icons.person_outline, size: 48, color: Color(0xFF6B7280)),
    );
  }
}
