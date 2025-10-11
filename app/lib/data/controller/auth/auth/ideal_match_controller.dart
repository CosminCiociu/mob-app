import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:get/get.dart';

class IdealMatchController extends GetxController {
  List<Map<String, dynamic>> idealMatch = [
    {
      'name': 'Love',
      'subTitle': 'You\'re not here to play around',
      'image': MyImages.heart,
      'status': false
    },
    {
      'name': 'Friends',
      'subTitle': 'I want to meet new people',
      'image': MyImages.friends,
      'status': false
    },
    {
      'name': 'Business',
      'subTitle': 'Meet business oriented people',
      'image': MyImages.business,
      'status': false
    },
  ];
  changeTapStatus(int i) {
    idealMatch[i]['status'] = !idealMatch[i]['status'];
    update();
  }
}
