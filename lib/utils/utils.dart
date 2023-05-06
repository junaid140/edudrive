import 'package:fluttertoast/fluttertoast.dart';

class Utils{
  toastMessage(String msg){
    Fluttertoast.showToast(msg: msg);
  }
}