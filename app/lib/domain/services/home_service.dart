import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service interface for home screen business logic
abstract class HomeService {
  /// State getters
  int get currentIndex;
  bool get isLoadingEvents;
  bool get isLoadingUsers;
  bool get hasFinishedAllEvents;
  int get distance;
  int get age;
  RangeValues get rangeValues;
  List<Map<String, dynamic>> get interestedIn;

  /// State setters
  void setLoadingEvents(bool loading);
  void setLoadingUsers(bool loading);

  /// Reset swipe index and notify UI (silent - no snackbar)
  void resetCurrentIndex();

  /// Reset swipe index with user feedback (shows snackbar)
  void resetCurrentIndexWithFeedback();

  /// Handle swipe completion logic
  void handleSwipeComplete(int index, List<DocumentSnapshot> events);

  /// Update search distance with validation
  void updateSearchDistance(int newDistance);

  /// Update age range with validation
  void updateAgeRange(double start, double end);

  /// Change gender filter status
  void changeGenderFilterStatus(int index);

  /// Reset all filters to default values
  void resetFilters();

  /// Validate search parameters
  void validateSearchParameters();

  /// Check if any loading operation is in progress
  bool get isLoading;

  /// Get current loading status message
  String get loadingMessage;

  /// Check if there are active filters applied
  bool get hasActiveFilters;

  /// Get count of active filters
  int get activeFiltersCount;

  /// Get summary of current search parameters
  String get searchSummary;
}
