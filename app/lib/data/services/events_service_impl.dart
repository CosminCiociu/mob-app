import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/services/events_service.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/image_repository.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/my_strings.dart';

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
  bool _requiresApproval = true; // Default to requiring approval
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
  int? _maxPersons;
  int? _minAge;
  int? _maxAge;

  // Form controllers
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _maxPersonsController = TextEditingController();
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
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
  bool get requiresApproval => _requiresApproval;

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
  int? get maxPersons => _maxPersons;

  @override
  int? get minAge => _minAge;

  @override
  int? get maxAge => _maxAge;

  @override
  TextEditingController get eventNameController => _eventNameController;

  @override
  TextEditingController get detailsController => _detailsController;

  @override
  TextEditingController get dateTimeController => _dateTimeController;

  @override
  TextEditingController get maxPersonsController => _maxPersonsController;

  @override
  TextEditingController get minAgeController => _minAgeController;

  @override
  TextEditingController get maxAgeController => _maxAgeController;

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
  void setRequiresApproval(bool requiresApproval) {
    _requiresApproval = requiresApproval;
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

  @override
  void setMaxPersons(int? maxPersons) {
    _maxPersons = maxPersons;
    if (maxPersons != null) {
      _maxPersonsController.text = maxPersons.toString();
    } else {
      _maxPersonsController.clear();
    }
    _notifyStateChanged();
  }

  @override
  void setAgeRange(int? minAge, int? maxAge) {
    _minAge = minAge;
    _maxAge = maxAge;
    if (minAge != null) {
      _minAgeController.text = minAge.toString();
    } else {
      _minAgeController.clear();
    }
    if (maxAge != null) {
      _maxAgeController.text = maxAge.toString();
    } else {
      _maxAgeController.clear();
    }
    _notifyStateChanged();
  }

  /// Populate form with existing event data for editing
  void populateFormForEditing(Map<String, dynamic> eventData) {
    // Clear form first
    clearForm();

    // Basic event info
    _eventNameController.text = eventData['eventName'] ?? '';
    _detailsController.text = eventData['details'] ?? '';

    // Category
    _selectedCategoryId = eventData['categoryId'];
    _selectedSubcategoryId = eventData['subcategoryId'];

    // DateTime
    if (eventData['dateTime'] != null) {
      try {
        final dateTime = DateTime.parse(eventData['dateTime']);
        setDateTimeRange(dateTime, null);
        setHasSpecificTime(true);
      } catch (e) {
        print('Error parsing event dateTime: $e');
      }
    }

    // Location
    if (eventData['location'] != null) {
      final locationData = eventData['location'];
      if (locationData is Map<String, dynamic>) {
        final lat = locationData['latitude'];
        final lng = locationData['longitude'];
        final name = locationData['name'] ?? locationData['address'];

        if (lat != null && lng != null) {
          setEventLocation(
            LatLng(lat.toDouble(), lng.toDouble()),
            name?.toString(),
          );
          setHasSpecificLocation(true);
        }
      }
    }

    // Max attendees
    if (eventData['maxAttendees'] != null) {
      setMaxPersons(eventData['maxAttendees']);
    }

    // Age range
    setAgeRange(
      eventData['minAge'],
      eventData['maxAge'],
    );

    // Approval requirement
    if (eventData.containsKey('requiresApproval')) {
      setRequiresApproval(eventData['requiresApproval'] ?? true);
    }

    // Image URL
    if (eventData['imageUrl'] != null && eventData['imageUrl'].isNotEmpty) {
      _eventImagePath = eventData['imageUrl'];
    }

    _notifyStateChanged();
  }

  // =========================
  // FORM OPERATIONS
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

      // Check event limit before creating
      final currentEventCount = await getUserEventCount();
      if (currentEventCount >= 3) {
        CustomSnackBar.errorDeferred(errorList: [MyStrings.eventLimitReached]);
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
        'attendees': {
          currentUser.uid: {
            'joinedAt': FieldValue.serverTimestamp(),
          },
        },
        'maxAttendees': _maxPersons,
        'minAge': _minAge,
        'maxAge': _maxAge,
        'location': await getEventLocation(),
        'requiresApproval': _requiresApproval,
        'users_pending': {},
        'users_declined': {},
      };

      // Create event using repository
      await _eventRepository.createEvent(eventData);

      // Show success message
      CustomSnackBar.successDeferred(
          successList: ['Event created successfully']);

      // Refresh user events to include the newly created event
      await fetchUserEvents();

      // Clear form
      clearForm();

      // Navigate to bottom navigation with events tab selected (index 3)
      Get.offNamed(RouteHelper.bottomNavBar, arguments: 3);
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

  @override
  Future<void> updateEvent(String eventId) async {
    try {
      setSubmitLoading(true);

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Validate form data
      if (_eventNameController.text.trim().isEmpty) {
        throw Exception('Event name is required');
      }

      // Build updated event data
      final eventData = <String, dynamic>{
        'eventName': _eventNameController.text.trim(),
        'dateTime': _dateTimeStart?.toIso8601String(),
        'categoryId': _selectedCategoryId,
        'subcategoryId': _selectedSubcategoryId,
        'details': _detailsController.text.trim(),
        'imageUrl': _eventImagePath,
        'maxAttendees': _maxPersons,
        'minAge': _minAge,
        'maxAge': _maxAge,
        'location': _eventLocation != null
            ? {
                'latitude': _eventLocation!.latitude,
                'longitude': _eventLocation!.longitude,
                'name': _eventLocationName,
              }
            : null,
        'requiresApproval': _requiresApproval,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Update event using repository
      await _eventRepository.updateEvent(eventId, eventData);

      // Refresh user events to get updated data from database
      await fetchUserEvents();

      // Show success message
      CustomSnackBar.successDeferred(
          successList: ['Event updated successfully']);

      // Navigate back to events screen
      Get.back();

      _notifyStateChanged();
    } catch (e) {
      CustomSnackBar.errorDeferred(errorList: ['Failed to update event: $e']);
    } finally {
      setSubmitLoading(false);
    }
  }

  @override
  Future<void> toggleEventStatus(String eventId, String currentStatus) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Determine new status
      final newStatus = currentStatus == 'active' ? 'inactive' : 'active';

      // Update event status
      final eventData = <String, dynamic>{
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _eventRepository.updateEvent(eventId, eventData);

      // Refresh user events to get updated data from database
      await fetchUserEvents();

      // Show success message
      final statusText = newStatus == 'active' ? 'activated' : 'deactivated';
      CustomSnackBar.successDeferred(
          successList: ['Event $statusText successfully']);
    } catch (e) {
      CustomSnackBar.errorDeferred(
          errorList: ['Failed to update event status: $e']);
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
    _maxPersonsController.clear();
    _minAgeController.clear();
    _maxAgeController.clear();
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
    _maxPersons = null;
    _minAge = null;
    _maxAge = null;
    _hasSpecificTime = false;
    _hasSpecificLocation = false;
    _requiresApproval = true; // Default to requiring approval
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
      final location = await LocationService.getCurrentLocation();
      if (location != null && location.isValid) {
        final locationData = location.toFirebaseData();
        print("✅ Event location obtained: ${location.displayAddress}");
        return locationData;
      } else {
        print("❌ Unable to get valid location");
        CustomSnackBar.errorDeferred(errorList: ['Unable to get location']);
        return null;
      }
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

  @override
  Future<int> getUserEventCount() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return 0;
      }

      return await _eventRepository.countUserEvents(currentUser.uid);
    } catch (e) {
      print("❌ EventsService: Error counting user events: $e");
      return 0; // Return 0 if there's an error to avoid blocking event creation
    }
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
