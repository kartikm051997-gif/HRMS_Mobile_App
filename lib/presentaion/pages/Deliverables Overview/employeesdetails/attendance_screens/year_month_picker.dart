

import 'package:flutter/material.dart';

class YearMonthPicker extends StatefulWidget {
  final DateTime currentMonth;
  final Function(DateTime) onMonthSelected;

  const YearMonthPicker({
    super.key,
    required this.currentMonth,
    required this.onMonthSelected,
  });

  @override
  State<YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.currentMonth.year;
    selectedMonth = widget.currentMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Year selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  selectedYear--;
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              selectedYear.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  selectedYear++;
                });
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Month grid
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(12, (index) {
              final monthNames = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ];

              final monthIndex = index + 1;
              final isSelected =
                  monthIndex == selectedMonth &&
                      selectedYear == widget.currentMonth.year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMonth = monthIndex;
                  });
                  widget.onMonthSelected(DateTime(selectedYear, monthIndex, 1));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                    isSelected
                        ? const Color(0xFF1976D2)
                        : const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(8),
                    border:
                    monthIndex == selectedMonth
                        ? Border.all(
                      color: const Color(0xFF1976D2),
                      width: 2,
                    )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      monthNames[index],
                      style: TextStyle(
                        color:
                        isSelected ? Colors.white : const Color(0xFF202124),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}