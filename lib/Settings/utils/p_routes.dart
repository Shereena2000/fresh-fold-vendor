import 'package:flutter/material.dart';
import 'package:fresh_fold_shop_keeper/Features/auth/view/sigin.dart';
import 'package:fresh_fold_shop_keeper/Features/auth/view/sign_up.dart';
import 'package:fresh_fold_shop_keeper/Features/order_detial/view/ui.dart';
import 'package:fresh_fold_shop_keeper/Features/order_mangement/model/shedule_model.dart';
import 'package:fresh_fold_shop_keeper/Features/wrapper/view/ui.dart';

import '../../Features/splash/view/splash_screen.dart';
import 'p_pages.dart';

class Routes {
  static Route<dynamic>? genericRoute(RouteSettings settings) {
    switch (settings.name) {
      case PPages.splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case PPages.signUp:
        return MaterialPageRoute(builder: (context) => SignUpScreen());
      case PPages.login:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case PPages.wrapperPageUi:
        return MaterialPageRoute(builder: (context) => WrapperScreen());
      case PPages.orderDetailPageUi:
        return MaterialPageRoute(
          builder: (context) =>
              OrderDetailScreen(schedule: settings.arguments as ScheduleModel),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Page Not Found')),
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }
}
