import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/providers/ride_provider.dart';
import 'package:edudrive/providers/user_provider.dart';
import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/driver/screens/create_schedule_book.dart';
import 'package:edudrive/driver/screens/schedule_booking_screen.dart';
import 'package:edudrive/services/fcmServices/firebase_messaging.dart';
import 'package:edudrive/view/screens/account_type_screen.dart';
import 'package:edudrive/view/screens/auth_screen.dart';
import 'package:edudrive/view/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'driver/providers/auth.dart';
import 'driver/providers/maps_provider.dart';
import 'providers/auth.dart' as parentAuth;
import 'providers/maps_provider.dart';
import 'driver/providers/driver_provider.dart';
import 'package:edudrive/driver/screens/navigation_bar.dart' as nav;
import 'driver/screens/auth_screen.dart';
import 'driver/screens/home_screen.dart';
import 'driver/screens/splash_screen.dart';
import 'driver/screens/profile_screen.dart';
import 'driver/screens/ratings_screen.dart';
import 'driver/screens/all_cars_screen.dart';
import 'driver/screens/earnings_screen.dart';
import 'driver/screens/car_info_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'view/screens/dashboard_screen.dart';
import 'view/screens/instant_pickup_screen.dart';
import 'view/screens/search_screen.dart';
import 'view/screens/sign_up_with_phone.dart';



Future<void> backgroundHandler(RemoteMessage message) async{
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  AppleNotification? apple = message.notification?.apple;
  if(notification != null){
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription:
            channel.description,
            color: Colors.blue,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentSound: true,
            subtitle: message.notification!.body,
          ),
        ));
    print("Notification Received");
  }

  print(message.data.toString());
  print(message.notification!.title);
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notification', description: 'This is channek used for important notification',
    importance: Importance.max, playSound: true
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  //fcm
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  FirebaseMessaging.onMessage.listen((message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification!.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription:
            channel.description,
            color: Colors.blue,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
              presentSound: true,
              subtitle: notification.body
          ),
        ));
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification!.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription:
            channel.description,
            color: Colors.blue,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
              presentSound: true,
              subtitle: notification.body
          ),
        ));
    // PushNotificationServices().retrieveClientRequestData(
    //     PushNotificationServices().getClientRequestId(message.data), context);

  });

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later


  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload != null) {
        debugPrint('notification payload: ${notificationResponse.payload}');
      }    },
  );
  onSelectNotification: (String payload) async {


  };

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  runApp(MyApp());
}
CollectionReference<Map<String,dynamic>> rideRequestRef= FirebaseFirestore.instance.collection("rideRequest");
DocumentReference<Map<String,dynamic>> driverRef= FirebaseFirestore.instance.collection("driver").doc(FirebaseAuth.instance.currentUser!.uid);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: parentAuth.Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, DriverProvider>(
          create: (_) => DriverProvider(),
          update: (_, auth, driverData) => driverData!..update(auth),
        ),ChangeNotifierProxyProvider<parentAuth.Auth, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, auth, driverData) => driverData!..update(auth),
        ),
        ChangeNotifierProvider.value(
          value: MapsProvider(),
        ),
        ChangeNotifierProxyProvider2<parentAuth.Auth, UserProvider, RideProvider>(
          create: (_) => RideProvider(),
          update: (_, auth, userData, rideData) =>
          rideData!..update(auth, userData),
        ),
        ChangeNotifierProxyProvider<DriverProvider, MapsProvider1>(
          create: (_) => MapsProvider1(),
          update: (_, driver, mapsData) => mapsData!..update(driver),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => Consumer<DriverProvider>(
          builder: (ctx, driver, _) => MaterialApp(
            title: 'EduDrive App',
            debugShowCheckedModeBanner: false,
            theme: themeData,
            home: SplashScreen(),
            routes: routes,
          ),
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> get routes {
    return {
      SplashScreen.routeName: (ctx) => SplashScreen(),
      AuthScreen.routeName: (ctx) => AuthScreen(),
      AuthScreen1.routeName: (ctx) => AuthScreen1(),
      CarInfoScreen.routeName: (ctx) => CarInfoScreen(),
      nav.BottomBar.routeName: (ctx) => nav.BottomBar(),
      HomeScreen.routeName: (ctx) => HomeScreen(),
      AccountTypeScreen.routeName: (ctx) => AccountTypeScreen(),
      ScheduleBookingScreen.routeName: (ctx) => ScheduleBookingScreen(),
      EarningsScreen.routeName: (ctx) => EarningsScreen(),
      RatingsScreen.routeName: (ctx) => RatingsScreen(),
      ProfileScreen.routeName: (ctx) => ProfileScreen(),
      AllCarsScreen.routeName: (ctx) => AllCarsScreen(),
      CreateScheduleBookScreen.routeName: (ctx) => CreateScheduleBookScreen(),
      SplashScreen.routeName: (ctx) => SplashScreen(),
      AuthScreen.routeName: (ctx) => AuthScreen(),
      InstantPickUpScreen.routeName: (ctx) => InstantPickUpScreen(),
      SearchScreen.routeName: (ctx) => SearchScreen(),
      DashboardScreen.routeName: (ctx) => DashboardScreen(),
      SignUpWithPhone.routeName: (ctx) => SignUpWithPhone(),
    };
  }
}

final themeData = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColor.whiteColor,
  scaffoldBackgroundColor: AppColor.scaffoldBackgroundColor,
  dialogBackgroundColor: AppColor.scaffoldBackgroundColor,

  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 14,
      color: AppColor.whiteColor,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: TextStyle(
      fontSize: 14,
      color: Color(0xff6D5D54),
      fontWeight: FontWeight.w500,
    ),
    displaySmall: TextStyle(
      color: Color(0xffB8AAA3),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),

    headlineMedium: TextStyle(
      fontSize: 20,
      color: Color(0xffD1793F),
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      color: Color(0xffFBFAF9),
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      color: AppColor.whiteColor,
      fontSize: 20,
    ),
    bodyMedium: TextStyle(
      color: AppColor.whiteColor,
      fontSize: 14,
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColor.blackColor,
    iconTheme: IconThemeData(
      color: AppColor.whiteColor,
    ),
  ),
  colorScheme:
  ColorScheme.fromSwatch().copyWith(
    background:Color(0xffffffff) ,
    secondary: AppColor.blackColor,
  ),
);
