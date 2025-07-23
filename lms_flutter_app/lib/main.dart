// Flutter imports:

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:connection_notifier/connection_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';

// Package imports:
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lms_flutter_app/Config/app_config.dart';
import 'package:lms_flutter_app/Model/Settings/Settings.dart';
import 'package:lms_flutter_app/Service/iap_service.dart';
import 'package:lms_flutter_app/Service/language_service.dart';
import 'package:lms_flutter_app/Views/SplashScreen.dart';
import 'package:lms_flutter_app/firebase_options.dart';
import 'package:lms_flutter_app/utils/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lms_flutter_app/Controller/site_controller.dart';

import 'Bindings/dashboard_binding.dart';
import 'Config/themes.dart';
import 'Service/theme_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lms_flutter_app/utils/translation_helper.dart';

class MyHttpoverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  await GetStorage.init();
  HttpOverrides.global = new MyHttpoverrides();

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize LanguageService and wait for it to complete
  final languageService = LanguageService();
  await languageService.init();
  Get.put(languageService);

  // Initialize SiteController early since it's used globally
  Get.put(SiteController(), permanent: true);

  setupNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Stripe.publishableKey = stripePublishableKey;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (Platform.isIOS || Platform.isMacOS) {
    StoreConfig(
      store: Store.appleStore,
      apiKey: apiIosRevenueKey,
    );
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(RestartApp(child: new MyApp()));
  });

  fetchSetting().then((value) {
    if (value != null && value['data'] != null) {
      appCurrency = value['data']['currency_symbol'] ?? '';
    }
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    // Get language service - it should already be initialized from main()
    final LanguageService languageService = Get.find();

    return ConnectionNotifier(
      child: Obx(
        () {
          // Ensure we have a valid locale before rendering
          String currentLocale = languageService.appLocale.value.isNotEmpty
              ? languageService.appLocale.value
              : 'en';

          return GetMaterialApp(
            translations: AppTranslations(),
            locale: Locale(currentLocale),
            fallbackLocale: Locale(languageService.fallbackLocale),
            // Explicitly set text direction based on language
            builder: (BuildContext context, Widget? child) {
              // Force text direction update based on current language
              return Directionality(
                textDirection: languageService.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageService.supportedLanguages.keys
                .map((lang) => Locale(lang))
                .toList(),
            title: '$companyName',
            debugShowCheckedModeBanner: false,
            theme: Themes.light,
            darkTheme: Themes.dark,
            themeMode: ThemeService().theme,
            home: FutureBuilder(
                future: _initialization,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Text(
                          snapshot.error.toString(),
                        ),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Scaffold(
                      body: SplashScreen(),
                    );
                  }
                  return CircularProgressIndicator();
                }),
            initialBinding: DashboardBinding(),
          );
        },
      ),
    );
  }
}

class AppTranslations extends Translations {
  final languageService = Get.find<LanguageService>();

  @override
  Map<String, Map<String, String>> get keys => {
        'en': languageService.en,
        'ar': languageService.ar,
      };
}

void setupNotification() {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/notification_icon',
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic group',
        )
      ],
      debug: true);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!AwesomeStringUtils.isNullOrEmpty(message.notification?.title,
          considerWhiteSpaceAsEmpty: true) ||
      !AwesomeStringUtils.isNullOrEmpty(message.notification?.body,
          considerWhiteSpaceAsEmpty: true)) {
    String? imageUrl;
    imageUrl ??= message.notification?.android?.imageUrl ?? '';

    Map<String, dynamic> notificationAdapter = {
      NOTIFICATION_CHANNEL_KEY: 'basic_channel',
      NOTIFICATION_ID: message.data[NOTIFICATION_CONTENT][NOTIFICATION_ID] ??
          message.messageId ??
          math.Random().nextInt(2147483647),
      NOTIFICATION_TITLE: message.data[NOTIFICATION_CONTENT]
              [NOTIFICATION_TITLE] ??
          message.notification?.title,
      NOTIFICATION_BODY: message.data[NOTIFICATION_CONTENT]
              [NOTIFICATION_BODY] ??
          message.notification?.body,
      NOTIFICATION_LAYOUT:
          AwesomeStringUtils.isNullOrEmpty(imageUrl) ? 'Default' : 'BigPicture',
      NOTIFICATION_BIG_PICTURE: imageUrl
    };

    AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
  } else {
    AwesomeNotifications().createNotificationFromJsonData(message.data);
  }
}

Future fetchSetting() async {
  Uri url = Uri.parse(baseUrl + "/settings");
  var response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    var jsonString = jsonDecode(response.body);
    return jsonString;
  } else {
    return null;
  }
}
