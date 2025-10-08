import 'package:flutter/material.dart';

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

class CategoriesDropDown extends StatefulWidget {
  final Function(String?, String?)? onSelectionChanged;
  final String? initialCategory;
  final String? initialSubcategory;

  const CategoriesDropDown({
    Key? key,
    this.onSelectionChanged,
    this.initialCategory,
    this.initialSubcategory,
  }) : super(key: key);

  @override
  State<CategoriesDropDown> createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<CategoriesDropDown> {
  String? selectedCategory;
  String? selectedSubcategory;
  List<Subcategory> subcategories = [];

  // Categories data based on the Firebase seeder structure
  final List<Category> mainCategories = [
    Category(
      id: "sports",
      name: "Sports",
      description: "Physical activities and competitive games",
      icon: "sports.svg",
      color: "#FF6B6B",
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
      color: "#2ECC71",
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
      color: "#8E44AD",
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
      color: "#F39C12",
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
      color: "#4ECDC4",
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
      color: "#E74C3C",
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
      color: "#3498DB",
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
      color: "#45B7D1",
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
      color: "#9B59B6",
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
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
    selectedSubcategory = widget.initialSubcategory;

    if (selectedCategory != null) {
      subcategories = getSubcategories(selectedCategory!);
    }
  }

  List<Subcategory> getSubcategories(String categoryId) {
    final category = mainCategories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(
          id: '',
          name: '',
          description: '',
          icon: '',
          color: '',
          subcategories: []),
    );
    return category.subcategories;
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      selectedCategory = value;
      subcategories = value != null ? getSubcategories(value) : [];
      selectedSubcategory = null;
    });

    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(selectedCategory, selectedSubcategory);
    }
  }

  void _onSubcategoryChanged(String? value) {
    setState(() {
      selectedSubcategory = value;
    });

    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(selectedCategory, selectedSubcategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Category Dropdown
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedCategory,
            hint: const Text('Select Category'),
            isExpanded: true,
            underline: const SizedBox(),
            items: mainCategories
                .map((cat) => DropdownMenuItem<String>(
                      value: cat.id,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(cat.name),
                      ),
                    ))
                .toList(),
            onChanged: _onCategoryChanged,
          ),
        ),

        const SizedBox(height: 16),

        // Subcategory Dropdown
        if (subcategories.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: selectedSubcategory,
              hint: const Text('Select Subcategory'),
              isExpanded: true,
              underline: const SizedBox(),
              items: subcategories
                  .map((sub) => DropdownMenuItem<String>(
                        value: sub.id,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(sub.name),
                        ),
                      ))
                  .toList(),
              onChanged: _onSubcategoryChanged,
            ),
          ),
      ],
    );
  }
}
