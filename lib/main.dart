
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_mobile_app/presentaion/page_not_found/page_not_found.dart';
import 'package:hrms_mobile_app/presentaion/pages/login/login_provider.dart';
import 'package:hrms_mobile_app/presentaion/pages/login/login_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/splash_screen/splash_screen.dart';

import 'package:provider/provider.dart';

import 'controller/ui_controller/appbar_controllers.dart';
import 'core/routes/app_route_observer.dart';
import 'core/routes/routes.dart';
import 'core/utils/helper_utils.dart';

void main() async {
  runApp(const MyApp());
  Get.lazyPut<AppBarController>(() => AppBarController());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CRM DraivF',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
          ),
        ),

        navigatorObservers: [AppRouteObserver()],
        initialRoute: "/splashscreen",
        onGenerateRoute: (settings) {
          String routeName = settings.name ?? '';
          routeName = HelperUtil.normalizeUrl(routeName);

          if (HelperUtil.isValidStaticRoute(routeName)) {
            return GetPageRoute(
              settings: settings,
              page: () => _getStaticPage(routeName),
            );
          }

          return GetPageRoute(
            settings: settings,
            page: () => const NotFoundPage(),

          );
        },
      ),
    );
  }

  Widget _getStaticPage(String routeName) {
    switch (routeName) {
      case AppRoutes.splashScreen:
        return SplashScreen();
      case AppRoutes.loginScreen:
        return LoginScreen();
      default:
        return const NotFoundPage();

    }
  }
}
