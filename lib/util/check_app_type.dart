import 'package:flutter/foundation.dart';
import 'package:flutter_error_report/model/app_type_enum.dart';

class CheckAppType{
 static AppType checkAppType (){
   if(kDebugMode){
     return AppType.debug;
   }else if(kProfileMode){
     return AppType.profile;
   }else {
     return AppType.release;
   }
 }
}