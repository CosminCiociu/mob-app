import 'package:get/get.dart';
import '../../domain/repositories/events_repository.dart';
import '../../domain/repositories/users_repository.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/services/home_service.dart';
import '../../domain/services/matching_service.dart';
import '../../domain/services/events_service.dart';
import '../../domain/services/categories_service.dart';
import '../../data/repositories/firebase_events_repository.dart';
import '../../data/repositories/firebase_users_repository.dart';
import '../../data/repositories/firebase_event_repository.dart';
import '../../data/repositories/firebase_category_repository.dart';
import '../../data/repositories/image_picker_repository.dart';
import '../../data/services/home_service_impl.dart';
import '../../data/services/matching_service_impl.dart';
import '../../data/services/events_service_impl.dart';
import '../../data/services/categories_service_impl.dart';
import '../../data/controller/categories/categories_controller.dart';

/// Dependency injection configuration for services and repositories
class DependencyInjection {
  /// Initialize all dependencies for the application
  static void init() {
    // Register repositories
    Get.put<EventsRepository>(FirebaseEventsRepository(), permanent: true);
    Get.put<UsersRepository>(FirebaseUsersRepository(), permanent: true);
    Get.put<EventRepository>(FirebaseEventRepository(), permanent: true);
    Get.put<ImageRepository>(ImagePickerRepository(), permanent: true);
    Get.put<CategoryRepository>(FirebaseCategoryRepository(), permanent: true);

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

    Get.put<EventsService>(
      EventsServiceImpl(
        eventRepository: Get.find<EventRepository>(),
        imageRepository: Get.find<ImageRepository>(),
      ),
      permanent: true,
    );

    Get.put<CategoriesService>(
      CategoriesServiceImpl(
        categoryRepository: Get.find<CategoryRepository>(),
      ),
      permanent: true,
    );

    // Register controllers
    Get.put<CategoriesController>(
      CategoriesController(),
      permanent: true,
    );
  }

  /// Clean up all dependencies (useful for testing)
  static void dispose() {
    Get.delete<CategoriesController>();
    Get.delete<CategoriesService>();
    Get.delete<CategoryRepository>();
    Get.delete<HomeService>();
    Get.delete<MatchingService>();
    Get.delete<EventsService>();
    Get.delete<EventsRepository>();
    Get.delete<UsersRepository>();
    Get.delete<EventRepository>();
    Get.delete<ImageRepository>();
  }
}
