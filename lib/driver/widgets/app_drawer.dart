import 'package:edudrive/driver/providers/driver_provider.dart';
import 'package:edudrive/driver/screens/history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import '../../view/screens/account_type_screen.dart';
import '../res/app_color/app_color.dart';
import '../res/font_assets/font_assets.dart';
import '../screens/auth_screen.dart';
import '../screens/update_profile_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<DriverProvider>(context, listen: false);
    final username = userData.name;
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          height: MediaQuery.of(context).size.height*0.85,
          width: MediaQuery.of(context).size.width*0.8,
          decoration: BoxDecoration(
            color: AppColor.backgroundColor,
            borderRadius: BorderRadius.only(
              bottomLeft:Radius.circular(30),
                bottomRight: Radius.circular(30)
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0,4),
                blurRadius: 4,
                color: AppColor.primaryIconColor.withOpacity(0.25),
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                onTap: (){
                  Navigator.pop(context);
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>UpdateProfileScreen()));
                },
                leading: Image.asset("assets/images/user_icon.png",height: 50,),

                title:  Text(
                  "$username",
                  style: FontAssets.mediumText.copyWith(
                      color: AppColor.whiteColor
                  ),
                ),
                subtitle: Text(
                  'View Profile',
                  style: FontAssets.smallText.copyWith(
                      color: AppColor.whiteColor
                  ),
                ),
                trailing: Padding(padding: EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: ()=>Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            // BoxShadow(
                            //   offset: Offset(2,2),
                            //   blurRadius: 10,
                            //   color:AppColor.primaryIconColor.withOpacity(0.6)
                            // ),
                            BoxShadow(
                                offset: Offset(-4,-4),
                                blurRadius: 12,
                                color: Color(0xffBBC3CE).withOpacity(0.6)
                            )
                          ]
                      ),
                      child: Center(child: Icon(Icons.cancel_sharp,color: Color(0xffC30F0F),),),
                    ),
                  ),),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Home',
                        style: FontAssets.mediumText.copyWith(
                            color: AppColor.whiteColor
                        ),
                      ),
                      onTap: () {

                      },
                    ),
                    ListTile(
                      title: Text(
                        'History',
                        style: FontAssets.mediumText.copyWith(
                            color: AppColor.whiteColor
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder:(context)=>History()));
                      },
                    ),
                    // ListTile(
                    //   title: Text(
                    //     'Complains',
                    //     style: FontAssets.mediumText.copyWith(
                    //         color: AppColor.whiteColor
                    //     ),
                    //   ),
                    //   onTap: () {
                    //
                    //     Navigator.pop(context);
                    //     // Navigator.push(context, MaterialPageRoute(builder:(context)=>ComplainScreen()));
                    //   },
                    // ),

                    SizedBox(height: MediaQuery.of(context).size.height*0.22,),
                    ListTile(
                      leading: Icon(Icons.power_settings_new,color: Colors.red,),
                      minLeadingWidth: 0,
                      title: Text(
                        'Sign Out',
                        style: FontAssets.mediumText.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      onTap: ()async {

                        await Provider.of<Auth>(
                          context,
                          listen: false,
                        ).logout();
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, AccountTypeScreen.routeName);

                      },
                    ),
                    Row(
                      children: [
                        SizedBox(width: 20,),
                        Text("Version 1.0.0",style: FontAssets.smallText.copyWith(
                          color: AppColor.whiteColor
                        ),),
                      ],
                    ),

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
