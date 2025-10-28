import 'package:flutter/material.dart';

/// Manages search filters and parameters
class SearchFiltersManager {
  // Filter state
  int _distance = 200; // Default 200km radius
  int _age = 25; // Default age
  RangeValues _rangeValues = const RangeValues(18, 65); // Default age range
  List<Map<String, dynamic>> _interestedIn = [];

  // Getters
  int get distance => _distance;
  int get age => _age;
  RangeValues get rangeValues => _rangeValues;
  List<Map<String, dynamic>> get interestedIn => _interestedIn;

  /// Update search distance
  void updateDistance(int newDistance) {
    if (newDistance > 0 && newDistance <= 500) {
      _distance = newDistance;
      print('🔍 Search distance updated to: ${_distance}km');
    }
  }

  /// Update age range filter
  void updateAgeRange(double start, double end) {
    if (start >= 18 && end <= 100 && start < end) {
      _rangeValues = RangeValues(start, end);
      print('🔍 Age range updated to: ${start.round()}-${end.round()}');
    }
  }

  /// Update age filter
  void updateAge(int newAge) {
    if (newAge >= 18 && newAge <= 100) {
      _age = newAge;
      print('🔍 Age filter updated to: $_age');
    }
  }

  /// Toggle gender filter status
  void changeGenderFilterStatus(int index) {
    if (index >= 0 && index < _interestedIn.length) {
      final current = _interestedIn[index];
      final newStatus = !(current['status'] as bool? ?? false);
      _interestedIn[index] = {
        ...current,
        'status': newStatus,
      };
      print('🔍 Gender filter ${current['name']} set to: $newStatus');
    }
  }

  /// Reset all filters to defaults
  void resetFilters() {
    _distance = 20;
    _age = 25;
    _rangeValues = const RangeValues(18, 65);
    _interestedIn = _getDefaultGenderFilters();
    print('🔍 All filters reset to defaults');
  }

  /// Initialize default gender filters
  void initializeGenderFilters() {
    _interestedIn = _getDefaultGenderFilters();
  }

  /// Get default gender filter options
  List<Map<String, dynamic>> _getDefaultGenderFilters() {
    return [
      {'name': 'Men', 'status': true},
      {'name': 'Women', 'status': true},
      {'name': 'Other', 'status': true},
    ];
  }

  /// Get active gender filters
  List<String> getActiveGenderFilters() {
    return _interestedIn
        .where((filter) => filter['status'] == true)
        .map((filter) => filter['name'] as String)
        .toList();
  }

  /// Check if any filters are active (non-default)
  bool get hasActiveFilters {
    return _distance != 20 ||
        _age != 25 ||
        _rangeValues.start != 18.0 ||
        _rangeValues.end != 65.0 ||
        getActiveGenderFilters().length != 3; // All genders selected by default
  }

  /// Get filter summary for display
  String getFilterSummary() {
    final List<String> summary = [];

    if (_distance != 20) {
      summary.add('${_distance}km radius');
    }

    if (_rangeValues.start != 18.0 || _rangeValues.end != 65.0) {
      summary
          .add('Age ${_rangeValues.start.round()}-${_rangeValues.end.round()}');
    }

    final activeGenders = getActiveGenderFilters();
    if (activeGenders.length < 3) {
      summary.add('${activeGenders.join(", ")}');
    }

    return summary.isEmpty ? 'No filters' : summary.join(', ');
  }

  /// Export current filter state
  Map<String, dynamic> exportFilterState() {
    return {
      'distance': _distance,
      'age': _age,
      'ageRange': {
        'start': _rangeValues.start,
        'end': _rangeValues.end,
      },
      'interestedIn': List.from(_interestedIn),
    };
  }

  /// Import filter state
  void importFilterState(Map<String, dynamic> state) {
    try {
      _distance = state['distance'] ?? 20;
      _age = state['age'] ?? 25;

      final ageRange = state['ageRange'] as Map<String, dynamic>?;
      if (ageRange != null) {
        _rangeValues = RangeValues(
          (ageRange['start'] as num?)?.toDouble() ?? 18.0,
          (ageRange['end'] as num?)?.toDouble() ?? 65.0,
        );
      }

      final interested = state['interestedIn'] as List?;
      if (interested != null) {
        _interestedIn = List<Map<String, dynamic>>.from(interested);
      }

      print('🔍 Filter state imported successfully');
    } catch (e) {
      print('❌ Error importing filter state: $e');
      resetFilters(); // Fallback to defaults
    }
  }
}
