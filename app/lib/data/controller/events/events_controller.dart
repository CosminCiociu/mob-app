import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/services/location_service.dart';
import 'package:ovo_meet/view/components/snack_bar/show_custom_snackbar.dart';

class EventsController extends GetxController {
  // =========================
  // STATE VARIABLES
  // =========================

  /// Loading states
  bool isSubmitLoading = false;
  bool isLoading = false;
  bool isRepeatEvent = false;

  /// Form data
  String eventImagePath = '';
  String selectedTimezone = MyStrings.selectTimezone;
  String timezoneLabel = MyStrings.selectTimezone;
  String? selectedCategoryId;
  String? selectedSubcategoryId;

  /// Controllers and focus nodes
  TextEditingController eventNameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();

  FocusNode eventNameFocusNode = FocusNode();
  FocusNode detailsFocusNode = FocusNode();
  FocusNode dateTimeFocusNode = FocusNode();

  /// Data storage
  File? imageFile;
  List<Map<String, dynamic>> userEvents = [];

  // =========================
  // GETTERS & VALIDATORS
  // =========================

  /// Form validation getter (checks if required fields are filled)
  bool get isFormValid {
    return eventNameController.text.trim().isNotEmpty &&
        dateTimeController.text.trim().isNotEmpty &&
        selectedCategoryId != null &&
        selectedSubcategoryId != null &&
        detailsController.text.trim().isNotEmpty;
  }

  // =========================
  // LIFECYCLE METHODS
  // =========================

  @override
  void onInit() {
    super.onInit();
    fetchUserEvents();
  }

  // =========================
  // EVENT MANAGEMENT METHODS
  // =========================

  /// Create a new event
  void createEvent() async {
    if (!isFormValid) return;

    isSubmitLoading = true;
    update();

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        CustomSnackBar.error(errorList: [MyStrings.pleaseLoginToCreateEvent]);
        return;
      }
      // Parse and format the datetime properly
      DateTime? eventDateTime;
      try {
        eventDateTime = DateTime.parse(dateTimeController.text.trim());
      } catch (e) {
        CustomSnackBar.error(errorList: [MyStrings.invalidDateFormat]);
        return;
      }

      // Create event data
      final eventData = {
        'eventName': eventNameController.text.trim(),
        'dateTime': eventDateTime.toIso8601String(),
        'timezone': selectedTimezone,
        'categoryId': selectedCategoryId,
        'subcategoryId': selectedSubcategoryId,
        'details': detailsController.text.trim(),
        'imageUrl': eventImagePath, // For now, store local path
        'createdBy': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'attendees': [currentUser.uid], // Creator is first attendee
        'maxAttendees': null, // Can be extended later
        'location': await getEventLocation(), // Get event location
      };

      // Store in users_events collection
      await FirebaseFirestore.instance
          .collection('users_events')
          .add(eventData);

      // Show success message
      CustomSnackBar.success(successList: [MyStrings.eventCreatedSuccessfully]);

      // Clear form
      _clearForm();

      // Navigate to bottom navigation with events tab selected (index 1)
      Get.offNamed(RouteHelper.bottomNavBar, arguments: 1);
    } catch (e) {
      CustomSnackBar.error(errorList: ['${MyStrings.failedToCreateEvent}: $e']);
    } finally {
      isSubmitLoading = false;
      update();
    }
  }

  // =========================
  // IMAGE HANDLING METHODS
  // =========================

  /// Upload image from gallery
  void uploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show options to pick from gallery or camera
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: Dimensions.maxImageWidth,
        maxHeight: Dimensions.maxImageHeight,
        imageQuality: Dimensions.imageQuality,
      );

      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        eventImagePath = pickedFile.path;
        update(); // Update UI to show the selected image
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['${MyStrings.failedToPickImage}: $e']);
    }
  }

  /// Pick image from camera
  void pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: Dimensions.maxImageWidth,
        maxHeight: Dimensions.maxImageHeight,
        imageQuality: Dimensions.imageQuality,
      );

      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        eventImagePath = pickedFile.path;
        update(); // Update UI to show the selected image
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['${MyStrings.failedToTakePhoto}: $e']);
    }
  }

  /// Show image picker options bottom sheet
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(Dimensions.space20),
        decoration: BoxDecoration(
          color: MyColor.getWhiteColor(),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.space20),
            topRight: Radius.circular(Dimensions.space20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              MyStrings.selectImageSource,
              style: const TextStyle(
                fontSize: Dimensions.fontExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Dimensions.space20),
            ListTile(
              leading: Icon(Icons.photo_library, color: MyColor.buttonColor),
              title: Text(MyStrings.gallery),
              onTap: () {
                Get.back();
                uploadImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: MyColor.getGreenColor()),
              title: Text(MyStrings.camera),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            const SizedBox(height: Dimensions.space10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // =========================
  // FORM & UTILITY METHODS
  // =========================

  /// Update selected category and subcategory
  void updateCategorySelection(String? categoryId, String? subcategoryId) {
    selectedCategoryId = categoryId;
    selectedSubcategoryId = subcategoryId;
    update();
  }

  /// Handle timezone selection
  void onTimezonePressed() {
    // Implement your timezone selection logic here
  }

  /// Get event location using LocationService
  Future<Map<String, dynamic>?> getEventLocation() async {
    try {
      // Get location data using the shared location service
      final locationData = await LocationService.getLocationDataForFirebase();
      print(
          "✅ Event location obtained: ${locationData['address']['fullAddress']}");
      return locationData;
    } catch (e) {
      print("❌ Failed to get event location: $e");
      CustomSnackBar.error(errorList: [MyStrings.unableToGetLocation]);
      return null;
    }
  }

  /// Clear form after successful submission
  void _clearForm() {
    eventNameController.clear();
    dateTimeController.clear();
    detailsController.clear();
    eventImagePath = '';
    imageFile = null;
    selectedCategoryId = null;
    selectedSubcategoryId = null;
    selectedTimezone = MyStrings.selectTimezone;
    timezoneLabel = MyStrings.selectTimezone;
    update();
  }

  /// Fetch user's events from Firebase
  void fetchUserEvents() async {
    try {
      isLoading = true;
      update();

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('users_events')
          .where('createdBy', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      userEvents = eventsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    } catch (e) {
      CustomSnackBar.error(errorList: ['${MyStrings.failedToFetchEvents}: $e']);
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Delete an event
  void deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users_events')
          .doc(eventId)
          .delete();

      // Remove from local list
      userEvents.removeWhere((event) => event['id'] == eventId);
      update();

      CustomSnackBar.success(successList: [MyStrings.eventDeletedSuccessfully]);
    } catch (e) {
      CustomSnackBar.error(errorList: ['${MyStrings.failedToDeleteEvent}: $e']);
    }
  }
}
