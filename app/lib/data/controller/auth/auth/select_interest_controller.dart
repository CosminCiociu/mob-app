import 'package:get/get.dart';

class SelectInterestController extends GetxController {
  List<Map<String, dynamic>> interests = [
    {'name': 'Photography', 'image': 'assets/images/select_interests/camera-retro.svg', 'status': false},
    {'name': 'Traveling', 'image': 'assets/images/select_interests/plane.svg', 'status': false},
    {'name': 'Gaming', 'image': 'assets/images/select_interests/gamepad.svg', 'status': false},
    {'name': 'Cooking', 'image': 'assets/images/select_interests/hat-chef.svg', 'status': false},
    {'name': 'Music', 'image': 'assets/images/select_interests/music-alt.svg', 'status': false},
    {'name': 'Reading', 'image': 'assets/images/select_interests/book-alt.svg', 'status': false},
    {'name': 'Fitness', 'image': 'assets/images/select_interests/dumbbell-fitness.svg', 'status': false},
    {'name': 'Art', 'image': 'assets/images/select_interests/palette.svg', 'status': false},
    {'name': 'Technology', 'image': 'assets/images/select_interests/microchip.svg', 'status': false},
    {'name': 'Fashion', 'image': 'assets/images/select_interests/lab-coat.svg', 'status': false},
  ];
  tappedStatus(int i) {
    interests[i]['status'] = !interests[i]['status'];
    update();
  }
}
