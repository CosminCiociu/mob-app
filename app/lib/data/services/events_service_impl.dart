import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/services/events_service.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/image_repository.dart';
import '../../core/services/location_service.dart';

import '../../core/utils/my_color.dart';
import '../../core/utils/dimensions.dart';
import '../../core/route/route.dart';
import '../../view/components/snack_bar/show_custom_snackbar.dart';

/// Implementation of EventsService
class EventsServiceImpl implements EventsService {
  final EventRepository _eventRepository;
  final ImageRepository _imageRepository;

  EventsServiceImpl({
    required EventRepository eventRepository,
    required ImageRepository imageRepository,
  })  : _eventRepository = eventRepository,
        _imageRepository = imageRepository;

  // =========================
  // STATE VARIABLES
  // =========================

  bool _isSubmitLoading = false;
  bool _isLoading = false;
  bool _isRepeatEvent = false;
  bool _hasSpecificTime = false;
  bool _hasSpecificLocation = false;
  String _eventImagePath = '';
  String _selectedTimezone = 'Select Timezone';
  String _timezoneLabel = 'Select Timezone';
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  File? _imageFile;
  List<Map<String, dynamic>> _userEvents = [];
  DateTime? _dateTimeStart;
  DateTime? _dateTimeEnd;
  LatLng? _eventLocation;
  String? _eventLocationName;

  // Form controllers
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final FocusNode _eventNameFocusNode = FocusNode();
  final FocusNode _detailsFocusNode = FocusNode();
  final FocusNode _dateTimeFocusNode = FocusNode();

  // Callback for UI updates
  VoidCallback? onStateChanged;

  EventsServiceImpl.withCallback({
    required EventRepository eventRepository,
    required ImageRepository imageRepository,
    this.onStateChanged,
  })  : _eventRepository = eventRepository,
        _imageRepository = imageRepository;

  // =========================
  // GETTERS
  // =========================

  @override
  bool get isSubmitLoading => _isSubmitLoading;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isRepeatEvent => _isRepeatEvent;

  @override
  bool get hasSpecificTime => _hasSpecificTime;

  @override
  bool get hasSpecificLocation => _hasSpecificLocation;

  @override
  String get eventImagePath => _eventImagePath;

  @override
  String get selectedTimezone => _selectedTimezone;

  @override
  String get timezoneLabel => _timezoneLabel;

  @override
  String? get selectedCategoryId => _selectedCategoryId;

  @override
  String? get selectedSubcategoryId => _selectedSubcategoryId;

  @override
  File? get imageFile => _imageFile;

  @override
  List<Map<String, dynamic>> get userEvents => _userEvents;

  @override
  DateTime? get dateTimeStart => _dateTimeStart;

  @override
  DateTime? get dateTimeEnd => _dateTimeEnd;

  @override
  LatLng? get eventLocation => _eventLocation;

  @override
  String? get eventLocationName => _eventLocationName;

  @override
  TextEditingController get eventNameController => _eventNameController;

  @override
  TextEditingController get detailsController => _detailsController;

  @override
  TextEditingController get dateTimeController => _dateTimeController;

  @override
  FocusNode get eventNameFocusNode => _eventNameFocusNode;

  @override
  FocusNode get detailsFocusNode => _detailsFocusNode;

  @override
  FocusNode get dateTimeFocusNode => _dateTimeFocusNode;

  @override
  bool get isFormValid {
    return _eventNameController.text.trim().isNotEmpty &&
        _dateTimeController.text.trim().isNotEmpty &&
        _selectedCategoryId != null &&
        _selectedSubcategoryId != null &&
        _detailsController.text.trim().isNotEmpty;
  }

  // =========================
  // SETTERS
  // =========================

  @override
  void setSubmitLoading(bool loading) {
    _isSubmitLoading = loading;
    _notifyStateChanged();
  }

