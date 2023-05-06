import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/view/widgets/chat_text_widget.dart';
import 'package:flutter/material.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController=TextEditingController();
  @override
  void dispose() {
    messageController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title:Text("Chat with Driver"),
        leading: IconButton(
          icon:Icon(Icons.arrow_back),
          onPressed: ()=>Navigator.pop(context),
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30,0,30,10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              flex: 10,
              child: Container(
                // height:MediaQuery.of(context).size.height*0.8,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text("1 Feb 2022 03:40 pm",
                          style: FontAssets.base.copyWith(
                            color: AppColor.primaryButtonColor,
                            fontSize: 11,
                          ),),
                      ),
                      ChatTextWidget(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed",  user: true),
                      ChatTextWidget(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed",  user: false),
                      ChatTextWidget(text: "Lorem ipsum dolor sit ",  user: true),
                      ChatTextWidget(text: "Lorem ipsum",  user: false),
                      ChatTextWidget(text: "?",  user: true),
                      ChatTextWidget(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed ",  user: false),
                      ChatTextWidget(text: "Lorem ipsum dolor sit ",  user: true),
                      ChatTextWidget(text: "Lorem ipsum",  user: false),
                      ChatTextWidget(text: "?",  user: true),
                      // Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width*0.8,
              child: TextFormField(
                style: FontAssets.mediumText.copyWith(color: AppColor.whiteColor),
                controller: messageController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor:Color(0xff6E6E6E).withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.arrow_forward_ios,color: AppColor.whiteColor,),
                      onPressed: (){

                      },
                    )
                ),
              ),
            )

          ],
         ),
      ),
    );
  }
}