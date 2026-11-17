import 'dart:io';

import 'package:carbo/views/dashboard/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'base/maintenance/maintenance_dialog.dart';
import 'base/services/location_service.dart';
import 'base/utils/basic_import.dart';
import 'initializer.dart';
import 'languages/app_translations.dart';
import 'languages/locale_service.dart';
import 'routes/routes.dart';

void main() async {
    HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();
  
  // Enable mock location for testing distance sorting on emulator (Jeddah coordinates)
  // LocationService().setMockLocation(21.5474812, 39.2046468); // فرع السبعين
  LocationService().setMockLocation(21.56551597, 39.21182576); // الاربعين
  
  // Check if app was opened from a notification action
  final initialAction = await AwesomeNotifications().getInitialNotificationAction(
    removeFromActionEvents: true,
  );
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  runApp(MyApp(initialNotificationAction: initialAction));
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
class MyApp extends StatelessWidget {
  // Global navigator key for navigating from static methods
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  final ReceivedAction? initialNotificationAction;
  
  const MyApp({super.key, this.initialNotificationAction});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      designSize: const Size(375, 812),
      builder: (_, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // Add navigator key for static navigation
        initialRoute: Routes.splashScreen,
        title: Strings.appName,
        theme: Themes.light,
        darkTheme: Themes.dark,
        getPages: Routes.list,
        themeMode: ThemeMode.light,
        // Localization configuration
        translations: AppTranslations(),
        locale: LocaleService.to.currentLocale,
        fallbackLocale: const Locale('en'),
        supportedLocales: LanguageConfig.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialBinding: BindingsBuilder(() {
          Get.put(SystemMaintenanceController());
          Get.put(DashboardController());
        }),
        builder: (context, widget) {
          ScreenUtil.init(context);
          return Obx(
            () => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: Directionality(
                textDirection: LocaleService.to.textDirection,
                child: widget!,
              ),
            ),
          );
        },
      ),
    );
  }
}
