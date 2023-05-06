import 'package:edudrive/providers/user_provider.dart';
import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/view/screens/live_location.dart';
import 'package:edudrive/view/screens/schedule_book.dart';
import 'package:edudrive/view/screens/user_details.dart';
import 'package:edudrive/view/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../main.dart';
import '../../services/fcmServices/firebase_messaging.dart';
import '../../services/fcmServices/notifications.dart';
import '../../services/firestore_services.dart';
import 'instant_pickup_screen.dart';


class DashboardScreen extends StatefulWidget {
  int currentIndex;
   DashboardScreen({Key? key, this.currentIndex = 0}) : super(key: key);

  static const routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // int currentIndex=0;
  String titleText='';
  setTitle(){
    if(widget.currentIndex==0){
      this.titleText="EduDrive";
    }else if(widget.currentIndex==1){
    this.titleText="Instant Book";
    }else{
      this.titleText="Schedule Book";
    }
  }
  Future<void> _loadData(BuildContext context, ) async {
    await Provider.of<UserProvider>(context, listen: false).fetchUserDetails();
    // await Provider.of<MapsProvider>(context, listen: false).locatePosition();
  }
  firebaseMessaging(){

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if(notification != null){
        PushNotificationServices().retrieveClientRequestData(
            PushNotificationServices().getClientRequestId(message.data), context);

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
        // Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> Artist_Menu(),));


      }
    });

    FirebaseMessaging.onBackgroundMessage((message) async{
      print(message.data);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
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
                  subtitle: notification.body
              ),
            ));
        PushNotificationServices().retrieveClientRequestData(
            PushNotificationServices().getClientRequestId(message.data), context);

      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.data);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
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
                  subtitle: notification.body
              ),
            ));
        PushNotificationServices().retrieveClientRequestData(
            PushNotificationServices().getClientRequestId(message.data), context);
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      // print(message!.data);
      RemoteNotification? notification = message!.notification;
      AndroidNotification? android = message.notification?.android;
      if(notification != null){

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

        final routeFromMessage = message.data["route"];

        // Navigator.of(context).pushNamed(routeFromMessage);
      }
    });


  }
  String? notificationTitle, notificationDescription;

  updateFCM()async{
    await FirestoreServices().updateFCMToken();

  }
  @override
  void initState() {
    _loadData(context);
    setTitle();
    Notifications().init();
    updateFCM();
    firebaseMessaging();

    // TODO: implement initState
    super.initState();
  }


  List currentPage=[
    UserDetails(),
    InstantPickUpScreen(),
   ScheduleBook(),
  ];

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
      body: currentPage[widget.currentIndex],
      bottomNavigationBar:
        Container(
          decoration: BoxDecoration(
            color: AppColor.whiteColor
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Row (
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap:()=> setState(() {
                  widget.currentIndex=0;
                  setTitle();
                }),
                child: CircleAvatar(
                  radius: 20,
                    backgroundColor: widget.currentIndex==0?AppColor.primaryButtonColor:AppColor.whiteColor,

                  child: Icon(Icons.home_outlined,
                  size: 30,
                  color: widget.currentIndex==0?AppColor.whiteColor:AppColor.primaryButtonColor),

                ),
              ),
              GestureDetector(
                onTap:()=> setState(() {
                  widget.currentIndex=1;
                  setTitle();
                }),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: widget.currentIndex==1?AppColor.primaryButtonColor:AppColor.whiteColor,
                  child: Icon(Icons.location_on,
                  size: 30,
                  color: widget.currentIndex==1?AppColor.whiteColor:AppColor.primaryButtonColor),

                ),
              ),
              GestureDetector(
                onTap:()=> setState(() {
                  widget.currentIndex=2;
                  setTitle();
                }),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: widget.currentIndex==2?AppColor.primaryButtonColor:AppColor.whiteColor,
                  child: Icon(Icons.calendar_month,
                  size: 30,
                  color: widget.currentIndex==2?AppColor.whiteColor:AppColor.primaryButtonColor),

                ),
              ),
            ],
          ),
        )
    );
  }
}




class TitleText extends StatelessWidget {

  String title;

  TitleText({Key? key,
  required this.title
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(title,
      style: FontAssets.largeText.copyWith(
        color: AppColor.whiteColor,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
