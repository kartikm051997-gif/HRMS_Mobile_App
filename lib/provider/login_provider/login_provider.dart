
import 'package:flutter/material.dart';

import '../../presentaion/pages/dashboradScreens/dashboard_screen.dart';


class LoginProvider extends ChangeNotifier{
//controller for textfield
  final emailcontroller=TextEditingController();
  final passwordcontroller=TextEditingController();
  bool _isloading=false;
  bool get isloading=>_isloading;
//login function
  void login(BuildContext context)async{
    if(emailcontroller.text.isEmpty || passwordcontroller.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("please fill all fields")));
      return;
    }
    _isloading=true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _isloading=false;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("login successfull")));
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DashboardScreen()));


  }
  @override
  void dispose(){
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();

  }


}