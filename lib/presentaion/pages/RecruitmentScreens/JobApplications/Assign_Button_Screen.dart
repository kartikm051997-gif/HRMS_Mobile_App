import 'package:flutter/Material.dart';

import '../../../../core/fonts/fonts.dart';

class AssignButtonScreen extends StatefulWidget {
  const AssignButtonScreen({super.key});

  @override
  State<AssignButtonScreen> createState() => _AssignButtonScreenState();
}

class _AssignButtonScreenState extends State<AssignButtonScreen> {
  String? selectedAssignee;
  final List<String> assigneeList = [
    "Durga Prakash",
    "S.Madhumitha",
    "M.Sneha",
    "DIVYAA AMALANATHAN",
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,

          child: ElevatedButton.icon(
            onPressed: () {
              _showAssignDialog();
            },
            icon: Icon(Icons.assignment_ind, size: 18),
            label: Text(
              "Assign",
              style: TextStyle(fontFamily: AppFonts.poppins),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:  Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

      ],
    );
  }

  void _showAssignDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Assign",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Text(
                  "Assign to *",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    fontFamily: AppFonts.poppins,
                  ),
                ),

                SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: InputBorder.none,
                    ),
                    hint: Text(
                      "Select",
                      style: TextStyle(fontFamily: AppFonts.poppins),
                    ),
                    value: selectedAssignee,
                    items:
                    assigneeList.map((String assignee) {
                      return DropdownMenuItem<String>(
                        value: assignee,
                        child: Text(assignee),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAssignee = newValue;
                      });
                    },
                  ),
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontFamily: AppFonts.poppins),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedAssignee != null) {
                          // Handle assignment logic here
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Assigned to $selectedAssignee"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffa14f79),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        "Assign",
                        style: TextStyle(fontFamily: AppFonts.poppins),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
