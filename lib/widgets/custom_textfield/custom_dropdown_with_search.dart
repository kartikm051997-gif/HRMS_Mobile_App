import 'package:flutter/material.dart';
import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';

class CustomSearchDropdownWithSearch extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final bool isMandatory;
  final String labelText;
  final bool readOnly;

  const CustomSearchDropdownWithSearch({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.hintText = "Select",
    this.isMandatory = false,
    this.labelText = "",
    this.readOnly = false,
  });

  @override
  State<CustomSearchDropdownWithSearch> createState() =>
      _CustomSearchDropdownWithSearchState();
}

class _CustomSearchDropdownWithSearchState
    extends State<CustomSearchDropdownWithSearch> {
  bool _isExpanded = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<String> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items
        .where(
          (item) => item.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LABEL
            if (widget.labelText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    if (widget.isMandatory)
                      const Text(
                        "*",
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    if (widget.isMandatory) const SizedBox(width: 4),
                    Text(
                      widget.labelText,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: AppFonts.poppins,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

            /// DROPDOWN BUTTON
            GestureDetector(
              onTap:
                  widget.readOnly
                      ? null
                      : () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                          if (!_isExpanded) {
                            _searchQuery = '';
                            _searchController.clear();
                          }
                        });
                      },
              child: Container(
                width: constraints.maxWidth, // ✅ SAME WIDTH
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      widget.readOnly ? Colors.grey.shade200 : Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.selectedValue ?? widget.hintText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 14,
                          color:
                              widget.selectedValue == null
                                  ? Colors.grey[600]
                                  : AppColor.primaryColor1,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF8E0E6B),
                    ),
                  ],
                ),
              ),
            ),

            /// DROPDOWN LIST
            if (_isExpanded)
              Container(
                width: constraints.maxWidth, // ✅ SAME WIDTH
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// SEARCH
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins, // ✅ TYPED TEXT FONT
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Search ${widget.labelText.isNotEmpty ? widget.labelText : ''}...',
                          hintStyle: TextStyle(
                            fontFamily: AppFonts.poppins, // ✅ HINT FONT
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF8E0E6B),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                      ),
                    ),

                    /// ITEMS
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child:
                          _filteredItems.isEmpty
                              ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'No data found',
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredItems[index];
                                  final isSelected =
                                      widget.selectedValue == item;

                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      item,
                                      style: TextStyle(
                                        fontFamily: AppFonts.poppins,
                                        fontSize: 14,
                                        color:
                                            isSelected
                                                ? AppColor.primaryColor1
                                                : Colors.black,
                                      ),
                                    ),
                                    trailing:
                                        isSelected
                                            ? const Icon(
                                              Icons.check,
                                              color: Color(0xFF8E0E6B),
                                            )
                                            : null,
                                    onTap: () {
                                      widget.onChanged(item);
                                      setState(() {
                                        _isExpanded = false;
                                        _searchQuery = '';
                                        _searchController.clear();
                                      });
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
