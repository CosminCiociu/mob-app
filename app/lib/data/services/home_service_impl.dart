import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/services/home_service.dart';
import '../../core/utils/dimensions.dart';
import '../../core/utils/my_strings.dart';
import '../../view/components/snack_bar/show_custom_snackbar.dart';

/// Concrete implementation of HomeService for home screen business logic
class HomeServiceImpl implements HomeService {
  // State variables that the service manages
  int currentIndex = 0;
  bool isLoadingEvents = false;
  bool isLoadingUsers = false;
  bool hasFinishedAllEvents = false;

  int distance = Dimensions.defaultSearchRadius.toInt();
  int age = Dimensions.defaultAgeFilter.toInt();
  RangeValues rangeValues =
      const RangeValues(Dimensions.minAgeRange, Dimensions.maxAgeRange);

  List<Map<String, dynamic>> interestedIn = [
    {'genders': 'Men', 'status': false},
    {'genders': 'Women', 'status': false},
    {'genders': 'Other', 'status': false},
  ];

  // Callback function for UI updates
  VoidCallback? onStateChanged;

  HomeServiceImpl({this.onStateChanged});

  @override
  void resetCurrentIndex() {
    currentIndex = 0;
    CustomSnackBar.successDeferred(successList: [MyStrings.indexReset]);
    _notifyStateChanged();
  }

  @override
  void handleSwipeComplete(int index, List<DocumentSnapshot> events) {
    if (events.isNotEmpty) {
      currentIndex = index + 1;
      if (currentIndex >= events.length) {
        hasFinishedAllEvents = true;
      }
    } else {
      // Fallback behavior for demo images
      currentIndex = (index + 1) % 4; // Assuming 4 demo images
    }
    _notifyStateChanged();
  }

  @override
  void updateSearchDistance(int newDistance) {
    if (newDistance < Dimensions.minSearchRadius.toInt()) {
      distance = Dimensions.minSearchRadius.toInt();
      CustomSnackBar.errorDeferred(errorList: [
        'Distance set to minimum: ${Dimensions.minSearchRadius.toInt()}km'
      ]);
    } else if (newDistance > Dimensions.maxSearchRadius.toInt()) {
      distance = Dimensions.maxSearchRadius.toInt();
      CustomSnackBar.errorDeferred(errorList: [
        'Distance set to maximum: ${Dimensions.maxSearchRadius.toInt()}km'
      ]);
    } else {
      distance = newDistance;
      CustomSnackBar.successDeferred(
          successList: ['Search radius updated to ${distance}km']);
    }
    _notifyStateChanged();
  }

  @override
  void updateAgeRange(double start, double end) {
    if (start < Dimensions.minAgeRange || end > Dimensions.maxAgeRange) {
      rangeValues =
          const RangeValues(Dimensions.minAgeRange, Dimensions.maxAgeRange);
      CustomSnackBar.errorDeferred(errorList: [
        'Age range set to valid limits: ${Dimensions.minAgeRange.toInt()}-${Dimensions.maxAgeRange.toInt()}'
      ]);
    } else if (start >= end) {
      CustomSnackBar.errorDeferred(
          errorList: ['Invalid age range: minimum must be less than maximum']);
    } else {
      rangeValues = RangeValues(start, end);
      CustomSnackBar.successDeferred(successList: [
        'Age range updated: ${rangeValues.start.toInt()}-${rangeValues.end.toInt()}'
      ]);
    }
    _notifyStateChanged();
  }

  @override
  void changeGenderFilterStatus(int index) {
    if (index < 0 || index >= interestedIn.length) {
      CustomSnackBar.errorDeferred(
          errorList: ['Invalid gender filter selection']);
      return;
    }

    interestedIn[index]['status'] = !interestedIn[index]['status'];

    String genderName = interestedIn[index]['genders'] as String;
    bool isEnabled = interestedIn[index]['status'] as bool;

    CustomSnackBar.successDeferred(successList: [
      'Filter ${isEnabled ? "enabled" : "disabled"} for $genderName'
    ]);

    _notifyStateChanged();
  }

  @override
  void resetFilters() {
    distance = Dimensions.defaultSearchRadius.toInt();
    age = Dimensions.defaultAgeFilter.toInt();
    rangeValues =
        const RangeValues(Dimensions.minAgeRange, Dimensions.maxAgeRange);

    for (var filter in interestedIn) {
      filter['status'] = false;
    }

    CustomSnackBar.successDeferred(
        successList: ['All filters reset to default values']);
    _notifyStateChanged();
  }

  @override
  void validateSearchParameters() {
    bool hasChanges = false;

    if (distance < Dimensions.minSearchRadius.toInt()) {
      distance = Dimensions.minSearchRadius.toInt();
      hasChanges = true;
    } else if (distance > Dimensions.maxSearchRadius.toInt()) {
      distance = Dimensions.maxSearchRadius.toInt();
      hasChanges = true;
    }

    if (rangeValues.start < Dimensions.minAgeRange ||
        rangeValues.end > Dimensions.maxAgeRange) {
      rangeValues =
          const RangeValues(Dimensions.minAgeRange, Dimensions.maxAgeRange);
      hasChanges = true;
    }

    if (hasChanges) {
      CustomSnackBar.errorDeferred(
          errorList: ['Search parameters adjusted to valid ranges']);
      _notifyStateChanged();
    }
  }

  @override
  bool get isLoading => isLoadingEvents || isLoadingUsers;

  @override
  String get loadingMessage {
    if (isLoadingEvents && isLoadingUsers) {
      return 'Loading events and users...';
    } else if (isLoadingEvents) {
      return MyStrings.searchingForEvents;
    } else if (isLoadingUsers) {
      return MyStrings.searchingForUsers;
    } else {
      return 'Ready';
    }
  }

  @override
  bool get hasActiveFilters {
    return interestedIn.any((filter) => filter['status'] == true) ||
        distance != Dimensions.defaultSearchRadius.toInt() ||
        rangeValues.start != Dimensions.minAgeRange ||
        rangeValues.end != Dimensions.maxAgeRange;
  }

  @override
  int get activeFiltersCount {
    int count = 0;

    count += interestedIn.where((filter) => filter['status'] == true).length;

    if (distance != Dimensions.defaultSearchRadius.toInt()) count++;

    if (rangeValues.start != Dimensions.minAgeRange ||
        rangeValues.end != Dimensions.maxAgeRange) count++;

    return count;
  }

  @override
  String get searchSummary {
    List<String> summary = [];

    summary.add('Radius: ${distance}km');
    summary.add('Age: ${rangeValues.start.toInt()}-${rangeValues.end.toInt()}');

    var activeGenders = interestedIn
        .where((filter) => filter['status'] == true)
        .map((filter) => filter['genders'] as String)
        .toList();

    if (activeGenders.isNotEmpty) {
      summary.add('Interested in: ${activeGenders.join(', ')}');
    }

    return summary.join(' • ');
  }

  void _notifyStateChanged() {
    onStateChanged?.call();
  }

  // Setters for loading states (to be used by controller)
  void setLoadingEvents(bool loading) {
    isLoadingEvents = loading;
    _notifyStateChanged();
  }

  void setLoadingUsers(bool loading) {
    isLoadingUsers = loading;
    _notifyStateChanged();
  }
}
