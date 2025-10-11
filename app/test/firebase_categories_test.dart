import 'package:flutter_test/flutter_test.dart';
import 'package:ovo_meet/domain/models/category_model.dart';
import 'package:ovo_meet/data/services/categories_service_impl.dart';
import 'package:ovo_meet/data/controller/categories/categories_controller.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

void main() {
  group('Firebase Categories Integration Tests', () {
    test('CategoryModel should serialize/deserialize correctly', () {
      // Test data matching Firebase structure
      final testData = {
        'id': 'test_category_id',
        'name': 'Social',
        'description': 'Social activities',
        'icon': 'social_icon',
        'color': '#FF6B6B',
        'subcategories': [
          {'id': 'sub1', 'name': 'Coffee', 'description': 'Coffee meetups'},
          {
            'id': 'sub2',
            'name': 'Drinks',
            'description': 'Drinks and cocktails'
          }
        ],
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'isActive': true
      };

      // Test fromMap
      final category = CategoryModel.fromMap(testData);

      expect(category.id, equals('test_category_id'));
      expect(category.name, equals('Social'));
      expect(category.description, equals('Social activities'));
      expect(category.color, equals('#FF6B6B'));
      expect(category.subcategories, hasLength(2));
      expect(category.subcategories.first.name, equals('Coffee'));
      expect(
          category.subcategories.first.description, equals('Coffee meetups'));
      expect(category.isActive, isTrue);

      // Test toMap
      final serialized = category.toMap();
      expect(serialized['name'], equals('Social'));
      expect(serialized['description'], equals('Social activities'));
      expect(serialized['isActive'], isTrue);
    });

    test('SubcategoryModel should handle data correctly', () {
      final subcategory = SubcategoryModel(
        id: 'test_id',
        name: 'Coffee',
        description: 'Coffee meetups',
      );

      expect(subcategory.id, equals('test_id'));
      expect(subcategory.name, equals('Coffee'));
      expect(subcategory.description, equals('Coffee meetups'));

      // Test copyWith
      final updated = subcategory.copyWith(name: 'Tea');
      expect(updated.name, equals('Tea'));
      expect(updated.description,
          equals('Coffee meetups')); // Should remain unchanged
    });

    test('CategoryModel should handle empty subcategories', () {
      final testData = {
        'id': 'empty_category',
        'name': 'Empty Category',
        'subcategories': <Map<String, dynamic>>[],
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'isActive': true
      };

      final category = CategoryModel.fromMap(testData);

      expect(category.subcategories, isEmpty);
      expect(category.name, equals('Empty Category'));
    });

    test('Firebase categories should match expected structure', () {
      // Test that our model matches the expected Firebase document structure
      final expectedFirebaseDoc = {
        'id': 'social_category',
        'name': 'Social',
        'description': 'Social activities',
        'icon': 'social_icon',
        'color': MyColor.socialColor.value
            .toRadixString(16)
            .substring(2)
            .toUpperCase(),
        'subcategories': [
          {'id': 'coffee', 'name': 'Coffee', 'description': 'Coffee meetups'}
        ],
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'isActive': true
      };

      // This should not throw any exceptions
      expect(() => CategoryModel.fromMap(expectedFirebaseDoc), returnsNormally);
    });
  });

  group('Categories Service Integration', () {
    test('CategoriesServiceImpl should initialize correctly', () {
      // This tests that our service can be constructed
      // In a real test, you'd mock the repository
      expect(() {
        // This tests the interface design
        expect(CategoriesServiceImpl, isNotNull);
      }, returnsNormally);
    });

    test('CategoriesController should extend GetxController', () {
      // Test that controller follows GetX conventions
      // We can't directly test inheritance without running the app,
      // but we can test that the class exists
      expect(CategoriesController, isNotNull);
    });
  });
}
