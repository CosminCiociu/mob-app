import 'package:intl/intl.dart';
import '../helper/date_converter.dart';

/// Utility class for formatting event-related data
class EventFormatter {
  // Private constructor to prevent instantiation
  EventFormatter._();

  /// Format event date and time for display
  /// Returns formatted date with time, e.g., "15 Oct 2025, 09:49 PM"
  static String formatEventDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Date TBD';
    }

    try {
      // Try to parse the ISO string
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      // Fallback to existing date converter if available
      try {
        return DateConverter.convertIsoToString(dateTimeString);
      } catch (e2) {
        return 'Date TBD';
      }
    }
  }

  /// Format event date only (without time)
  /// Returns formatted date, e.g., "15 Oct 2025"
  static String formatEventDateOnly(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Date TBD';
    }

    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return 'Date TBD';
    }
  }

  /// Format event time only
  /// Returns formatted time, e.g., "09:49 PM"
  static String formatEventTimeOnly(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Time TBD';
    }

    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return 'Time TBD';
    }
  }

  /// Format event location from location data
  /// Returns formatted location string or fallback text
  static String formatEventLocation(
      Map<String, dynamic>? locationData, String? locationName) {
    // First check if we have a location name
    if (locationName != null &&
        locationName.isNotEmpty &&
        locationName != 'null') {
      return locationName;
    }

    // Then check location data
    if (locationData != null) {
      // Check if it has address or name
      if (locationData['address'] != null &&
          locationData['address'].toString().isNotEmpty) {
        return locationData['address'].toString();
      }

      if (locationData['name'] != null &&
          locationData['name'].toString().isNotEmpty) {
        return locationData['name'].toString();
      }

      // Check for coordinates as fallback
      if (locationData['latitude'] != null &&
          locationData['longitude'] != null) {
        final lat = locationData['latitude'];
        final lng = locationData['longitude'];
        return 'Location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      }
    }

    return 'Location TBD';
  }

  /// Format event location for display with icon-friendly text
  /// Returns a shorter, user-friendly location string
  static String formatEventLocationShort(
      Map<String, dynamic>? locationData, String? locationName) {
    final fullLocation = formatEventLocation(locationData, locationName);

    if (fullLocation == 'Location TBD') {
      return fullLocation;
    }

    // If it's a coordinate display, keep it short
    if (fullLocation.startsWith('Location:')) {
      return 'Custom Location';
    }

    // Truncate long addresses
    if (fullLocation.length > 30) {
      return '${fullLocation.substring(0, 27)}...';
    }

    return fullLocation;
  }

  /// Format age range for display
  /// Returns formatted age range string or null if no limits
  static String? formatAgeRange(int? minAge, int? maxAge) {
    if (minAge == null && maxAge == null) {
      return null; // No age restrictions
    }

    if (minAge != null && maxAge != null) {
      if (minAge == maxAge) {
        return 'Age: $minAge';
      }
      return 'Age: $minAge-$maxAge';
    }

    if (minAge != null) {
      return 'Age: $minAge+';
    }

    if (maxAge != null) {
      return 'Age: Up to $maxAge';
    }

    return null;
  }

  /// Format max persons for display
  /// Returns formatted max persons string or null if no limit
  static String? formatMaxPersons(int? maxPersons) {
    if (maxPersons == null) {
      return null; // No limit
    }

    if (maxPersons == 1) {
      return '1 person max';
    }

    return '$maxPersons people max';
  }

  /// Format event status for display
  /// Returns a user-friendly status string
  static String formatEventStatus(String? status) {
    if (status == null || status.isEmpty) {
      return 'Active';
    }

    // Capitalize first letter
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  /// Format category display name
  /// Returns a user-friendly category name
  static String formatCategoryName(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return '';
    }

    // Convert category ID to display name
    switch (categoryId.toLowerCase()) {
      case 'entertainment':
        return 'ENTERTAINMENT';
      case 'leisure':
        return 'LEISURE';
      case 'food_drink':
        return 'FOOD & DRINK';
      case 'sports':
        return 'SPORTS';
      case 'business':
        return 'BUSINESS';
      case 'education':
        return 'EDUCATION';
      case 'health':
        return 'HEALTH';
      case 'social':
        return 'SOCIAL';
      default:
        return categoryId.toUpperCase();
    }
  }

  /// Get relative time (e.g., "2 hours ago", "in 3 days")
  /// Returns human-readable relative time string
  static String getRelativeTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '';
    }

    try {
      DateTime eventDateTime = DateTime.parse(dateTimeString);
      DateTime now = DateTime.now();
      Duration difference = eventDateTime.difference(now);

      if (difference.isNegative) {
        // Past event
        difference = difference.abs();
        if (difference.inDays > 0) {
          return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
        } else if (difference.inHours > 0) {
          return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
        } else {
          return 'Just now';
        }
      } else {
        // Future event
        if (difference.inDays > 0) {
          return 'In ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
        } else if (difference.inHours > 0) {
          return 'In ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
        } else if (difference.inMinutes > 0) {
          return 'In ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
        } else {
          return 'Starting now';
        }
      }
    } catch (e) {
      return '';
    }
  }

  /// Check if event is upcoming (in the future)
  static bool isUpcoming(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return false;
    }

    try {
      DateTime eventDateTime = DateTime.parse(dateTimeString);
      return eventDateTime.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Check if event is today
  static bool isToday(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return false;
    }

    try {
      DateTime eventDateTime = DateTime.parse(dateTimeString);
      DateTime now = DateTime.now();
      return eventDateTime.year == now.year &&
          eventDateTime.month == now.month &&
          eventDateTime.day == now.day;
    } catch (e) {
      return false;
    }
  }
}
