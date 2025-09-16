import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';

import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';

class RemoteAttendanceScreen extends StatefulWidget {
  const RemoteAttendanceScreen({super.key});

  @override
  State<RemoteAttendanceScreen> createState() => _RemoteAttendanceScreenState();
}

class _RemoteAttendanceScreenState extends State<RemoteAttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Remote Attendance "),
      body: Center(
        child: Text(
          "Remote Attendance Screen",
          style: TextStyle(fontFamily: AppFonts.poppins, fontSize: 18),
        ),
      ),
    );
  }
}
