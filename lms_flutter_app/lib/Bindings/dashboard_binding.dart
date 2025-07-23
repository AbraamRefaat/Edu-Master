// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:lms_flutter_app/Controller/account_controller.dart';
import 'package:lms_flutter_app/Controller/account_page_controller.dart';
import 'package:lms_flutter_app/Controller/cart_controller.dart';
import 'package:lms_flutter_app/Controller/dashboard_controller.dart';
import 'package:lms_flutter_app/Controller/home_controller.dart';
import 'package:lms_flutter_app/Controller/quiz_controller.dart';
import 'package:lms_flutter_app/Service/language_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize language service as a service
    Get.put<LanguageService>(LanguageService(), permanent: true);
    // SiteController is already initialized in main()
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AccountController>(() => AccountController());
    Get.lazyPut<AccountPageController>(() => AccountPageController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<QuizController>(() => QuizController()); // Add QuizController
  }
}
