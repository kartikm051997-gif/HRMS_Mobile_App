import 'package:flutter/Material.dart';

import '../../../../core/fonts/fonts.dart';

class StatusButtonScreen extends StatefulWidget {
  const StatusButtonScreen({super.key});

  @override
  State<StatusButtonScreen> createState() => _StatusButtonScreenState();
}

class _StatusButtonScreenState extends State<StatusButtonScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton.icon(
            onPressed: () {
              _showStatusDialog(context);
            },
            icon: Icon(Icons.info_outline, size: 18),
            label: Text(
              "Status",
              style: TextStyle(fontFamily: AppFonts.poppins),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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

  void _showStatusDialog(BuildContext context) {
    final _descController = TextEditingController();
    String _selectedStatus = 'Unread';
    final List<String> statusList = ['Unread', 'In Progress', 'Completed'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Change Status',
            style: TextStyle(fontFamily: AppFonts.poppins),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status *',
                      style: TextStyle(fontFamily: AppFonts.poppins),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items:
                          statusList
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description *',
                      style: TextStyle(fontFamily: AppFonts.poppins),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter description',
                        hintStyle: TextStyle(fontFamily: AppFonts.poppins),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: AppFonts.poppins),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_descController.text.trim().isEmpty) {
                  // Simple validation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please fill out description.',
                        style: TextStyle(fontFamily: AppFonts.poppins),
                      ),
                    ),
                  );
                  return;
                }
                // Handle update logic here
                Navigator.pop(context);
              },
              child: const Text(
                'Update',
                style: TextStyle(fontFamily: AppFonts.poppins),
              ),
            ),
          ],
        );
      },
    );
  }
}
