import 'package:get/get.dart';
import '../../domain/repositories/events_repository.dart';
import '../../domain/repositories/users_repository.dart';
import '../../domain/services/home_service.dart';
import '../../domain/services/matching_service.dart';
import '../../data/repositories/firebase_events_repository.dart';
import '../../data/repositories/firebase_users_repository.dart';
import '../../data/services/home_service_impl.dart';
import '../../data/services/matching_service_impl.dart';

/// Dependency injection configuration for services and repositories
class DependencyInjection {
  /// Initialize all dependencies for the application
  static void init() {
    // Register repositories
    Get.put<EventsRepository>(FirebaseEventsRepository(), permanent: true);
    Get.put<UsersRepository>(FirebaseUsersRepository(), permanent: true);

    // Register services with dependencies
    Get.put<MatchingService>(
      MatchingServiceImpl(
        eventsRepository: Get.find<EventsRepository>(),
        usersRepository: Get.find<UsersRepository>(),
      ),
      permanent: true,
    );

    Get.put<HomeService>(
      HomeServiceImpl(),
      permanent: true,
    );
  }

  /// Clean up all dependencies (useful for testing)
  static void dispose() {
    Get.delete<HomeService>();
    Get.delete<MatchingService>();
    Get.delete<EventsRepository>();
    Get.delete<UsersRepository>();
  }
}
