import '../models/category_model.dart';

/// Repository interface for category data operations
abstract class CategoryRepository {
  /// Fetch all active categories from the data source
  Future<List<CategoryModel>> fetchCategories();

  /// Fetch a specific category by ID
  Future<CategoryModel?> getCategoryById(String categoryId);

  /// Search categories by name or description
  Future<List<CategoryModel>> searchCategories(String query);

  /// Check if a category exists
  Future<bool> categoryExists(String categoryId);

  /// Get categories count
  Future<int> getCategoriesCount();
}
