import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/view/components/bottom-sheet/custom_bottom_sheet.dart';
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

  // Fallback categories data for backward compatibility
  final List<Category> _fallbackCategories = [
    Category(
      id: "sports",
      name: "Sports",
      description: "Physical activities and competitive games",
      icon: "sports.svg",
      color: "sports",
      subcategories: [
        Subcategory(
            id: "football",
            name: "Football",
            description: "Football matches and training sessions"),
        Subcategory(
            id: "basketball",
            name: "Basketball",
            description: "Basketball games and practice"),
        Subcategory(
            id: "tennis",
            name: "Tennis",
            description: "Tennis matches and lessons"),
        Subcategory(
            id: "running",
            name: "Running",
            description: "Running groups and marathons"),
        Subcategory(
            id: "cycling",
            name: "Cycling",
            description: "Cycling tours and bike rides"),
        Subcategory(
            id: "swimming",
            name: "Swimming",
            description: "Swimming sessions and competitions"),
        Subcategory(
            id: "yoga_fitness",
            name: "Yoga / Fitness",
            description: "Yoga classes and fitness training"),
        Subcategory(
            id: "martial_arts",
            name: "Martial Arts",
            description: "Martial arts training and competitions"),
      ],
    ),
    Category(
      id: "outdoor_adventure",
      name: "Outdoor & Adventure",
      description: "Outdoor activities and adventure sports",
      icon: "outdoor.svg",
      color: "fitness",
      subcategories: [
        Subcategory(
            id: "hiking",
            name: "Hiking",
            description: "Hiking trails and mountain walks"),
        Subcategory(
            id: "camping",
            name: "Camping",
            description: "Camping trips and outdoor experiences"),
        Subcategory(
            id: "rock_climbing",
            name: "Rock Climbing",
            description: "Rock climbing and bouldering"),
        Subcategory(
            id: "skiing_snowboarding",
            name: "Skiing / Snowboarding",
            description: "Winter sports activities"),
        Subcategory(
            id: "surfing",
            name: "Surfing",
            description: "Surfing lessons and beach activities"),
        Subcategory(
            id: "kayaking_canoeing",
            name: "Kayaking / Canoeing",
            description: "Water sports and paddling"),
        Subcategory(
            id: "motorcycling_ride",
            name: "Motorcycling / Ride",
            description: "Motorcycle rides and tours"),
        Subcategory(
            id: "paragliding_skydiving",
            name: "Paragliding / Skydiving",
            description: "Extreme air sports"),
      ],
    ),
    Category(
      id: "arts_culture",
      name: "Arts & Culture",
      description: "Creative arts, museums, and cultural events",
      icon: "arts.svg",
      color: "art",
      subcategories: [
        Subcategory(
            id: "painting_drawing",
            name: "Painting / Drawing",
            description: "Art classes and painting sessions"),
        Subcategory(
            id: "photography",
            name: "Photography",
            description: "Photo walks and photography workshops"),
        Subcategory(
            id: "theater_drama",
            name: "Theater / Drama",
            description: "Theater performances and drama groups"),
        Subcategory(
            id: "music_concerts",
            name: "Music / Concerts",
            description: "Musical events and concerts"),
        Subcategory(
            id: "dance",
            name: "Dance",
            description: "Dance classes and performances"),
        Subcategory(
            id: "museums_exhibitions",
            name: "Museums / Exhibitions",
            description: "Museum visits and art exhibitions"),
        Subcategory(
            id: "writing_poetry",
            name: "Writing / Poetry",
            description: "Writing workshops and poetry readings"),
      ],
    ),
    Category(
      id: "food_drink",
      name: "Food & Drink",
      description: "Culinary experiences and social dining",
      icon: "food.svg",
      color: "cooking",
      subcategories: [
        Subcategory(
            id: "coffee_meetups",
            name: "Coffee meetups",
            description: "Coffee shop gatherings and networking"),
        Subcategory(
            id: "wine_tasting",
            name: "Wine tasting",
            description: "Wine tasting events and vineyard visits"),
        Subcategory(
            id: "cooking_classes",
            name: "Cooking classes",
            description: "Culinary workshops and cooking lessons"),
        Subcategory(
            id: "restaurant_gatherings",
            name: "Restaurant gatherings",
            description: "Group dining experiences"),
        Subcategory(
            id: "picnic_meetups",
            name: "Picnic meetups",
            description: "Outdoor dining and picnic events"),
      ],
    ),
    Category(
      id: "technology_gaming",
      name: "Technology & Gaming",
      description: "Tech meetups, gaming, and digital innovation",
      icon: "technology.svg",
      color: "games",
      subcategories: [
        Subcategory(
            id: "coding_hackathons",
            name: "Coding / Hackathons",
            description: "Programming meetups and hackathon events"),
        Subcategory(
            id: "gaming_meetups",
            name: "Gaming meetups",
            description: "Video game tournaments and gaming sessions"),
        Subcategory(
            id: "robotics_ai",
            name: "Robotics / AI",
            description: "Robotics and artificial intelligence discussions"),
        Subcategory(
            id: "tech_talks_workshops",
            name: "Tech talks / Workshops",
            description: "Technology presentations and workshops"),
        Subcategory(
            id: "vr_ar_experiences",
            name: "VR / AR experiences",
            description: "Virtual and augmented reality experiences"),
      ],
    ),
    Category(
      id: "education_learning",
      name: "Education & Learning",
      description: "Learning opportunities and educational activities",
      icon: "education.svg",
      color: "reading",
      subcategories: [
        Subcategory(
            id: "language_exchange",
            name: "Language exchange",
            description: "Language practice and cultural exchange"),
        Subcategory(
            id: "book_clubs",
            name: "Book clubs",
            description: "Reading groups and literary discussions"),
        Subcategory(
            id: "study_groups",
            name: "Study groups",
            description: "Collaborative learning sessions"),
        Subcategory(
            id: "workshops_seminars",
            name: "Workshops & Seminars",
            description: "Educational workshops and seminars"),
        Subcategory(
            id: "science_stem_meetups",
            name: "Science & STEM meetups",
            description:
                "Science, technology, engineering, and math discussions"),
      ],
    ),
    Category(
      id: "social_community",
      name: "Social & Community",
      description: "Community building and social networking",
      icon: "social.svg",
      color: "social",
      subcategories: [
        Subcategory(
            id: "volunteering_charity",
            name: "Volunteering / Charity events",
            description: "Community service and charitable activities"),
        Subcategory(
            id: "networking_events",
            name: "Networking events",
            description: "Professional and social networking"),
        Subcategory(
            id: "meet_greets",
            name: "Meet & greets",
            description: "Casual social gatherings"),
        Subcategory(
            id: "cultural_exchange",
            name: "Cultural exchange",
            description: "Cross-cultural communication and learning"),
        Subcategory(
            id: "discussion_groups_debates",
            name: "Discussion groups / Debates",
            description: "Intellectual discussions and debates"),
      ],
    ),
    Category(
      id: "entertainment_leisure",
      name: "Entertainment & Leisure",
      description: "Fun activities and leisure entertainment",
      icon: "entertainment.svg",
      color: "music",
      subcategories: [
        Subcategory(
            id: "movie_nights",
            name: "Movie nights",
            description: "Cinema screenings and movie discussions"),
        Subcategory(
            id: "karaoke",
            name: "Karaoke",
            description: "Karaoke nights and singing events"),
        Subcategory(
            id: "board_games_card_games",
            name: "Board games / Card games",
            description: "Tabletop gaming sessions"),
        Subcategory(
            id: "trivia_quiz_nights",
            name: "Trivia / Quiz nights",
            description: "Quiz competitions and trivia events"),
        Subcategory(
            id: "theme_park_visits",
            name: "Theme park visits",
            description: "Amusement park outings and adventures"),
      ],
    ),
    Category(
      id: "travel_trips",
      name: "Travel & Trips",
      description: "Travel experiences and group adventures",
      icon: "travel.svg",
      color: "travel",
      subcategories: [
        Subcategory(
            id: "day_trips",
            name: "Day trips",
            description: "Single-day excursions and local adventures"),
        Subcategory(
            id: "road_trips",
            name: "Road trips",
            description: "Multi-day driving adventures"),
        Subcategory(
            id: "city_tours",
            name: "City tours",
            description: "Urban exploration and city sightseeing"),
        Subcategory(
            id: "adventure_travel",
            name: "Adventure travel",
            description: "Extreme travel and adventure experiences"),
        Subcategory(
            id: "beach_outings",
            name: "Beach outings",
            description: "Beach trips and coastal activities"),
      ],
    ),
  ];

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

  Color _getCategoryColorFromKey(String colorKey) {
    return MyColor.getHobbyColor(colorKey);
  }

  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return MyStrings.selectCategory;

    // Try to get from controller first
    if (_categoriesController != null &&
        _categoriesController!.areCategoriesLoaded) {
      return _categoriesController!.getCategoryName(categoryId);
    }

    // Fallback to static categories
    try {
      final category =
          _fallbackCategories.firstWhere((cat) => cat.id == categoryId);
      return category.name;
    } catch (e) {
      return MyStrings.categoryNotAvailable;
    }
  }

  String _getSubcategoryName(String? categoryId, String? subcategoryId) {
    if (categoryId == null || subcategoryId == null) return '';

    // Try to get from controller first
    if (_categoriesController != null &&
        _categoriesController!.areCategoriesLoaded) {
      return _categoriesController!
          .getSubcategoryName(categoryId, subcategoryId);
    }

    // Fallback to static categories
    try {
      final category =
          _fallbackCategories.firstWhere((cat) => cat.id == categoryId);
      final subcategory =
          category.subcategories.firstWhere((sub) => sub.id == subcategoryId);
      return subcategory.name;
    } catch (e) {
      return MyStrings.categoryNotAvailable;
    }
  }

  Color _getCategoryColor(String? categoryId) {
    if (categoryId == null) return MyColor.getGreyColor();

    // Try to get from controller first
    if (_categoriesController != null &&
        _categoriesController!.areCategoriesLoaded) {
      return _categoriesController!.getCategoryColor(categoryId);
    }

    // Fallback to static categories
    try {
      final category =
          _fallbackCategories.firstWhere((cat) => cat.id == categoryId);
      return _getCategoryColorFromKey(category.color);
    } catch (e) {
      return MyColor.getGreyColor();
    }
  }

  void _showCategorySelector() {
    CustomBottomSheet(
      isNeedMargin: false, // Set to false for full width
      child: CategorySelectionBottomSheet(
        selectedCategoryId: selectedCategoryId,
        selectedSubcategoryId: selectedSubcategoryId,
        onSelectionChanged: (categoryId, subcategoryId) {
          setState(() {
            selectedCategoryId = categoryId;
            selectedSubcategoryId = subcategoryId;
          });
          widget.onSelectionChanged(categoryId, subcategoryId);
        },
      ),
    ).customBottomSheet(context);
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
