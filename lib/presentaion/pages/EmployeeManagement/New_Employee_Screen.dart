import 'package:flutter/material.dart';

class NewEmployeeScreen extends StatelessWidget {
  const NewEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Inactive Employees",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
