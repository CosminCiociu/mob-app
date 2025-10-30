import 'package:get/get.dart';
import '../../../domain/services/attending_events_service.dart';
import '../../../data/services/attending_events_service_impl.dart';

class AttendingEventsController extends GetxController {
  // Service instance
  late AttendingEventsService _attendingEventsService;

  @override
  void onInit() {
    super.onInit();
    // Initialize service
    _attendingEventsService = AttendingEventsServiceImpl();

    // Set up state change callback
    _attendingEventsService.setStateChangeCallback(() {
      update();
    });

    // Initial data fetch
    fetchAttendingEvents();
  }

  // Delegate getters to service
  bool get isLoading => _attendingEventsService.isLoading;
  bool get isRefreshing => _attendingEventsService.isRefreshing;
  String get errorMessage => _attendingEventsService.errorMessage;
  AttendingEventTab get currentTab => _attendingEventsService.currentTab;

  List<Map<String, dynamic>> get upcomingEvents =>
      _attendingEventsService.upcomingEvents;
  List<Map<String, dynamic>> get activeEvents =>
      _attendingEventsService.activeEvents;
  List<Map<String, dynamic>> get pastEvents =>
      _attendingEventsService.pastEvents;
  List<Map<String, dynamic>> get pendingEvents =>
      _attendingEventsService.pendingEvents;

  List<Map<String, dynamic>> get currentTabEvents =>
      _attendingEventsService.currentTabEvents;
  bool get hasAnyEvents => _attendingEventsService.hasAnyEvents;
  int get totalEventsCount => _attendingEventsService.totalEventsCount;
  String get currentTabTitle => _attendingEventsService.currentTabTitle;

  // Delegate methods to service
  void switchTab(AttendingEventTab tab) {
    _attendingEventsService.switchTab(tab);
  }

  Future<void> fetchAttendingEvents() async {
    await _attendingEventsService.fetchAttendingEvents();
  }

  Future<void> refreshEvents() async {
    await _attendingEventsService.refreshEvents();
  }

  Future<void> leaveEvent(String eventId) async {
    await _attendingEventsService.leaveEvent(eventId);
  }

  Future<void> toggleReminder(String eventId, bool currentStatus) async {
    await _attendingEventsService.toggleReminder(eventId, currentStatus);
  }
}
