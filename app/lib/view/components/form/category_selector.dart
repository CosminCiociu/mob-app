import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/view/components/bottom-sheet/category_selection_bottom_sheet.dart';
import 'package:ovo_meet/data/controller/categories/categories_controller.dart';

class CategorySelector extends StatefulWidget {
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;
  final Function(String?, String?) onSelectionChanged;

  const CategorySelector({
    Key? key,
    this.selectedCategoryId,
    this.selectedSubcategoryId,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String? selectedCategoryId;
  String? selectedSubcategoryId;
  CategoriesController? _categoriesController;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.selectedCategoryId;
    selectedSubcategoryId = widget.selectedSubcategoryId;

    // Initialize categories controller
    try {
      _categoriesController = Get.find<CategoriesController>();
    } catch (e) {
      print(
          "⚠️ CategorySelector: CategoriesController not found, categories may not work properly");
    }
  }

  @override
  void didUpdateWidget(CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryId != widget.selectedCategoryId ||
        oldWidget.selectedSubcategoryId != widget.selectedSubcategoryId) {
      setState(() {
        selectedCategoryId = widget.selectedCategoryId;
        selectedSubcategoryId = widget.selectedSubcategoryId;
      });
    }
  }

  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return MyStrings.selectCategory;

    // Get from controller
    if (_categoriesController != null &&
        _categoriesController!.areCategoriesLoaded) {
      return _categoriesController!.getCategoryName(categoryId);
    }

    return MyStrings.categoryNotAvailable;
  }

  String _getSubcategoryName(String? categoryId, String? subcategoryId) {
    if (categoryId == null || subcategoryId == null) return '';

    // Get from controller
    if (_categoriesController != null &&
        _categoriesController!.areCategoriesLoaded) {
      return _categoriesController!
          .getSubcategoryName(categoryId, subcategoryId);
    }

    return MyStrings.categoryNotAvailable;
  }

  Color _getCategoryColor(String? categoryId) {
    if (categoryId == null) return MyColor.getGreyColor();

    // Get from controller
    if (_categoriesController != null &&
        _categoriesController!.areCategoriesLoaded) {
      return _categoriesController!.getCategoryColor(categoryId);
    }

    return MyColor.getGreyColor();
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => CategorySelectionBottomSheet(
          selectedCategoryId: selectedCategoryId,
          selectedSubcategoryId: selectedSubcategoryId,
          onSelectionChanged: (categoryId, subcategoryId) {
            setState(() {
              selectedCategoryId = categoryId;
              selectedSubcategoryId = subcategoryId;
            });
            widget.onSelectionChanged(categoryId, subcategoryId);
          },
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = _getCategoryName(selectedCategoryId);
    final subcategoryName =
        _getSubcategoryName(selectedCategoryId, selectedSubcategoryId);
    final categoryColor = _getCategoryColor(selectedCategoryId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MyColor.getTextColor(),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showCategorySelector,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              border: Border.all(color: MyColor.getBorderColor()),
              borderRadius: BorderRadius.circular(8),
              color: MyColor.getCardBgColor(),
            ),
            child: Row(
              children: [
                // Red marker (colored circle)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Dimensions.space12),

                // Category and subcategory text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: selectedCategoryId != null
                              ? MyColor.getTextColor()
                              : MyColor.getSecondaryTextColor(),
                        ),
                      ),
                      if (subcategoryName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subcategoryName,
                          style: TextStyle(
                            fontSize: 14,
                            color: categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Dropdown arrow
                Icon(
                  Icons.keyboard_arrow_down,
                  color: MyColor.getSecondaryTextColor(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
