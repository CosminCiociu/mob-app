import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/services/events_service.dart';

/// Refactored MyEventsController using clean architecture with services
///
/// This controller now focuses on UI coordination and delegates business logic
/// to dedicated service classes, promoting better separation of concerns.
class MyEventsController extends GetxController {
  static MyEventsController get to => Get.find();

  // Service dependency injection
  final EventsService _eventsService = Get.find<EventsService>();

  // UI reactive variables - expose service state
  bool get isLoading => _eventsService.isLoading;
  bool get isSubmitLoading => _eventsService.isSubmitLoading;
  bool get isRepeatEvent => _eventsService.isRepeatEvent;
  bool get hasSpecificTime => _eventsService.hasSpecificTime;
  bool get hasSpecificLocation => _eventsService.hasSpecificLocation;
  bool get requiresApproval => _eventsService.requiresApproval;

  // Form controllers - expose service controllers
  TextEditingController get eventNameController =>
      _eventsService.eventNameController;
  TextEditingController get detailsController =>
      _eventsService.detailsController;
  TextEditingController get dateTimeController =>
      _eventsService.dateTimeController;

  // Focus nodes - expose service focus nodes
  FocusNode get eventNameFocusNode => _eventsService.eventNameFocusNode;
  FocusNode get detailsFocusNode => _eventsService.detailsFocusNode;
  FocusNode get dateTimeFocusNode => _eventsService.dateTimeFocusNode;

  // Image and data - expose service properties
  File? get imageFile => _eventsService.imageFile;
  String get eventImagePath => _eventsService.eventImagePath;
  String get selectedTimezone => _eventsService.selectedTimezone;
  String get timezoneLabel => _eventsService.timezoneLabel;
  String? get selectedCategoryId => _eventsService.selectedCategoryId;
  String? get selectedSubcategoryId => _eventsService.selectedSubcategoryId;
  List<Map<String, dynamic>> get userEvents => _eventsService.userEvents;
  DateTime? get dateTimeStart => _eventsService.dateTimeStart;
  DateTime? get dateTimeEnd => _eventsService.dateTimeEnd;
  LatLng? get eventLocation => _eventsService.eventLocation;
  String? get eventLocationName => _eventsService.eventLocationName;
  int? get maxPersons => _eventsService.maxPersons;
  TextEditingController get maxPersonsController =>
      _eventsService.maxPersonsController;
  int? get minAge => _eventsService.minAge;
  int? get maxAge => _eventsService.maxAge;
  TextEditingController get minAgeController => _eventsService.minAgeController;
  TextEditingController get maxAgeController => _eventsService.maxAgeController;

  // Form validation - delegate to service
  bool get isFormValid => _eventsService.isFormValid;

  @override
  void onInit() {
    super.onInit();
    print("🚀 MyEventsController: Initializing...");
    // Set up callback to update UI when service state changes
    _setupServiceCallback();
    print("🔗 MyEventsController: Service callback set up");
    fetchMyEvents();
    print("✅ MyEventsController: Initialization complete");
  }

  /// Set up callback to update UI when service state changes
  void _setupServiceCallback() {
    _eventsService.setStateChangeCallback(() => update());
  }

  // Business logic methods - delegate to service
  Future<void> createEvent() => _eventsService.createEvent();
  Future<void> updateEvent(String eventId) =>
      _eventsService.updateEvent(eventId);
  void clearForm() => _eventsService.clearForm();
  void populateFormForEditing(Map<String, dynamic> eventData) =>
      _eventsService.populateFormForEditing(eventData);

  // Image handling methods - delegate to service
  Future<void> uploadImage() => _eventsService.uploadImage();
  Future<void> pickImageFromCamera() => _eventsService.pickImageFromCamera();
  void showImagePickerOptions() => _eventsService.showImagePickerOptions();

  // Timezone methods - delegate to service
  void onTimezonePressed() => _eventsService.onTimezonePressed();

  // Category methods - delegate to service
  void updateCategorySelection(String? categoryId, String? subcategoryId) =>
      _eventsService.updateCategorySelection(categoryId, subcategoryId);

  // Time configuration methods - delegate to service
  void setHasSpecificTime(bool hasTime) =>
      _eventsService.setHasSpecificTime(hasTime);

  void setHasSpecificLocation(bool hasLocation) =>
      _eventsService.setHasSpecificLocation(hasLocation);

  void setRequiresApproval(bool requiresApproval) =>
      _eventsService.setRequiresApproval(requiresApproval);

  void setDateTimeRange(DateTime? start, DateTime? end) =>
      _eventsService.setDateTimeRange(start, end);

  void setEventLocation(LatLng? location, String? locationName) =>
      _eventsService.setEventLocation(location, locationName);

  void setMaxPersons(int? maxPersons) =>
      _eventsService.setMaxPersons(maxPersons);

  void setAgeRange(int? minAge, int? maxAge) =>
      _eventsService.setAgeRange(minAge, maxAge);

  // Data access methods - delegate to service
  Future<void> fetchUserEvents() => _eventsService.fetchUserEvents();
  Future<void> deleteEvent(String eventId) =>
      _eventsService.deleteEvent(eventId);
  Future<void> toggleEventStatus(String eventId, String currentStatus) =>
      _eventsService.toggleEventStatus(eventId, currentStatus);
  Future<int> getUserEventCount() => _eventsService.getUserEventCount();

  // Additional methods for backward compatibility
  Future<void> fetchMyEvents() => _eventsService.fetchUserEvents();

  @override
  void onClose() {
    // Service handles its own cleanup
    super.onClose();
  }
}
