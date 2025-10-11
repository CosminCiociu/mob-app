import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/models/category_model.dart';

/// Firebase implementation of CategoryRepository
class FirebaseCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      print(
          "🔄 FirebaseCategoryRepository: Fetching categories from $_collection");

      final QuerySnapshot categoriesSnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final categories = categoriesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        return CategoryModel.fromMap(data);
      }).toList();

      // Sort by createdAt in-memory to avoid needing Firestore composite index
      categories.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      print(
          "✅ FirebaseCategoryRepository: Fetched ${categories.length} categories");
      return categories;
    } catch (e) {
      print("❌ FirebaseCategoryRepository: Error fetching categories: $e");
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      print(
          "🔍 FirebaseCategoryRepository: Fetching category with ID: $categoryId");

      final DocumentSnapshot categoryDoc =
          await _firestore.collection(_collection).doc(categoryId).get();

      if (categoryDoc.exists) {
        final data = categoryDoc.data() as Map<String, dynamic>;
        data['id'] = categoryDoc.id;
        final category = CategoryModel.fromMap(data);

        print("✅ FirebaseCategoryRepository: Found category: ${category.name}");
        return category;
      }

      print("⚠️ FirebaseCategoryRepository: Category not found: $categoryId");
      return null;
    } catch (e) {
      print(
          "❌ FirebaseCategoryRepository: Error fetching category $categoryId: $e");
      throw Exception('Failed to fetch category: $e');
    }
  }

  @override
  Future<List<CategoryModel>> searchCategories(String query) async {
    try {
      print(
          "🔍 FirebaseCategoryRepository: Searching categories with query: $query");

      final QuerySnapshot categoriesSnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final categories = categoriesSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return CategoryModel.fromMap(data);
          })
          .where((category) =>
              category.name.toLowerCase().contains(query.toLowerCase()) ||
              category.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      print(
          "✅ FirebaseCategoryRepository: Found ${categories.length} categories matching '$query'");
      return categories;
    } catch (e) {
      print("❌ FirebaseCategoryRepository: Error searching categories: $e");
      throw Exception('Failed to search categories: $e');
    }
  }

  @override
  Future<bool> categoryExists(String categoryId) async {
    try {
      final DocumentSnapshot categoryDoc =
          await _firestore.collection(_collection).doc(categoryId).get();

      return categoryDoc.exists;
    } catch (e) {
      print(
          "❌ FirebaseCategoryRepository: Error checking category existence: $e");
      return false;
    }
  }

  @override
  Future<int> getCategoriesCount() async {
    try {
      final QuerySnapshot categoriesSnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      return categoriesSnapshot.docs.length;
    } catch (e) {
      print("❌ FirebaseCategoryRepository: Error getting categories count: $e");
      throw Exception('Failed to get categories count: $e');
    }
  }
}
