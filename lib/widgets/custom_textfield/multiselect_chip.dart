
import 'package:flutter/material.dart';

import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';

class CustomMultiSelectField extends StatelessWidget {
  final List<String> options; // all available options
  final List<String> selectedItems; // currently selected
  final String labelText;
  final bool isMandatory;
  final Function(String value) onItemToggle; // callback to add/remove item

  const CustomMultiSelectField({
    super.key,
    required this.options,
    required this.selectedItems,
    required this.onItemToggle,
    this.labelText = "",
    this.isMandatory = false,
  });

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
                fontFamily: AppFonts.poppins,
                color: AppColor.blackColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        GestureDetector(
          onTap: () {
            _showOptionsDialog(context, options, selectedItems, onItemToggle);
          },
          child: Container(
            width: double.infinity, // ✅ max width
            constraints: const BoxConstraints(
              minHeight: 50, // ✅ decent minimum height
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: -8,
              children:
              selectedItems.isEmpty
                  ? [
                Text(
                  "Select values...",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppFonts.poppins,
                    color: AppColor.blackColor,
                  ),
                ),
              ]
                  : selectedItems
                  .map(
                    (e) => Chip(
                  label: Text(e),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => onItemToggle(e),
                  backgroundColor: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showOptionsDialog(
      BuildContext context,
      List<String> options,
      List<String> selectedItems,
      Function(String) onItemToggle,
      ) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          final item = options[index];
          final isSelected = selectedItems.contains(item);
          return ListTile(
            title: Text(item),
            trailing:
            isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              onItemToggle(item);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
