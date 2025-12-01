import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';

class CustomSearchDropdownWithSearch extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final double searchHeight;
  final bool isMandatory;
  final String labelText;
  final bool readOnly;


  const CustomSearchDropdownWithSearch({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.hintText = "Select an item",
    this.searchHeight = 60,
    this.isMandatory = false,
    this.labelText = "",
    this.readOnly = false,

  });

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                if (isMandatory)
                  const Text(
                    "*",
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                if (isMandatory) const SizedBox(width: 3),
                Text(
                  labelText,
                  style: TextStyle(fontSize: 13, fontFamily: AppFonts.poppins),
                ),
              ],
            ),
          ),

        // Wrap inside FormField for validation
        FormField<String>(
          validator: (value) {
            if (isMandatory &&
                (selectedValue == null || selectedValue!.isEmpty)) {
              return 'Please select $labelText';
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.hasError ? Colors.red : AppColor.blackColor,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        hintText,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColor.hinttextblackColor,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      items: items
                          .map(
                            (item) => DropdownMenuItem(
                          value: item,
                          enabled: !readOnly, // 🔹 Disable individual items when readOnly
                          child: Text(
                            item,
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              color: readOnly ? Colors.grey : Colors.black, // 🔹 Change text color
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      value: selectedValue,
                      onChanged: readOnly
                          ? null // 🔹 Disable selection when readOnly = true
                          : (val) {
                        onChanged(val);
                        state.didChange(val);
                      },
                      buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 48,
                        decoration: BoxDecoration(
                          color: readOnly ? Colors.grey.shade200 : Colors.white, // 🔹 Show disabled UI
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      dropdownSearchData: readOnly
                          ? null // 🔹 Disable search when readOnly
                          : DropdownSearchData(
                        searchController: searchController,
                        searchInnerWidgetHeight: searchHeight,
                        searchInnerWidget: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(8),
                              hintText: 'Search...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                fontFamily: AppFonts.poppins,
                                color: AppColor.blackColor,
                              ),
                              fillColor: const Color(0xFFF2F2F2),
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return item.value.toString().toLowerCase().contains(
                            searchValue.toLowerCase(),
                          );
                        },
                      ),
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) searchController.clear();
                      },
                    ),

                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 8),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(
                        fontFamily: AppFonts.poppins,
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
