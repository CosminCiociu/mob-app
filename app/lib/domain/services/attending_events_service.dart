/// Enum for attending event tabs
enum AttendingEventTab { upcoming, active, past, pending }

/// Service interface for attending events business logic
abstract class AttendingEventsService {
  // State getters
  bool get isLoading;
  bool get isRefreshing;
  String get errorMessage;
  AttendingEventTab get currentTab;

  // Event lists getters
  List<Map<String, dynamic>> get upcomingEvents;
  List<Map<String, dynamic>> get activeEvents;
  List<Map<String, dynamic>> get pastEvents;
  List<Map<String, dynamic>> get pendingEvents;
  List<Map<String, dynamic>> get currentTabEvents;

  // Computed properties
  bool get hasAnyEvents;
  int get totalEventsCount;
  String get currentTabTitle;

  // State setters
  void setLoading(bool loading);
  void setRefreshing(bool refreshing);
  void setErrorMessage(String message);

  // Tab operations
  void switchTab(AttendingEventTab tab);

  // Event operations
  Future<void> fetchAttendingEvents();
  Future<void> refreshEvents();
  Future<void> leaveEvent(String eventId);
  Future<void> toggleReminder(String eventId, bool currentStatus);

  // Utility operations
  void clearAllEvents();

  // Callback operations
  void setStateChangeCallback(void Function()? callback);
}
