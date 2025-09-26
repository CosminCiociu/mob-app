import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  bool isLoading = true;


  List<Map<String, String>> notifications = [
    {
    "image":MyImages.girl1,
    'notification':"Ketty like your photo",
    'time':"10 min ago",
  },
    {
    "image":MyImages.girl2, 
    'notification':"Merry like your photo",
    'time':"20 min ago",
  },
    {
    "image":MyImages.boySmile,
    'notification':"John comment your photo",
    'time':"45 min ago",
  },
     {
    "image":MyImages.girl2, 
    'notification':"Merry like your photo",
    'time':"20 min ago",
  },
   {
    "image":MyImages.boySmile,
    'notification':"John comment your photo",
    'time':"45 min ago",
  },
     {
    "image":MyImages.girl1,
    'notification':"Ketty like your photo",
    'time':"10 min ago",
  },
    {
    "image":MyImages.girl2, 
    'notification':"Merry like your photo",
    'time':"20 min ago",
  },
  ];
}
