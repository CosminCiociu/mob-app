import '../data/repositories/firebase_users_repository.dart';
import '../domain/repositories/users_repository.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final UsersRepository _usersRepository = FirebaseUsersRepository();

  // Cache for user display names to avoid repeated API calls
  final Map<String, String> _userDisplayNameCache = {};

  /// Get user's display name by user ID
  Future<String> getUserDisplayName(String userId) async {
    // Check cache first
    if (_userDisplayNameCache.containsKey(userId)) {
      return _userDisplayNameCache[userId]!;
    }

    try {
      final userDoc = await _usersRepository.getUserById(userId);

      if (userDoc != null && userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          // Try to get displayName first, then fallback to firstname + lastname
          String displayName = userData['displayName']?.toString() ?? '';

          if (displayName.isEmpty) {
            final firstName = userData['firstName']?.toString() ?? '';
            final lastName = userData['lastName']?.toString() ?? '';

            if (firstName.isNotEmpty || lastName.isNotEmpty) {
              displayName = '$firstName $lastName'.trim();
            }
          }

          // If still empty, try username or email
          if (displayName.isEmpty) {
            displayName = userData['username']?.toString() ??
                userData['email']?.toString() ??
                'Unknown User';
          }

          // Cache the result
          _userDisplayNameCache[userId] = displayName;
          return displayName;
        }
      }

      // Fallback if user not found
      const fallbackName = 'Unknown User';
      _userDisplayNameCache[userId] = fallbackName;
      return fallbackName;
    } catch (e) {
      // On error, return fallback and cache it
      const fallbackName = 'Unknown User';
      _userDisplayNameCache[userId] = fallbackName;
      return fallbackName;
    }
  }

  /// Clear the cache (useful for refreshing user data)
  void clearCache() {
    _userDisplayNameCache.clear();
  }

  /// Clear specific user from cache
  void clearUserFromCache(String userId) {
    _userDisplayNameCache.remove(userId);
  }
}
