import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/services/categories_service.dart';
import '../../../domain/models/category_model.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/my_color.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';

/// Categories controller using clean architecture with services
///
/// This controller focuses on UI coordination and delegates business logic
/// to the CategoriesService, following the same pattern as HomeController.
class CategoriesController extends GetxController {
  // =========================
  // DEPENDENCIES
  // =========================

  late final CategoriesService _categoriesService;

  // =========================
  // UI CONTROLLERS
  // =========================

  final TextEditingController searchController = TextEditingController();

  // =========================
  // LIFECYCLE METHODS
  // =========================

  @override
  void onInit() {
    super.onInit();
    print("🚀 CategoriesController: Initializing...");
    _initializeServices();
    _loadInitialData();
    print("✅ CategoriesController: Initialization complete");
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // =========================
  // INITIALIZATION
  // =========================

  void _initializeServices() {
    try {
      _categoriesService = Get.find<CategoriesService>();
      _setupServiceCallback();
      print("🔗 CategoriesController: Service callback set up");
    } catch (e) {
      print("❌ CategoriesController: Failed to initialize services: $e");
      CustomSnackBar.errorDeferred(
          errorList: ['Failed to initialize categories: ${e.toString()}']);
    }
  }

  void _setupServiceCallback() {
    _categoriesService.setStateChangeCallback(() => update());
  }

  void _loadInitialData() {
    // Load categories silently during initialization (no snackbars on init)
    _loadCategoriesQuietly();
  }

  /// Load categories silently during initialization (no snackbars)
  Future<void> _loadCategoriesQuietly() async {
    try {
      await _categoriesService.loadCategories();
    } catch (e) {
      // Log error but don't show snackbar during initialization
      print('Failed to load categories during initialization: $e');
    }
  }

  // =========================
  // SERVICE DELEGATES - STATE GETTERS
  // =========================

  /// Loading state
  bool get isLoading => _categoriesService.isLoading;

  /// Error state
  bool get hasError => _categoriesService.hasError;
  String? get errorMessage => _categoriesService.errorMessage;

  /// Categories data
  List<CategoryModel> get categories => _categoriesService.categories;
  List<CategoryModel> get activeCategories =>
      _categoriesService.activeCategories;

  /// Counts
  int get categoriesCount => _categoriesService.categoriesCount;
  int get activeCategoriesCount => _categoriesService.activeCategoriesCount;

  /// Status checks
  bool get areCategoriesLoaded => _categoriesService.areCategoriesLoaded;

  // =========================
  // SERVICE DELEGATES - ACTIONS
  // =========================

  /// Load categories from service
  Future<void> loadCategories() async {
    await _categoriesService.loadCategories();
  }

  /// Refresh categories data
  Future<void> refreshCategories() async {
    await _categoriesService.refreshCategories();
  }

  /// Get category by ID
  CategoryModel? getCategoryById(String categoryId) {
    return _categoriesService.getCategoryById(categoryId);
  }

  /// Get subcategory by IDs
  SubcategoryModel? getSubcategoryById(
      String categoryId, String subcategoryId) {
    return _categoriesService.getSubcategoryById(categoryId, subcategoryId);
  }

  /// Search categories
  Future<List<CategoryModel>> searchCategories(String query) async {
    return await _categoriesService.searchCategories(query);
  }

  // =========================
  // UTILITY METHODS
  // =========================

  /// Get category color using MyColor system
  Color getCategoryColor(String categoryId) {
    final colorKey = _categoriesService.getCategoryColor(categoryId);
    return MyColor.getHobbyColor(colorKey);
  }

  /// Get category name
  String getCategoryName(String categoryId) {
    return _categoriesService.getCategoryName(categoryId);
  }

  /// Get subcategory name
  String getSubcategoryName(String categoryId, String subcategoryId) {
    final subcategory = getSubcategoryById(categoryId, subcategoryId);
    return subcategory?.name ?? MyStrings.categoryNotAvailable;
  }

  /// Validate category selection
  bool isValidCategorySelection(String? categoryId, String? subcategoryId) {
    return _categoriesService.isValidCategorySelection(
        categoryId, subcategoryId);
  }

  /// Get category icon path
  String getCategoryIcon(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.icon ?? 'default.svg';
  }

  /// Get category description
  String getCategoryDescription(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.description ?? '';
  }

  // =========================
  // UI INTERACTION METHODS
  // =========================

  /// Handle search input
  void onSearchChanged(String query) {
    // Debounce search if needed
    searchCategories(query);
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    update();
  }

  /// Handle pull-to-refresh
  Future<void> onRefresh() async {
    await refreshCategories();
  }

  /// Handle retry on error
  Future<void> onRetry() async {
    await loadCategories();
  }

  // =========================
  // CATEGORY SELECTION HELPERS
  // =========================

  /// Convert domain model to dropdown model for backward compatibility
  List<Category> get dropdownCategories {
    return activeCategories.map((categoryModel) {
      return Category(
        id: categoryModel.id,
        name: categoryModel.name,
        description: categoryModel.description,
        icon: categoryModel.icon,
        color: categoryModel.color,
        subcategories: categoryModel.subcategories.map((subcategoryModel) {
          return Subcategory(
            id: subcategoryModel.id,
            name: subcategoryModel.name,
            description: subcategoryModel.description,
          );
        }).toList(),
      );
    }).toList();
  }

  /// Get formatted category display text
  String getFormattedCategoryText(String categoryId, String? subcategoryId) {
    final categoryName = getCategoryName(categoryId);
    if (subcategoryId != null) {
      final subcategoryName = getSubcategoryName(categoryId, subcategoryId);
      if (subcategoryName != MyStrings.categoryNotAvailable) {
        return '$categoryName • $subcategoryName';
      }
    }
    return categoryName;
  }

  // =========================
  // DEBUGGING METHODS
  // =========================

  /// Print categories summary for debugging
  void printCategoriesSummary() {
    print("📊 Categories Summary:");
    print("   Total: $categoriesCount");
    print("   Active: $activeCategoriesCount");
    print("   Loaded: $areCategoriesLoaded");
    print("   Loading: $isLoading");
    print("   Has Error: $hasError");

    if (categories.isNotEmpty) {
      print("   Categories:");
      for (final category in categories.take(3)) {
        print(
            "     • ${category.name} (${category.subcategories.length} subcategories)");
      }
      if (categories.length > 3) {
        print("     • ... and ${categories.length - 3} more");
      }
    }
  }
}

// =========================
// BACKWARD COMPATIBILITY MODELS
// =========================

/// Keep existing Category class for backward compatibility
class Category {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final List<Subcategory> subcategories;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.subcategories,
  });
}

/// Keep existing Subcategory class for backward compatibility
class Subcategory {
  final String id;
  final String name;
  final String description;

  Subcategory({
    required this.id,
    required this.name,
    required this.description,
  });
}
