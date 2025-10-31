import '../../domain/repositories/category_repository.dart';
import '../../domain/models/category_model.dart';
import '../../core/utils/firebase_repository_base.dart';

/// Firebase implementation of CategoryRepository
class FirebaseCategoryRepository extends FirebaseRepositoryBase
    implements CategoryRepository {
  static const String _repositoryName = 'FirebaseCategoryRepository';

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    return FirebaseRepositoryBase.executeWithErrorHandling('fetch categories',
        () async {
      FirebaseRepositoryBase.logDebug(_repositoryName,
          'Fetching categories from ${FirebaseRepositoryBase.categoriesCollection}');

      final activeDocs = await FirebaseRepositoryBase.getActiveDocuments(
          FirebaseRepositoryBase.categoriesCollection);

      final categories = FirebaseRepositoryBase.convertDocumentsToModels(
        activeDocs,
        CategoryModel.fromMap,
      );

      // Sort by createdAt in-memory to avoid needing Firestore composite index
      final sortedCategories = FirebaseRepositoryBase.sortByCreatedAt(
        categories,
        (category) => category.createdAt,
      );

      FirebaseRepositoryBase.logInfo(
          _repositoryName, 'Fetched ${sortedCategories.length} categories');
      return sortedCategories;
    });
  }

  @override
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('get category by ID',
        () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Fetching category with ID: $categoryId');

      final categoryDoc = await FirebaseRepositoryBase.getDocumentById(
        FirebaseRepositoryBase.categoriesCollection,
        categoryId,
      );

      if (categoryDoc != null) {
        final data = FirebaseRepositoryBase.extractDocumentData(categoryDoc);
        final category = CategoryModel.fromMap(data);

        FirebaseRepositoryBase.logInfo(
            _repositoryName, 'Found category: ${category.name}');
        return category;
      }

      FirebaseRepositoryBase.logWarning(
          _repositoryName, 'Category not found: $categoryId');
      return null;
    });
  }

  @override
  Future<List<CategoryModel>> searchCategories(String query) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('search categories',
        () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Searching categories with query: $query');

      final activeDocs = await FirebaseRepositoryBase.getActiveDocuments(
          FirebaseRepositoryBase.categoriesCollection);

      final searchResults = FirebaseRepositoryBase.searchInDocuments(
        activeDocs,
        query,
        ['name', 'description'],
      );

      final categories = searchResults.map(CategoryModel.fromMap).toList();

      FirebaseRepositoryBase.logInfo(_repositoryName,
          'Found ${categories.length} categories matching "$query"');
      return categories;
    });
  }

  @override
  Future<bool> categoryExists(String categoryId) async {
    try {
      return await FirebaseRepositoryBase.documentExists(
        FirebaseRepositoryBase.categoriesCollection,
        categoryId,
      );
    } catch (e) {
      FirebaseRepositoryBase.logError(
          _repositoryName, 'Error checking category existence', e);
      return false;
    }
  }

  @override
  Future<int> getCategoriesCount() async {
    return FirebaseRepositoryBase.executeWithErrorHandling(
        'get categories count', () async {
      return await FirebaseRepositoryBase.getCollectionCount(
        FirebaseRepositoryBase.categoriesCollection,
        whereConditions: {'isActive': true},
      );
    });
  }
}
