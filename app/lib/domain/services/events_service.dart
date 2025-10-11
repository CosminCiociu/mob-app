import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service interface for events business logic
abstract class EventsService {
  // State getters
  bool get isSubmitLoading;
  bool get isLoading;
  bool get isRepeatEvent;
  bool get hasSpecificTime;
  bool get hasSpecificLocation;
  String get eventImagePath;
  String get selectedTimezone;
  String get timezoneLabel;
  String? get selectedCategoryId;
  String? get selectedSubcategoryId;
  File? get imageFile;
  List<Map<String, dynamic>> get userEvents;
  bool get isFormValid;
  DateTime? get dateTimeStart;
  DateTime? get dateTimeEnd;
  LatLng? get eventLocation;
  String? get eventLocationName;
  int? get maxPersons;
  int? get minAge;
  int? get maxAge;

  // Form controllers
  TextEditingController get eventNameController;
  TextEditingController get detailsController;
  TextEditingController get dateTimeController;
  TextEditingController get maxPersonsController;
  TextEditingController get minAgeController;
  TextEditingController get maxAgeController;
  FocusNode get eventNameFocusNode;
  FocusNode get detailsFocusNode;
  FocusNode get dateTimeFocusNode;

  // State setters
  void setSubmitLoading(bool loading);
  void setLoading(bool loading);
  void setRepeatEvent(bool repeat);
  void setHasSpecificTime(bool hasTime);
  void setHasSpecificLocation(bool hasLocation);
  void setDateTimeRange(DateTime? start, DateTime? end);
  void setEventLocation(LatLng? location, String? locationName);
  void setMaxPersons(int? maxPersons);
  void setAgeRange(int? minAge, int? maxAge);

  // Event operations
  Future<void> createEvent();
  Future<void> fetchUserEvents();
  Future<void> deleteEvent(String eventId);

  // Form operations
  void updateCategorySelection(String? categoryId, String? subcategoryId);
  void clearForm();
  void validateForm();

  // Image operations
  Future<void> uploadImage();
  Future<void> pickImageFromCamera();
  void showImagePickerOptions();

  // Utility operations
  void onTimezonePressed();
  Future<Map<String, dynamic>?> getEventLocation();

  // Callback operations
  void setStateChangeCallback(VoidCallback? callback);
}
