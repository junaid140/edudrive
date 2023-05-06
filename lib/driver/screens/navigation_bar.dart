import 'package:edudrive/driver/providers/driver_provider.dart';
import 'package:edudrive/driver/screens/schedule_booking_screen.dart';
import 'package:edudrive/driver/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../res/app_color/app_color.dart';
import '../res/font_assets/font_assets.dart';
import '../../driver/services/fcmServices/firebase_messaging.dart';
import '../../driver/services/fcmServices/notifications.dart';
import '../../driver/widgets/app_drawer.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'ratings_screen.dart';
import 'earnings_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);
  static const routeName = '/nav-bar';

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();

  int selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> _pages = [
    HomeScreen(),
    EarningsScreen(),
    ScheduleBookingScreen(),
    ProfileScreen(),
  ];
  String titleText='';
  setTitle(){
    if(selectedIndex==0){
      this.titleText="EduDrive";
    }else if(selectedIndex==1){
      this.titleText="Earning";
    }else if(selectedIndex==2){
      this.titleText="Schedule Book";
    }else{
      this.titleText="Profile Screen";
    }
  }
  Future<void> _loadData(BuildContext context, ) async {
   await Provider.of<DriverProvider>(context, listen: false).fetchDriverDetails();
   // await Provider.of<MapsProvider>(context, listen: false).locatePosition();
  }

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      setTitle();
      _pageController.animateToPage(
        selectedIndex,
        duration: Duration(microseconds: 160),
        curve: Curves.bounceIn,
      );
    });
  }
  firebaseMessaging(){

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if(notification != null){
        if(message.data["type"]=="1") {
          PushNotificationServices().retrieveClientRequestData(
              PushNotificationServices().getClientRequestId(message.data),
              context);
        }

        else{
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  color: Colors.blue,
                  playSound: true,
                  icon: '@mipmap/ic_launcher',
                ),
                iOS: DarwinNotificationDetails(
                    presentSound: true, subtitle: notification.body),
              ));
        }
        // Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> Artist_Menu(),));


      }
    });

    FirebaseMessaging.onBackgroundMessage((message) async{
      print(message.data);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if(notification != null){
        if(message.data["type"]=="1") {
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
                    subtitle: notification.body
                ),
              ));
          PushNotificationServices().retrieveClientRequestData(
              PushNotificationServices().getClientRequestId(message.data),
              context);
        }
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
                  subtitle: notification.body
              ),
            ));


      }
    });
    FirebaseMessaging.instance.subscribeToTopic("allDrivers");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.data);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if(notification != null){

        if(message.data["type"]=="1") {
          PushNotificationServices().retrieveClientRequestData(
              PushNotificationServices().getClientRequestId(message.data),
              context);
        }
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
                  subtitle: notification.body
              ),
            ));

      }
      // else{
      //   flutterLocalNotificationsPlugin.show(
      //       notification.hashCode,
      //       notification!.title,
      //       notificationDescription,
      //
      //       // notification.body,
      //       NotificationDetails(
      //         android: AndroidNotificationDetails(
      //           channel.id,
      //           channel.name,
      //           channelDescription:
      //           channel.description,
      //           color: Colors.blue,
      //           playSound: true,
      //           icon: '@mipmap/ic_launcher',
      //         ),
      //         iOS: DarwinNotificationDetails(
      //             presentSound: true,
      //             subtitle: notification.body
      //         ),
      //       ));
      // }
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if(message==null){

      }
      else{
        print(message!.data);
        RemoteNotification? notification = message!.notification;
        AndroidNotification? android = message.notification?.android;
        if(notification != null){
          if(message.data["type"]==1){
            flutterLocalNotificationsPlugin.show(
                notification.hashCode,
                notification.title,
                notificationDescription,

                // notification.body,
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
            PushNotificationServices().retrieveClientRequestData(
                PushNotificationServices().getClientRequestId(message.data),
                context);
          }
          else{
            flutterLocalNotificationsPlugin.show(
                notification.hashCode,
                notification.title,
                notificationDescription,

                // notification.body,
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    channelDescription: channel.description,
                    color: Colors.blue,
                    playSound: true,
                    icon: '@mipmap/ic_launcher',
                  ),
                  iOS: DarwinNotificationDetails(
                      presentSound: true, subtitle: notification.body),
                ));
          }

          final routeFromMessage = message.data["route"];

          // Navigator.of(context).pushNamed(routeFromMessage);
        }
      }

    });


  }
  String? notificationTitle, notificationDescription;
  // indexcontrollar cntrl = Get.put(indexcontrollar());

  updateFCM()async{
    await FirestoreServices().updateFCMToken();
  }
  @override
  void initState() {
    setTitle();
    _loadData(context,);
    Notifications().init();
    updateFCM();
    firebaseMessaging();

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void _openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu,color: AppColor.whiteColor,size: 24,),
          onPressed: _openDrawer,
        ),
        centerTitle: true,
        elevation: 5,
        title: Text(
          titleText,
          style: FontAssets.largeText.copyWith(fontWeight: FontWeight.w700,fontSize: 24,color: AppColor.whiteColor),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (int index) => onItemClicked(index),
        children: _pages.map((page) => page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        unselectedItemColor:
            Theme.of(context).primaryColorLight.withOpacity(0.5),
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: (int index) => onItemClicked(index),
      ),
    );
  }
}