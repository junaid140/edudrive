import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/driver/screens/auth_screen.dart';
import 'package:edudrive/driver/screens/update_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/maps_provider.dart';
import '../providers/driver_provider.dart';

import 'all_cars_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const routeName = '/profile-screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _loadData(BuildContext context, ) async {
    await Provider.of<DriverProvider>(context, listen: false).fetchDriverDetails();
    // await Provider.of<MapsProvider>(context, listen: false).locatePosition();
  }
  @override
  void initState() {
    _loadData(context);
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // final driverData = Provider.of<DriverProvider>(context, listen: false);
    // final driver = driverData.driver;
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: (){},
      //     icon: Icon(Icons.menu,color: Colors.white,),
      //   ),
      //   centerTitle: true,
      //   title: Text("Profile Screen",style: TextStyle(
      //       fontSize: 20,
      //       fontWeight: FontWeight.bold
      //   ),),
      // ),

      body: SafeArea(
        child: Consumer<DriverProvider>(
          builder: (ctx, driver, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Theme.of(context).primaryColorDark.withOpacity(0.6),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  title: Center(
                    child: Text(
                      "Wallet Balance",
                      style:FontAssets.largeText.copyWith(color: AppColor.whiteColor)
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "\$ ${double.parse(driver.wallet).toStringAsFixed(2)}",
                        style: FontAssets.mediumText.copyWith(color: AppColor.whiteColor),
                      ),
                    ),
                  ),

                ),
                SizedBox(height: 20),

                ListTile(

                  onTap: () {
                    print('View Profile');
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>UpdateProfileScreen()));

                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Theme.of(context).primaryColorDark.withOpacity(0.6),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  leading: Image.asset('assets/images/user_icon.png',),
                  title: Text(
                    driver.name,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  subtitle: Text(
                    driver.mobile.toString(),
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  trailing: Icon(
                    Icons.edit,
                    color: Color(0xffB8AAA3),
                  ),
                ),

                SizedBox(height: 40),
                Divider(color: Color(0xff6D5D54)),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    Icons.money,
                    color: Color(0xff6D5D54),
                  ),
                  title: Text(
                    'View Cars',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AllCarsScreen.routeName);
                  },
                ),


                Divider(color: Color(0xff6D5D54)),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    Icons.history,
                    color: Color(0xff6D5D54),
                  ),
                  title: Text(
                    'History',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  onTap: () {
                    // Navigator.of(context).pushNamed(HistoryScreen.routeName);
                  },
                ),
                Divider(color: Color(0xff6D5D54)),
                Expanded(child: Container()),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    Icons.logout,
                    color: Color(0xff6D5D54),
                  ),
                  title: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  onTap: () async {
                    await Provider.of<MapsProvider1>(
                      context,
                      listen: false,
                    ).goOffline();
                    await Provider.of<Auth>(
                      context,
                      listen: false,
                    ).logout();

                    Navigator.pushNamed(context, AuthScreen.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
