import admin from "firebase-admin";
import dotenv from "dotenv";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

// Load environment variables
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
dotenv.config({ path: join(__dirname, "../.env") });

// Initialize Firebase Admin SDK
const initializeFirebase = () => {
  try {
    // Check if Firebase is already initialized
    if (admin.apps.length === 0) {
      // Option 1: Using environment variables
      if (process.env.FIREBASE_PRIVATE_KEY) {
        const serviceAccount = {
          type: "service_account",
          project_id: process.env.FIREBASE_PROJECT_ID,
          client_email: process.env.FIREBASE_CLIENT_EMAIL,
          private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
        };

        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
          projectId: process.env.FIREBASE_PROJECT_ID,
        });
      }
      // Option 2: Using service account key file
      else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
        admin.initializeApp({
          credential: admin.credential.applicationDefault(),
          projectId: process.env.FIREBASE_PROJECT_ID,
        });
      } else {
        throw new Error(
          "Firebase credentials not configured. Please set environment variables or service account key file."
        );
      }
    }

    console.log("✅ Firebase Admin SDK initialized successfully");
    return admin.firestore();
  } catch (error) {
    console.error("❌ Error initializing Firebase:", error.message);
    process.exit(1);
  }
};

// Categories data with specified structure
const categoriesData = [
  {
    id: "sports",
    name: "Sports",
    description: "Physical activities and competitive games",
    icon: "sports.svg",
    color: "#FF6B6B",
    isActive: true,
    subcategories: [
      {
        id: "football",
        name: "Football",
        description: "Football matches and training sessions",
      },
      {
        id: "basketball",
        name: "Basketball",
        description: "Basketball games and practice",
      },
      {
        id: "tennis",
        name: "Tennis",
        description: "Tennis matches and lessons",
      },
      {
        id: "running",
        name: "Running",
        description: "Running groups and marathons",
      },
      {
        id: "cycling",
        name: "Cycling",
        description: "Cycling tours and bike rides",
      },
      {
        id: "swimming",
        name: "Swimming",
        description: "Swimming sessions and competitions",
      },
      {
        id: "yoga_fitness",
        name: "Yoga / Fitness",
        description: "Yoga classes and fitness training",
      },
      {
        id: "martial_arts",
        name: "Martial Arts",
        description: "Martial arts training and competitions",
      },
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "outdoor_adventure",
    name: "Outdoor & Adventure",
    description: "Outdoor activities and adventure sports",
    icon: "outdoor.svg",
    color: "#2ECC71",
    isActive: true,
    subcategories: [
      {
        id: "hiking",
        name: "Hiking",
        description: "Hiking trails and mountain walks",
      },
      {
        id: "camping",
        name: "Camping",
        description: "Camping trips and outdoor experiences",
      },
      {
        id: "rock_climbing",
        name: "Rock Climbing",
        description: "Rock climbing and bouldering",
      },
      {
        id: "skiing_snowboarding",
        name: "Skiing / Snowboarding",
        description: "Winter sports activities",
      },
      {
        id: "surfing",
        name: "Surfing",
        description: "Surfing lessons and beach activities",
      },
      {
        id: "kayaking_canoeing",
        name: "Kayaking / Canoeing",
        description: "Water sports and paddling",
      },
      {
        id: "motorcycling_ride",
        name: "Motorcycling / Ride",
        description: "Motorcycle rides and tours",
      },
      {
        id: "paragliding_skydiving",
        name: "Paragliding / Skydiving",
        description: "Extreme air sports",
      },
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "arts_culture",
    name: "Arts & Culture",
    description: "Creative arts, museums, and cultural events",
    icon: "arts.svg",
    color: "#8E44AD",
    isActive: true,
    subcategories: [
      {
        id: "painting_drawing",
        name: "Painting / Drawing",
        description: "Art classes and painting sessions",
      },
      {
        id: "photography",
        name: "Photography",
        description: "Photo walks and photography workshops",
      },
      {
        id: "theater_drama",
        name: "Theater / Drama",
        description: "Theater performances and drama groups",
      },
      {
        id: "music_concerts",
        name: "Music / Concerts",
        description: "Musical events and concerts",
      },
      {
        id: "dance",
        name: "Dance",
        description: "Dance classes and performances",
      },
      {
        id: "museums_exhibitions",
        name: "Museums / Exhibitions",
        description: "Museum visits and art exhibitions",
      },
      {
        id: "writing_poetry",
        name: "Writing / Poetry",
        description: "Writing workshops and poetry readings",
      },
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "food_drink",
    name: "Food & Drink",
    description: "Culinary experiences and social dining",
    icon: "food.svg",
    color: "#F39C12",
    isActive: true,
    subcategories: [
      {
        id: "coffee_meetups",
        name: "Coffee meetups",
        description: "Coffee shop gatherings and networking",
      },
      {
        id: "wine_tasting",
        name: "Wine tasting",
        description: "Wine tasting events and vineyard visits",
      },
      {
        id: "cooking_classes",
        name: "Cooking classes",
        description: "Culinary workshops and cooking lessons",
      },
      {
        id: "restaurant_gatherings",
        name: "Restaurant gatherings",
        description: "Group dining experiences",
      },
      {
        id: "picnic_meetups",
        name: "Picnic meetups",
        description: "Outdoor dining and picnic events",
      },
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "technology_gaming",
    name: "Technology & Gaming",
    description: "Tech meetups, gaming, and digital innovation",
    icon: "technology.svg",
    color: "#4ECDC4",
    isActive: true,
    subcategories: [
      {
        id: "coding_hackathons",
        name: "Coding / Hackathons",
        description: "Programming meetups and hackathon events",
      },
      {
        id: "gaming_meetups",
        name: "Gaming meetups",
        description: "Video game tournaments and gaming sessions",
      },
      {
        id: "robotics_ai",
        name: "Robotics / AI",
        description: "Robotics and artificial intelligence discussions",
      },
      {
        id: "tech_talks_workshops",
        name: "Tech talks / Workshops",
        description: "Technology presentations and workshops",
      },
      {
        id: "vr_ar_experiences",
        name: "VR / AR experiences",
        description: "Virtual and augmented reality experiences",
      },
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "education_learning",
    name: "Education & Learning",
    description: "Learning opportunities and educational activities",
    icon: "education.svg",
    color: "#E74C3C",
    isActive: true,
    subcategories: [
      {
        id: "language_exchange",
        name: "Language exchange",
        description: "Language practice and cultural exchange",
      },
      {
        id: "book_clubs",
        name: "Book clubs",
        description: "Reading groups and literary discussions",
      },
      {
        id: "study_groups",
        name: "Study groups",
        description: "Collaborative learning sessions",
      },
      {
        id: "workshops_seminars",
        name: "Workshops & Seminars",
        description: "Educational workshops and seminars",
      },
      {
        id: "science_stem_meetups",
        name: "Science & STEM meetups",
        description: "Science, technology, engineering, and math discussions",
      },
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "social_community",
    name: "Social & Community",
    description: "Community building and social networking",
    icon: "social.svg",
    color: "#3498DB",
    isActive: true,
    subcategories: [
      {
        id: "volunteering_charity",
        name: "Volunteering / Charity events",
        description: "Community service and charitable activities",
      },
      {
        id: "networking_events",
        name: "Networking events",
        description: "Professional and social networking",
      },
      {
        id: "meet_greets",
        name: "Meet & greets",
        description: "Casual social gatherings",
      },
      {
        id: "cultural_exchange",
        name: "Cultural exchange",
        description: "Cross-cultural communication and learning",
      },
      {
        id: "discussion_groups_debates",
        name: "Discussion groups / Debates",
        description: "Intellectual discussions and debates",
      },
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "entertainment_leisure",
    name: "Entertainment & Leisure",
    description: "Fun activities and leisure entertainment",
    icon: "entertainment.svg",
    color: "#45B7D1",
    isActive: true,
    subcategories: [
      {
        id: "movie_nights",
        name: "Movie nights",
        description: "Cinema screenings and movie discussions",
      },
      {
        id: "karaoke",
        name: "Karaoke",
        description: "Karaoke nights and singing events",
      },
      {
        id: "board_games_card_games",
        name: "Board games / Card games",
        description: "Tabletop gaming sessions",
      },
      {
        id: "trivia_quiz_nights",
        name: "Trivia / Quiz nights",
        description: "Quiz competitions and trivia events",
      },
      {
        id: "theme_park_visits",
        name: "Theme park visits",
        description: "Amusement park outings and adventures",
      },
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "travel_trips",
    name: "Travel & Trips",
    description: "Travel experiences and group adventures",
    icon: "travel.svg",
    color: "#9B59B6",
    isActive: true,
    subcategories: [
      {
        id: "day_trips",
        name: "Day trips",
        description: "Single-day excursions and local adventures",
      },
      {
        id: "road_trips",
        name: "Road trips",
        description: "Multi-day driving adventures",
      },
      {
        id: "city_tours",
        name: "City tours",
        description: "Urban exploration and city sightseeing",
      },
      {
        id: "adventure_travel",
        name: "Adventure travel",
        description: "Extreme travel and adventure experiences",
      },
      {
        id: "beach_outings",
        name: "Beach outings",
        description: "Beach trips and coastal activities",
      },
    ],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// Function to seed categories
const seedCategories = async () => {
  console.log("🌱 Starting categories seeding...");

  const db = initializeFirebase();
  const categoriesCollection = db.collection("categories");

  try {
    // Check if categories already exist
    const existingCategories = await categoriesCollection.get();

    if (!existingCategories.empty) {
      console.log(`⚠️  Found ${existingCategories.size} existing categories.`);
      console.log(
        "Do you want to continue? This will add new categories or update existing ones."
      );

      // For automation, you can comment out this check or set a flag
      // process.exit(0);
    }

    console.log(`📝 Seeding ${categoriesData.length} categories...`);

    // Use batch write for better performance
    const batch = db.batch();

    categoriesData.forEach((category) => {
      const docRef = categoriesCollection.doc(category.id);
      batch.set(docRef, category, { merge: true });
    });

    // Commit the batch
    await batch.commit();

    console.log("✅ Categories seeded successfully!");
    console.log(`📊 Total categories: ${categoriesData.length}`);

    // Display seeded categories
    console.log("\n📋 Seeded Categories:");
    categoriesData.forEach((category, index) => {
      console.log(`  ${index + 1}. ${category.name} (${category.id})`);
      console.log(
        `     └─ ${
          category.subcategories.length
        } subcategories: ${category.subcategories
          .map((sub) => sub.name)
          .join(", ")}`
      );
    });
  } catch (error) {
    console.error("❌ Error seeding categories:", error);
    throw error;
  }
};

// Function to verify seeded data
const verifyCategories = async () => {
  console.log("\n🔍 Verifying seeded categories...");

  const db = initializeFirebase();
  const categoriesCollection = db.collection("categories");

  try {
    const snapshot = await categoriesCollection.get();

    if (snapshot.empty) {
      console.log("❌ No categories found in database");
      return;
    }

    console.log(`✅ Found ${snapshot.size} categories in database:`);

    snapshot.forEach((doc) => {
      const data = doc.data();
      console.log(
        `  - ${data.name} (ID: ${doc.id}) - Active: ${data.isActive}`
      );
      if (data.subcategories && data.subcategories.length > 0) {
        console.log(
          `    └─ ${
            data.subcategories.length
          } subcategories: ${data.subcategories
            .map((sub) => sub.name)
            .join(", ")}`
        );
      }
    });
  } catch (error) {
    console.error("❌ Error verifying categories:", error);
    throw error;
  }
};

// Function to clean up categories (for testing)
const cleanupCategories = async () => {
  console.log("🧹 Cleaning up categories...");

  const db = initializeFirebase();
  const categoriesCollection = db.collection("categories");

  try {
    const snapshot = await categoriesCollection.get();
    const batch = db.batch();

    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log("✅ Categories cleaned up successfully!");
  } catch (error) {
    console.error("❌ Error cleaning up categories:", error);
    throw error;
  }
};

// Main execution
const main = async () => {
  try {
    const command = process.argv[2];

    switch (command) {
      case "seed":
        await seedCategories();
        await verifyCategories();
        break;
      case "verify":
        await verifyCategories();
        break;
      case "cleanup":
        await cleanupCategories();
        break;
      default:
        console.log("Usage:");
        console.log("  npm run seed:categories seed    - Seed categories data");
        console.log("  npm run seed:categories verify  - Verify seeded data");
        console.log("  npm run seed:categories cleanup - Clean up categories");
        break;
    }

    console.log("\n🎉 Process completed successfully!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Process failed:", error);
    process.exit(1);
  }
};

// Run the script
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { seedCategories, verifyCategories, cleanupCategories };
