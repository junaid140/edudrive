import 'package:edudrive/res/app_color/app_color.dart';
import 'package:flutter/material.dart';

class NoDriverAvailableDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Finding Driver",
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .width / 22,
                      height: 1.2,
                      fontFamily: "Poppins"
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "No Available Driver founded in the nearby, we suggest you try again shortly",
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: MediaQuery
                            .of(context)
                            .size
                            .width / 30,
                        height: 1.2,
                        fontFamily: "Poppins"
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (){

                    // Navigator.pop(context);
                    // Navigator.pop(context);

                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 46,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30,right: 50),
                          child: Icon(Icons.repeat_one,color: Colors.white,),
                        ),

                        Text(
                          "Close",
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 20,
                              height: 1.2,
                              fontFamily: "Poppins"
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryButtonColor,
                      border: Border.all(
                        width: 2,
                        color: AppColor.primaryButtonColor
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                  ),
                ),
              ],
            ) ,
          ),
        ),
      ),
    );
  }
}
