import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/services/matching_service.dart';
import '../../domain/repositories/events_repository.dart';
import '../../domain/repositories/users_repository.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/my_strings.dart';
import '../../core/utils/dimensions.dart';
import '../../view/components/snack_bar/show_custom_snackbar.dart';

/// Concrete implementation of MatchingService for matching and discovery operations
class MatchingServiceImpl implements MatchingService {
  final EventsRepository _eventsRepository;
  final UsersRepository _usersRepository;

  MatchingServiceImpl({
    required EventsRepository eventsRepository,
    required UsersRepository usersRepository,
  })  : _eventsRepository = eventsRepository,
        _usersRepository = usersRepository;

  @override
  Future<List<DocumentSnapshot>> searchNearbyEvents({
    required double radiusInKm,
    required String? currentUserId,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception(MyStrings.userNotLoggedIn);
      }

      // Validate search radius
      if (!isValidSearchRadius(radiusInKm)) {
        throw Exception(
            'Invalid search radius: ${radiusInKm}km. Must be between ${Dimensions.minSearchRadius}km and ${Dimensions.maxSearchRadius}km.');
      }

      // Get user location
      final userLocation = await LocationService.getUserLocationFromFirebase();
      if (userLocation == null) {
        throw Exception(MyStrings.userLocationNotFound);
      }

      final userGeoPoint = userLocation.geopoint;
      final userGeohash = userLocation.geohash;

      // Try geohash-based search first, fallback to manual if needed
      final events = await _eventsRepository.fetchNearbyEvents(
        userLocation: userGeoPoint,
        userGeohash: userGeohash,
        radiusInKm: radiusInKm,
        currentUserId: currentUserId,
      );

      return events;
    } catch (e) {
      String errorMessage = getDetailedErrorMessage(e);
      CustomSnackBar.errorDeferred(errorList: [errorMessage]);
      return [];
    }
  }

  @override
  Future<List<DocumentSnapshot>> searchNearbyEventsQuietly({
    required double radiusInKm,
    required String? currentUserId,
  }) async {
    try {
      if (currentUserId == null) {
        return []; // Return empty list quietly instead of throwing
      }

      // Validate search radius
      if (!isValidSearchRadius(radiusInKm)) {
        print('Invalid search radius: ${radiusInKm}km. Using default.');
        radiusInKm = Dimensions.defaultSearchRadius.toDouble();
      }

      // Get user location - if not available, return empty list quietly
      final userLocation = await LocationService.getUserLocationFromFirebase();
      if (userLocation == null) {
        print('User location not found, returning empty events list');
        return []; // Return empty list instead of throwing exception
      }

      final userGeoPoint = userLocation.geopoint;
      final userGeohash = userLocation.geohash;

      // Quietly search for events without showing snackbars
      final events = await _eventsRepository.fetchNearbyEvents(
        userLocation: userGeoPoint,
        userGeohash: userGeohash,
        radiusInKm: radiusInKm,
        currentUserId: currentUserId,
      );

      return events;
    } catch (e) {
      // Log error silently without showing snackbar
      print('Failed to search nearby events quietly: $e');
      return [];
    }
  }

  @override
  Future<List<DocumentSnapshot>> searchNearbyUsers({
    required double radiusInKm,
    required String? currentUserId,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception(MyStrings.userNotLoggedIn);
      }

      // Get user location
      final userLocation = await LocationService.getUserLocationFromFirebase();
      if (userLocation == null) {
        throw Exception(MyStrings.userLocationNotFound);
      }

      final userGeoPoint = userLocation.geopoint;

      // Show loading feedback
      CustomSnackBar.successDeferred(successList: [
        '${MyStrings.searchingForUsers} within ${radiusInKm}km...'
      ]);

      final users = await _usersRepository.getNearbyUsers(
        currentUserId: currentUserId,
        userLocation: userGeoPoint,
        radiusInKm: radiusInKm,
      );

      // Show results to user
      if (users.isEmpty) {
        CustomSnackBar.errorDeferred(errorList: [MyStrings.noUsersFoundInArea]);
      } else {
        CustomSnackBar.successDeferred(successList: [
          '${users.length} ${MyStrings.usersFoundNearby} within ${radiusInKm}km'
        ]);
      }

      return users;
    } catch (e) {
      String errorMessage = getDetailedErrorMessage(e);
      CustomSnackBar.errorDeferred(errorList: [errorMessage]);
      return [];
    }
  }

  @override
  Future<void> updateLocationAndRefresh() async {
    try {
      // Update Firebase with the location data
      await LocationService.updateUserLocationInFirebase();

      // Show success feedback
      CustomSnackBar.successDeferred(
          successList: [MyStrings.locationUpdatedSuccessfully]);
    } catch (e) {
      // Show error feedback with detailed message
      String errorMessage = e.toString().contains('Permission')
          ? 'Location permission denied. Please enable location access.'
          : e.toString().contains('Service')
              ? 'Location service disabled. Please enable GPS.'
              : '${MyStrings.failedToUpdateLocation}: ${e.toString()}';

      CustomSnackBar.errorDeferred(errorList: [errorMessage]);
    }
  }

  @override
  Future<void> demonstrateGeohashFeatures() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(MyStrings.userNotLoggedIn);
      }

      // Update current user's location with geohash
      await updateLocationAndRefresh();

      // Get nearby users within the default distance
      final nearbyUsers = await _usersRepository.getUsersInDistanceRange(
        currentUserId: user.uid,
        distance: Dimensions.defaultSearchRadius,
      );

      // Show meaningful feedback about the results
      if (nearbyUsers.isNotEmpty) {
        CustomSnackBar.successDeferred(successList: [
          'Geohash demo: Found ${nearbyUsers.length} users nearby'
        ]);
      } else {
        CustomSnackBar.errorDeferred(
            errorList: ['Geohash demo: No users found nearby']);
      }
    } catch (e) {
      String errorMessage = getDetailedErrorMessage(e);
      CustomSnackBar.errorDeferred(
          errorList: ['Geohash demo failed: $errorMessage']);
    }
  }

  @override
  String getDetailedErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('internet') ||
        errorString.contains('connection')) {
      return MyStrings.connectionError;
    } else if (errorString.contains('permission')) {
      return 'Location permission required. Please enable location access in settings.';
    } else if (errorString.contains('location') &&
        errorString.contains('service')) {
      return 'Location service is disabled. Please enable GPS.';
    } else if (errorString.contains('firebase') ||
        errorString.contains('firestore')) {
      return 'Database connection error. Please try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else {
      return '${MyStrings.unexpectedError}: ${error.toString()}';
    }
  }

  @override
  bool isValidSearchRadius(double radius) {
    return radius >= Dimensions.minSearchRadius &&
        radius <= Dimensions.maxSearchRadius;
  }

  @override
  Future<void> handleEventLike({
    required String eventId,
    required String userId,
  }) async {
    try {
      // Get current user's display name for notification
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception(MyStrings.userNotLoggedIn);
      }

      // Get user information from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userData = userDoc.data();
      final userName = userData?['displayName'] ??
          userData?['firstName'] ??
          userData?['name'] ??
          'Someone';

      // Get event information
      final eventDoc = await FirebaseFirestore.instance
          .collection('users_events')
          .doc(eventId)
          .get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final eventName = eventData['eventName'] ?? 'Untitled Event';
      final eventCreatorId = eventData['createdBy'];

      if (eventCreatorId == null) {
        throw Exception('Event creator not found');
      }

      // Add user to event's liked users list
      await _eventsRepository.likeEvent(
        eventId: eventId,
        userId: userId,
      );

      // Create notification for event organizer
      await _eventsRepository.createEventLikeNotification(
        eventId: eventId,
        eventCreatorId: eventCreatorId,
        likerUserId: userId,
        likerName: userName,
        eventName: eventName,
      );
    } catch (e) {
      // CustomSnackBar.errorDeferred(
      //     errorList: ['Failed to like event: ${getDetailedErrorMessage(e)}']);
    }
  }

  @override
  Future<void> handleEventDecline({
    required String eventId,
    required String userId,
  }) async {
    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception(MyStrings.userNotLoggedIn);
      }

      // Get event information for user feedback
      final eventDoc = await FirebaseFirestore.instance
          .collection('users_events')
          .doc(eventId)
          .get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final eventName = eventData['eventName'] ?? 'Untitled Event';

      // Add user to event's declined users list
      await _eventsRepository.declineEvent(
        eventId: eventId,
        userId: userId,
      );

      // Show subtle feedback to user (no notification to organizer for declines)
      print(
          '✅ Event "$eventName" declined successfully. It won\'t appear again.');
    } catch (e) {
      print('❌ Failed to decline event: ${getDetailedErrorMessage(e)}');
      // Don't show error snackbar for declines to keep UI clean
    }
  }
}
