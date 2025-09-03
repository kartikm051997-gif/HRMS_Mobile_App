
import 'package:flutter/material.dart';

import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';

class SelectAllMultiSelectTextfield extends StatefulWidget {
  final String labelText;
  final String hintText;

  final List<String> items;
  final List<String> selectedValues; // external state (provider)
  final ValueChanged<List<String>>
  onChanged; // callback to update external state
  final bool isMandatory;

  const SelectAllMultiSelectTextfield({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.items,
    required this.selectedValues,
    required this.onChanged,
    this.isMandatory = false,
  });

  @override
  State<SelectAllMultiSelectTextfield> createState() =>
      _SelectAllMultiSelectTextfieldState();
}

class _SelectAllMultiSelectTextfieldState
    extends State<SelectAllMultiSelectTextfield> {
  late final TextEditingController _fieldController;

  @override
  void initState() {
    super.initState();
    _fieldController = TextEditingController(
      text: widget.selectedValues.join(", "),
    );
  }

  @override
  void didUpdateWidget(covariant SelectAllMultiSelectTextfield oldWidget) {
    super.didUpdateWidget(oldWidget);
    // keep the field display in sync with external (provider) changes
    if (oldWidget.selectedValues != widget.selectedValues) {
      _fieldController.text = widget.selectedValues.join(", ");
    }
  }

  @override
  void dispose() {
    _fieldController.dispose();
    super.dispose();
  }

  Future<void> _openPicker() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (ctx) => _MultiSelectBottomSheet(
        title: widget.labelText,
        items: widget.items,
        initialSelected: widget.selectedValues,
      ),
    );

    if (!mounted) return;
    if (result != null) {
      widget.onChanged(result);
      _fieldController.text = result.join(", ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (widget.isMandatory)
              const Text(
                "*",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            if (widget.isMandatory) const SizedBox(width: 3),
            Text(
              widget.labelText,
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
          onTap: _openPicker,
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              controller: _fieldController,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: AppFonts.poppins,
                color: AppColor.blackColor,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: AppFonts.poppins,
                  color: AppColor.hinttextblackColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Internal bottom sheet widget with search + select/deselect all + checkboxes
class _MultiSelectBottomSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> initialSelected;

  const _MultiSelectBottomSheet({
    required this.title,
    required this.items,
    required this.initialSelected,
  });

  @override
  State<_MultiSelectBottomSheet> createState() =>
      _MultiSelectBottomSheetState();
}

class _MultiSelectBottomSheetState extends State<_MultiSelectBottomSheet> {
  late List<String> _tempSelected;
  late List<String> _filtered;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelected = List<String>.from(widget.initialSelected);
    _filtered = List<String>.from(widget.items);

    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List<String>.from(widget.items);
      } else {
        _filtered =
            widget.items.where((e) => e.toLowerCase().contains(q)).toList();
      }
    });
  }

  void _toggle(String item) {
    setState(() {
      if (_tempSelected.contains(item)) {
        _tempSelected.remove(item);
      } else {
        _tempSelected.add(item);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _tempSelected = List<String>.from(
        widget.items,
      ); // all items (not just filtered)
    });
  }

  void _deselectAll() {
    setState(() {
      _tempSelected.clear();
    });
  }

  bool get _allSelected =>
      _tempSelected.length == widget.items.length && widget.items.isNotEmpty;
  bool get _noneSelected => _tempSelected.isEmpty;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final sheetHeight = media.size.height * 0.85;

    return SizedBox(
      height: sheetHeight,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: AppFonts.poppins,
                      color: AppColor.blackColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.pop(context, widget.initialSelected),
                  child: const Text(
                    "Cancel",
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppFonts.poppins,
                      color: AppColor.blackColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6E0E6B), Color(0xFFD4145A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, _tempSelected),
                    child: const Text(
                      "Apply",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: Colors.white, // text color stays white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search + Select All controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search...",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: _allSelected ? null : _selectAll,

                    child: const Text(
                      "Select All",
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: AppFonts.poppins,
                        color: AppColor.blackColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: _noneSelected ? null : _deselectAll,

                    child: const Text(
                      "Deselect All",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppFonts.poppins,
                        color: AppColor.blackColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selected count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Selected: ${_tempSelected.length}/${widget.items.length}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),

          const Divider(height: 1),

          // List
          Expanded(
            child:
            _filtered.isEmpty
                ? const Center(child: Text("No results"))
                : ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final item = _filtered[i];
                final checked = _tempSelected.contains(item);
                return CheckboxListTile(
                  dense: true,
                  title: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppFonts.poppins,
                      color: AppColor.blackColor,
                    ),
                  ),
                  value: checked,
                  activeColor: AppColor.primaryColor2,
                  checkColor: Colors.white,
                  onChanged: (_) => _toggle(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
