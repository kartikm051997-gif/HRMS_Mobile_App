import 'package:flutter/material.dart';

class InActiveScreen extends StatelessWidget {
  const InActiveScreen({super.key});

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
