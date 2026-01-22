// Multi-Select Dropdown Widget with Search
import 'package:flutter/Material.dart';

import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';

class MultiSelectDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;
  final bool zoneEnableSelectAll; // 👈 add
  final bool designationEnableSelectAll; // 👈 add

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.zoneEnableSelectAll = false,
    this.designationEnableSelectAll = false, // 👈 default false
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  bool _isExpanded = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items
        .where(
          (item) => item.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontFamily: AppFonts.poppins,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
              if (!_isExpanded) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedItems.isEmpty
                        ? 'Select ${widget.label}'
                        : widget.selectedItems.join(", "),
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 14,
                      color:
                          widget.selectedItems.isEmpty
                              ? Colors.grey[600]
                              : AppColor.primaryColor1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
        if (_isExpanded)
          Container(
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
                // Search TextField
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.label}...',
                      hintStyle: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
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
                        borderSide: const BorderSide(color: Color(0xFF8E0E6B)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 14,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                // List of items
                if (widget.zoneEnableSelectAll ||
                    widget.designationEnableSelectAll)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8E0E6B).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF8E0E6B).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              widget.onChanged(List.from(_filteredItems));
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8E0E6B),
                                    Color(0xFFD4145A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF8E0E6B,
                                    ).withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Select All',
                                    style: TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              widget.onChanged([]);
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    size: 16,
                                    color: Colors.grey[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Clear All',
                                    style: TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child:
                      _filteredItems.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No ${widget.label.toLowerCase()} found',
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
                              final isSelected = widget.selectedItems.contains(
                                item,
                              );

                              return CheckboxListTile(
                                dense: true,
                                value: isSelected,
                                title: Text(
                                  item,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 14,
                                  ),
                                ),
                                activeColor: const Color(0xFF8E0E6B),
                                onChanged: (bool? checked) {
                                  final updatedList = List<String>.from(
                                    widget.selectedItems,
                                  );
                                  if (checked == true &&
                                      !updatedList.contains(item)) {
                                    updatedList.add(item);
                                  } else if (checked == false) {
                                    updatedList.remove(item);
                                  }

                                  widget.onChanged(updatedList);
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
  }
}
