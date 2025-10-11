import 'package:flutter/material.dart';
import '../../domain/services/categories_service.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/models/category_model.dart';
import '../../core/utils/my_strings.dart';
import '../../view/components/snack_bar/show_custom_snackbar.dart';

/// Implementation of CategoriesService for categories business logic
class CategoriesServiceImpl implements CategoriesService {
  final CategoryRepository _categoryRepository;

  CategoriesServiceImpl({
    required CategoryRepository categoryRepository,
  }) : _categoryRepository = categoryRepository;

  // =========================
  // STATE VARIABLES
  // =========================

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  List<CategoryModel> _categories = [];

  // Callback for UI updates
  VoidCallback? _onStateChanged;

  // =========================
  // STATE GETTERS
  // =========================

  @override
  bool get isLoading => _isLoading;

  @override
  bool get hasError => _hasError;

  @override
  String? get errorMessage => _errorMessage;

  @override
  List<CategoryModel> get categories => List.unmodifiable(_categories);

  @override
  List<CategoryModel> get activeCategories =>
      _categories.where((category) => category.isActive).toList();

  @override
  int get categoriesCount => _categories.length;

  @override
  int get activeCategoriesCount => activeCategories.length;

  @override
  bool get areCategoriesLoaded => _categories.isNotEmpty;

  // =========================
  // CATEGORY OPERATIONS
  // =========================

  @override
  Future<void> loadCategories() async {
    try {
      final stopwatch = Stopwatch()..start();
      print("🔄 CategoriesService: Starting loadCategories...");

      _setLoading(true);
      _clearError();

      _categories = await _categoryRepository.fetchCategories();

      stopwatch.stop();
      print(
          "✅ CategoriesService: Loaded ${_categories.length} categories in ${stopwatch.elapsedMilliseconds}ms");

      _notifyStateChanged();
    } catch (e) {
      print("❌ CategoriesService: Error loading categories: $e");
      _setError('Failed to load categories: $e');
      CustomSnackBar.errorDeferred(errorList: ['Failed to load categories']);
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> refreshCategories() async {
    try {
      print("🔄 CategoriesService: Refreshing categories...");

      _setLoading(true);
      _clearError();

      _categories = await _categoryRepository.fetchCategories();

      print("✅ CategoriesService: Refreshed ${_categories.length} categories");
      CustomSnackBar.successDeferred(successList: ['Categories updated']);

      _notifyStateChanged();
    } catch (e) {
      print("❌ CategoriesService: Error refreshing categories: $e");
      _setError('Failed to refresh categories: $e');
      CustomSnackBar.errorDeferred(errorList: ['Failed to refresh categories']);
    } finally {
      _setLoading(false);
    }
  }

  @override
  CategoryModel? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      print("⚠️ CategoriesService: Category not found: $categoryId");
      return null;
    }
  }

  @override
  SubcategoryModel? getSubcategoryById(
      String categoryId, String subcategoryId) {
    try {
      final category = getCategoryById(categoryId);
      if (category == null) return null;

      return category.subcategories
          .firstWhere((subcategory) => subcategory.id == subcategoryId);
    } catch (e) {
      print(
          "⚠️ CategoriesService: Subcategory not found: $categoryId.$subcategoryId");
      return null;
    }
  }

  @override
  Future<List<CategoryModel>> searchCategories(String query) async {
    try {
      print("🔍 CategoriesService: Searching categories with query: $query");

      if (query.trim().isEmpty) {
        return activeCategories;
      }

      // First try to search in loaded categories
      final localResults = _categories
          .where((category) =>
              category.isActive &&
              (category.name.toLowerCase().contains(query.toLowerCase()) ||
                  category.description
                      .toLowerCase()
                      .contains(query.toLowerCase())))
          .toList();

      // If we have results locally or no network connection needed, return local results
      if (localResults.isNotEmpty || _categories.isNotEmpty) {
        print(
            "✅ CategoriesService: Found ${localResults.length} categories locally");
        return localResults;
      }

      // Otherwise, search in repository
      final results = await _categoryRepository.searchCategories(query);
      print(
          "✅ CategoriesService: Found ${results.length} categories from repository");
      return results;
    } catch (e) {
      print("❌ CategoriesService: Error searching categories: $e");
      _setError('Failed to search categories: $e');
      return [];
    }
  }

  // =========================
  // UTILITY METHODS
  // =========================

  @override
  String getCategoryColor(String categoryId) {
    final category = getCategoryById(categoryId);
    if (category != null) {
      return category.color;
    }
    return 'primary'; // fallback color key
  }

  @override
  String getCategoryName(String categoryId) {
    final category = getCategoryById(categoryId);
    if (category != null) {
      return category.name;
    }
    return MyStrings.categoryNotAvailable;
  }

  @override
  bool isValidCategorySelection(String? categoryId, String? subcategoryId) {
    if (categoryId == null) return false;

    final category = getCategoryById(categoryId);
    if (category == null || !category.isActive) return false;

    if (subcategoryId != null) {
      final subcategory = getSubcategoryById(categoryId, subcategoryId);
      return subcategory != null;
    }

    return true;
  }

  @override
  void setStateChangeCallback(void Function()? callback) {
    _onStateChanged = callback;
  }

  // =========================
  // PRIVATE METHODS
  // =========================

  void _setLoading(bool loading) {
    _isLoading = loading;
    _notifyStateChanged();
  }

  void _setError(String error) {
    _hasError = true;
    _errorMessage = error;
    _notifyStateChanged();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = null;
  }

  void _notifyStateChanged() {
    _onStateChanged?.call();
  }

  /// Dispose method for cleanup
  void dispose() {
    _onStateChanged = null;
    _categories.clear();
  }
}
