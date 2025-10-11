import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/data/controller/categories/categories_controller.dart';
import 'package:ovo_meet/domain/models/category_model.dart';

class CategorySelectionBottomSheet extends StatefulWidget {
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;
  final Function(String categoryId, String? subcategoryId) onSelectionChanged;
  final ScrollController? scrollController;

  const CategorySelectionBottomSheet({
    Key? key,
    this.selectedCategoryId,
    this.selectedSubcategoryId,
    required this.onSelectionChanged,
    this.scrollController,
  }) : super(key: key);

  @override
  State<CategorySelectionBottomSheet> createState() =>
      _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState
    extends State<CategorySelectionBottomSheet> {
  String? selectedCategoryId;
  String? selectedSubcategoryId;
  String? expandedCategoryId;

  CategoriesController? _categoriesController;
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.selectedCategoryId;
    selectedSubcategoryId = widget.selectedSubcategoryId;

    // Expand the selected category initially
    if (selectedCategoryId != null) {
      expandedCategoryId = selectedCategoryId;
    }

    // Load Firebase categories
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      // Try to get the CategoriesController
      _categoriesController = Get.find<CategoriesController>();

      if (_categoriesController != null) {
        // Load categories from Firebase
        await _categoriesController!.loadCategories();

        if (mounted) {
          setState(() {
            _categories = _categoriesController!.categories;
            _isLoading = false;
          });
        }
      } else {
        // Controller not found, show error
        if (mounted) {
          setState(() {
            _error = MyStrings.failedToLoadCategories;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("❌ CategorySelectionBottomSheet: Error loading categories: $e");
      if (mounted) {
        setState(() {
          _error = MyStrings.failedToLoadCategories;
          _isLoading = false;
        });
      }
    }
  }

  Color _getCategoryColor(String colorKey) {
    return MyColor.getHobbyColor(colorKey);
  }

  void _selectCategory(String categoryId) {
    setState(() {
      if (expandedCategoryId == categoryId) {
        // If clicking on already expanded category, collapse it
        expandedCategoryId = null;
      } else {
        // Expand the clicked category
        expandedCategoryId = categoryId;
        selectedCategoryId = categoryId;
        selectedSubcategoryId =
            null; // Reset subcategory when selecting new category
      }
    });
  }

  void _selectSubcategory(String categoryId, String subcategoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      selectedSubcategoryId = subcategoryId;
    });

    // Call the callback and close the bottom sheet
    widget.onSelectionChanged(categoryId, subcategoryId);
    Navigator.of(context).pop();
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: MyColor.getPrimaryColor(),
            ),
            const SizedBox(height: 16),
            Text(
              MyStrings.loadingCategories,
              style: TextStyle(
                color: MyColor.getTextColor(),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: MyColor.getRedColor(),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? MyStrings.failedToLoadCategories,
              style: TextStyle(
                color: MyColor.getTextColor(),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadCategories();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              color: MyColor.getGreyColor(),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              MyStrings.noCategoriesFound,
              style: TextStyle(
                color: MyColor.getTextColor(),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensure full width
      height: MediaQuery.of(context).size.height * 0.8, // Set explicit height
      decoration: BoxDecoration(
        color: MyColor.getCardBgColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: MyColor.getBorderColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(Dimensions.space20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  MyStrings.selectCategory,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyColor.getTextColor(),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: MyColor.getTextColor()),
                ),
              ],
            ),
          ),

          // Content based on loading state
          if (_isLoading)
            _buildLoadingWidget()
          else if (_error != null)
            _buildErrorWidget()
          else if (_categories.isEmpty)
            _buildEmptyWidget()
          else
            // Categories list
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: Dimensions.space20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isExpanded = expandedCategoryId == category.id;
                  final isSelected = selectedCategoryId == category.id;

                  return Column(
                    children: [
                      // Category Item
                      InkWell(
                        onTap: () => _selectCategory(category.id),
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.space15),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _getCategoryColor(category.color)
                                    .withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: _getCategoryColor(category.color),
                                    width: 1)
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Color marker (circle indicator)
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(category.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: Dimensions.space15),

                              // Category name and description
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: MyColor.getTextColor(),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      category.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: MyColor.getSecondaryTextColor(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Expand/collapse icon
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: MyColor.getSecondaryTextColor(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Subcategories (shown when expanded)
                      if (isExpanded)
                        Container(
                          margin: const EdgeInsets.only(
                              left: 27, top: 8, bottom: 8),
                          child: Column(
                            children: category.subcategories.map((subcategory) {
                              final isSubcategorySelected =
                                  selectedSubcategoryId == subcategory.id;

                              return InkWell(
                                onTap: () => _selectSubcategory(
                                    category.id, subcategory.id),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.space12,
                                    horizontal: Dimensions.space15,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: isSubcategorySelected
                                        ? _getCategoryColor(category.color)
                                            .withValues(alpha: 0.15)
                                        : MyColor.getCardBgColor(),
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSubcategorySelected
                                        ? Border.all(
                                            color: _getCategoryColor(
                                                category.color),
                                            width: 1)
                                        : Border.all(
                                            color: MyColor.getBorderColor(),
                                            width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subcategory.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSubcategorySelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSubcategorySelected
                                              ? _getCategoryColor(
                                                  category.color)
                                              : MyColor.getTextColor(),
                                        ),
                                      ),
                                      if (subcategory
                                          .description.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          subcategory.description,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                MyColor.getSecondaryTextColor(),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),

          // Bottom padding
          const SizedBox(height: Dimensions.space20),
        ],
      ),
    );
  }
}
