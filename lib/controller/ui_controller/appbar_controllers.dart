import 'package:get/get.dart';

class AppBarController extends GetxController {
  var selectedPage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectedPage.value = Get.currentRoute;
  }
}
