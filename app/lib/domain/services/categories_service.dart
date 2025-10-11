import '../models/category_model.dart';

/// Service interface for categories business logic
abstract class CategoriesService {
  /// State getters
  bool get isLoading;
  bool get hasError;
  String? get errorMessage;
  List<CategoryModel> get categories;
  List<CategoryModel> get activeCategories;

  /// Load all categories from repository
  Future<void> loadCategories();

  /// Refresh categories data
  Future<void> refreshCategories();

  /// Get category by ID
  CategoryModel? getCategoryById(String categoryId);

  /// Get subcategory by category and subcategory IDs
  SubcategoryModel? getSubcategoryById(String categoryId, String subcategoryId);

  /// Search categories by query
  Future<List<CategoryModel>> searchCategories(String query);

  /// Get categories count
  int get categoriesCount;

  /// Get active categories count
  int get activeCategoriesCount;

  /// Check if categories are loaded
  bool get areCategoriesLoaded;

  /// Get category color by ID
  String getCategoryColor(String categoryId);

  /// Get category name by ID
  String getCategoryName(String categoryId);

  /// Validate category selection
  bool isValidCategorySelection(String? categoryId, String? subcategoryId);

  /// Set state change callback for UI updates
  void setStateChangeCallback(void Function()? callback);
}
