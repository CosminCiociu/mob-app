import 'package:get/get.dart';
import '../../../domain/repositories/events_repository.dart';
import '../../../data/repositories/firebase_events_repository.dart';
import '../../../core/utils/my_strings.dart';

class EventMembersController extends GetxController {
  late EventsRepository _eventsRepository;

  // Observable variables
  var confirmedMembers = <Map<String, dynamic>>[].obs;
  var pendingMembers = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var eventId = ''.obs;
  var currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _eventsRepository = FirebaseEventsRepository();

    // Get arguments passed to the screen
    final args = Get.arguments;
    if (args != null && args is Map<String, String>) {
      eventId.value = args['eventId'] ?? '';
      currentUserId.value = args['currentUserId'] ?? '';

      if (eventId.value.isNotEmpty) {
        loadEventMembers();
      }
    }
  }

  /// Load event members from Firebase
  Future<void> loadEventMembers() async {
    try {
      isLoading.value = true;

      final members = await _eventsRepository.getEventMembers(
        eventId: eventId.value,
      );

      confirmedMembers.value = members['confirmed'] ?? [];
      pendingMembers.value = members['pending'] ?? [];
    } catch (e) {
      Get.snackbar(
        MyStrings.error,
        'Failed to load event members: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Accept a pending member
  Future<void> acceptMember(String userId) async {
    try {
      await _eventsRepository.acceptMember(
        eventId: eventId.value,
        userId: userId,
        currentUserId: currentUserId.value,
      );

      // Find the member in pending list and move to confirmed
      final memberIndex =
          pendingMembers.indexWhere((member) => member['id'] == userId);
      if (memberIndex != -1) {
        final member = pendingMembers[memberIndex];
        pendingMembers.removeAt(memberIndex);
        confirmedMembers.add(member);
      }

      Get.snackbar(
        MyStrings.success,
        MyStrings.memberAccepted,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        MyStrings.error,
        'Failed to accept member: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Decline a pending member
  Future<void> declineMember(String userId) async {
    try {
      await _eventsRepository.declineMember(
        eventId: eventId.value,
        userId: userId,
        currentUserId: currentUserId.value,
      );

      // Remove the member from pending list
      pendingMembers.removeWhere((member) => member['id'] == userId);

      Get.snackbar(
        MyStrings.success,
        MyStrings.memberDeclined,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        MyStrings.error,
        'Failed to decline member: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Start a message conversation with a member
  void messageMember(Map<String, dynamic> member) {
    // TODO: Implement messaging functionality
    // This could navigate to a chat screen or open a messaging interface
    Get.snackbar(
      MyStrings.message,
      '${MyStrings.openingChatWith} ${member['displayName'] ?? member['email']}',
      snackPosition: SnackPosition.BOTTOM,
    );

    // For future implementation, this could navigate to:
    // Get.toNamed('/chat', arguments: {
    //   'recipientId': member['id'],
    //   'recipientName': member['displayName'],
    //   'recipientEmail': member['email'],
    // });
  }

  /// Get total members count
  int get totalMembersCount => confirmedMembers.length + pendingMembers.length;

  /// Check if there are any members
  bool get hasMembers => totalMembersCount > 0;

  /// Check if there are confirmed members
  bool get hasConfirmedMembers => confirmedMembers.isNotEmpty;

  /// Check if there are pending members
  bool get hasPendingMembers => pendingMembers.isNotEmpty;
}
