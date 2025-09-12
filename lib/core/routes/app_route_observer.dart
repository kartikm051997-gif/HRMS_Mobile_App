import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../controller/ui_controller/appbar_controllers.dart';

class AppRouteObserver extends GetObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    _updateSelectedPage(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _updateSelectedPage(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _updateSelectedPage(previousRoute);
  }

  void _updateSelectedPage(Route? route) {
    final AppBarController controller = Get.find();
    if (route != null && route.settings.name != null) {
      controller.selectedPage.value = route.settings.name!;
    }
  }
}