  @override
  void setLoading(bool loading) {
    _isLoading = loading;
    _notifyStateChanged();
  }

  @override
  void setRepeatEvent(bool repeat) {
    _isRepeatEvent = repeat;
    _notifyStateChanged();
  }

  @override
  void setHasSpecificTime(bool hasTime) {
    _hasSpecificTime = hasTime;
    if (!hasTime) {
      // Clear datetime when hasSpecificTime is false
      _dateTimeController.clear();
      _dateTimeStart = null;
      _dateTimeEnd = null;
    }
    _notifyStateChanged();
  }

  @override
  void setHasSpecificLocation(bool hasLocation) {
    _hasSpecificLocation = hasLocation;
    if (!hasLocation) {
      // Clear location when hasSpecificLocation is false
      _eventLocation = null;
      _eventLocationName = null;
    }
    _notifyStateChanged();
  }

  @override
  void setDateTimeRange(DateTime? start, DateTime? end) {
    _dateTimeStart = start;
    _dateTimeEnd = end;
    // Update the legacy dateTimeController for backward compatibility
    if (start != null) {
      _dateTimeController.text = start.toIso8601String();
    } else {
      _dateTimeController.clear();
    }
    _notifyStateChanged();
  }

  @override
  void setEventLocation(LatLng? location, String? locationName) {
    _eventLocation = location;
    _eventLocationName = locationName;
    _notifyStateChanged();
  }

  // =========================
  // EVENT OPERATIONS
  // =========================

  @override
  Future<void> createEvent() async {
    if (!isFormValid) {
      CustomSnackBar.errorDeferred(
          errorList: ['Please fill all required fields']);
      return;
    }

    setSubmitLoading(true);

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        CustomSnackBar.errorDeferred(
            errorList: ['Please login to create event']);
        return;
      }

      // Parse and format the datetime properly
      DateTime? eventDateTime;
      try {
        eventDateTime = DateTime.parse(_dateTimeController.text.trim());
      } catch (e) {
        CustomSnackBar.errorDeferred(errorList: ['Invalid date format']);
        return;
      }

      // Create event data
      final eventData = {
        'eventName': _eventNameController.text.trim(),
        'dateTime': eventDateTime.toIso8601String(),
        'timezone': _selectedTimezone,
        'categoryId': _selectedCategoryId,
        'subcategoryId': _selectedSubcategoryId,
        'details': _detailsController.text.trim(),
        'imageUrl': _eventImagePath,
        'createdBy': currentUser.uid,
        'attendees': [currentUser.uid],
        'maxAttendees': null,
        'location': await getEventLocation(),
      };

      // Create event using repository
      await _eventRepository.createEvent(eventData);

      // Show success message
      CustomSnackBar.successDeferred(
          successList: ['Event created successfully']);

      // Clear form
      clearForm();

      // Navigate to bottom navigation with events tab selected (index 1)
      Get.offNamed(RouteHelper.bottomNavBar, arguments: 1);
    } catch (e) {
      CustomSnackBar.errorDeferred(errorList: ['Failed to create event: $e']);
    } finally {
      setSubmitLoading(false);
    }
  }

  @override
  Future<void> fetchUserEvents() async {
    try {
      final stopwatch = Stopwatch()..start();
      print("🔄 EventsService: Starting fetchUserEvents...");

      setLoading(true);

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("❌ EventsService: No authenticated user found");
        return;
      }

      print("📡 EventsService: Fetching events for user: ${currentUser.uid}");
      _userEvents = await _eventRepository.fetchUserEvents(currentUser.uid);

      stopwatch.stop();
      print(
          "✅ EventsService: Fetched ${_userEvents.length} events in ${stopwatch.elapsedMilliseconds}ms");

      _notifyStateChanged();
    } catch (e) {
      print("❌ EventsService: Error fetching events: $e");
      CustomSnackBar.errorDeferred(errorList: ['Failed to fetch events: $e']);
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventRepository.deleteEvent(eventId);

      // Remove from local list
      _userEvents.removeWhere((event) => event['id'] == eventId);
      _notifyStateChanged();

      CustomSnackBar.successDeferred(
          successList: ['Event deleted successfully']);
    } catch (e) {
      CustomSnackBar.errorDeferred(errorList: ['Failed to delete event: $e']);
    }
  }

  // =========================
  // FORM OPERATIONS
  // =========================

  @override
  void updateCategorySelection(String? categoryId, String? subcategoryId) {
    _selectedCategoryId = categoryId;
    _selectedSubcategoryId = subcategoryId;
    _notifyStateChanged();
  }

  @override
  void clearForm() {
    _eventNameController.clear();
    _dateTimeController.clear();
    _detailsController.clear();
    _eventImagePath = '';
    _imageFile = null;
    _selectedCategoryId = null;
    _selectedSubcategoryId = null;
    _selectedTimezone = 'Select Timezone';
    _timezoneLabel = 'Select Timezone';
    _dateTimeStart = null;
    _dateTimeEnd = null;
    _eventLocation = null;
    _eventLocationName = null;
    _hasSpecificTime = false;
    _hasSpecificLocation = false;
    _notifyStateChanged();
  }

  @override
  void validateForm() {
    // Form validation is handled by the isFormValid getter
    _notifyStateChanged();
  }

  // =========================
  // IMAGE OPERATIONS
  // =========================

  @override
  Future<void> uploadImage() async {
    try {
      final File? pickedFile = await _imageRepository.pickImageFromGallery();

      if (pickedFile != null) {
        _imageFile = pickedFile;
        _eventImagePath = pickedFile.path;
        _notifyStateChanged();
      }
    } catch (e) {
      CustomSnackBar.errorDeferred(errorList: ['Failed to pick image: $e']);
    }
  }

  @override
  Future<void> pickImageFromCamera() async {
    try {
      final File? pickedFile = await _imageRepository.pickImageFromCamera();

      if (pickedFile != null) {
        _imageFile = pickedFile;
        _eventImagePath = pickedFile.path;
        _notifyStateChanged();
      }
    } catch (e) {
      CustomSnackBar.errorDeferred(errorList: ['Failed to take photo: $e']);
    }
  }

  @override
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
              'Select Image Source',
              style: const TextStyle(
                fontSize: Dimensions.fontExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Dimensions.space20),
            ListTile(
              leading: Icon(Icons.photo_library, color: MyColor.buttonColor),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                uploadImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: MyColor.getGreenColor()),
              title: Text('Camera'),
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
  // UTILITY OPERATIONS
  // =========================

  @override
  void onTimezonePressed() {
    // TODO: Implement timezone selection logic
    CustomSnackBar.successDeferred(
        successList: ['Timezone selection coming soon']);
  }

  @override
  Future<Map<String, dynamic>?> getEventLocation() async {
    try {
      final locationData = await LocationService.getLocationDataForFirebase();
      print(
          "✅ Event location obtained: ${locationData['address']['fullAddress']}");
      return locationData;
    } catch (e) {
      print("❌ Failed to get event location: $e");
      CustomSnackBar.errorDeferred(errorList: ['Unable to get location']);
      return null;
    }
  }

  // =========================
  // CALLBACK OPERATIONS
  // =========================

  @override
  void setStateChangeCallback(VoidCallback? callback) {
    onStateChanged = callback;
  }

  // =========================
  // PRIVATE METHODS
  // =========================

  void _notifyStateChanged() {
    onStateChanged?.call();
  }

  /// Dispose method for cleanup
  void dispose() {
    _eventNameController.dispose();
    _detailsController.dispose();
    _dateTimeController.dispose();
    _eventNameFocusNode.dispose();
    _detailsFocusNode.dispose();
    _dateTimeFocusNode.dispose();
  }
}
