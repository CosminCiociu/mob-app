import "dotenv/config";
import admin from "firebase-admin";

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      type: "service_account",
      project_id: process.env.FIREBASE_PROJECT_ID,
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
      private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID,
      auth_uri: "https://accounts.google.com/o/oauth2/auth",
      token_uri: "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
      client_x509_cert_url: process.env.FIREBASE_CLIENT_CERT_URL,
    }),
    databaseURL: `https://${process.env.FIREBASE_PROJECT_ID}-default-rtdb.firebaseio.com/`,
  });
}

const db = admin.firestore();

// Function to get random element from array
function getRandomElement(array) {
  return array[Math.floor(Math.random() * array.length)];
}

// Function to get random number between min and max
function getRandomNumber(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Function to generate future date
function generateFutureDate(daysFromNow = 1, maxDaysAhead = 30) {
  const date = new Date();
  const randomDays = getRandomNumber(daysFromNow, maxDaysAhead);
  date.setDate(date.getDate() + randomDays);

  // Set random time between 9 AM and 9 PM
  const randomHour = getRandomNumber(9, 21);
  const randomMinute = Math.random() < 0.5 ? 0 : 30;
  date.setHours(randomHour, randomMinute, 0, 0);

  return date.toISOString();
}

// Sample event templates based on categories
const eventTemplates = {
  sports: [
    {
      name: "Football Training Session",
      description:
        "Join our weekly football training for all skill levels. Improve your technique and meet new players.",
      maxAttendees: 22,
    },
    {
      name: "Basketball Pickup Game",
      description:
        "Casual basketball game in the local court. All levels welcome!",
      maxAttendees: 10,
    },
    {
      name: "Tennis Tournament",
      description:
        "Singles tennis tournament for intermediate players. Prizes for winners!",
      maxAttendees: 16,
    },
    {
      name: "Running Club Meetup",
      description:
        "Weekly running group for 5-10km routes. Build endurance and make friends.",
      maxAttendees: 25,
    },
    {
      name: "Yoga in the Park",
      description:
        "Outdoor yoga session for relaxation and mindfulness. Bring your own mat.",
      maxAttendees: 20,
    },
  ],
  outdoor_adventure: [
    {
      name: "Mountain Hiking Adventure",
      description:
        "Explore scenic mountain trails. Suitable for intermediate hikers. Bring hiking gear.",
      maxAttendees: 15,
    },
    {
      name: "Camping Weekend",
      description:
        "Two-day camping trip with bonfire and outdoor activities. Equipment provided.",
      maxAttendees: 12,
    },
    {
      name: "Rock Climbing Session",
      description:
        "Indoor and outdoor rock climbing for beginners and experienced climbers.",
      maxAttendees: 8,
    },
    {
      name: "Cycling Tour",
      description:
        "Scenic bike ride through countryside paths. Rent bikes available.",
      maxAttendees: 20,
    },
    {
      name: "Kayak River Adventure",
      description:
        "Half-day kayaking trip down the local river. All equipment included.",
      maxAttendees: 10,
    },
  ],
  arts_culture: [
    {
      name: "Art Gallery Opening",
      description:
        "Contemporary art exhibition opening with wine and networking. Meet local artists.",
      maxAttendees: 50,
    },
    {
      name: "Photography Workshop",
      description:
        "Learn professional photography techniques with hands-on practice.",
      maxAttendees: 15,
    },
    {
      name: "Theater Performance",
      description:
        "Live theater performance by local drama group. Reserve your seats!",
      maxAttendees: 80,
    },
    {
      name: "Music Jam Session",
      description:
        "Bring your instruments for an informal music jam. All genres welcome.",
      maxAttendees: 12,
    },
    {
      name: "Painting Class",
      description:
        "Acrylic painting workshop for beginners. All materials provided.",
      maxAttendees: 18,
    },
  ],
  food_drink: [
    {
      name: "Coffee & Networking",
      description:
        "Morning coffee meetup for professionals and entrepreneurs. Great networking opportunity.",
      maxAttendees: 30,
    },
    {
      name: "Wine Tasting Evening",
      description:
        "Guided wine tasting featuring local vineyard selections. Learn about wine varieties.",
      maxAttendees: 25,
    },
    {
      name: "Cooking Class: Italian Cuisine",
      description:
        "Learn to cook authentic Italian dishes. All ingredients and recipes included.",
      maxAttendees: 16,
    },
    {
      name: "Foodie Restaurant Tour",
      description:
        "Visit 3 local restaurants and sample their signature dishes. Food adventure!",
      maxAttendees: 20,
    },
    {
      name: "Picnic in the Park",
      description:
        "Community picnic with games and activities. Bring a dish to share!",
      maxAttendees: 40,
    },
  ],
  technology_gaming: [
    {
      name: "Coding Bootcamp",
      description:
        "Intensive coding workshop covering modern web development techniques.",
      maxAttendees: 25,
    },
    {
      name: "Gaming Tournament",
      description:
        "Competitive gaming tournament with multiple game categories. Prizes available!",
      maxAttendees: 32,
    },
    {
      name: "AI & Robotics Meetup",
      description:
        "Discussion about latest developments in artificial intelligence and robotics.",
      maxAttendees: 40,
    },
    {
      name: "VR Experience Session",
      description:
        "Try the latest virtual reality games and applications. Mind-blowing technology!",
      maxAttendees: 20,
    },
    {
      name: "Tech Startup Pitch",
      description:
        "Local entrepreneurs pitch their tech startup ideas. Network with innovators.",
      maxAttendees: 60,
    },
  ],
  education_learning: [
    {
      name: "Language Exchange",
      description:
        "Practice different languages with native speakers. English, Spanish, French available.",
      maxAttendees: 30,
    },
    {
      name: "Book Club Meeting",
      description:
        "Monthly book discussion group. This month: contemporary fiction selections.",
      maxAttendees: 15,
    },
    {
      name: "Study Group Session",
      description:
        "Collaborative study session for professional certifications and exams.",
      maxAttendees: 12,
    },
    {
      name: "Science Workshop",
      description:
        "Hands-on science experiments and demonstrations for all ages.",
      maxAttendees: 25,
    },
    {
      name: "Personal Development Seminar",
      description:
        "Learn goal-setting, time management, and productivity techniques.",
      maxAttendees: 35,
    },
  ],
  social_community: [
    {
      name: "Community Volunteer Day",
      description:
        "Join local volunteer activities to give back to the community. Various projects available.",
      maxAttendees: null,
    },
    {
      name: "Neighborhood Cleanup",
      description:
        "Help clean up local parks and streets. Supplies provided, bring work gloves.",
      maxAttendees: 50,
    },
    {
      name: "Cultural Exchange Event",
      description:
        "Meet people from different cultures and learn about their traditions.",
      maxAttendees: 40,
    },
    {
      name: "Networking Mixer",
      description:
        "Professional networking event for career development and business connections.",
      maxAttendees: 75,
    },
    {
      name: "Community Garden Project",
      description:
        "Help maintain the community garden and learn about sustainable gardening.",
      maxAttendees: 20,
    },
  ],
  entertainment_leisure: [
    {
      name: "Movie Night Under Stars",
      description:
        "Outdoor movie screening with popcorn and beverages. Bring blankets!",
      maxAttendees: 60,
    },
    {
      name: "Karaoke Night",
      description:
        "Sing your favorite songs and enjoy a fun evening with friends. All skill levels welcome!",
      maxAttendees: 40,
    },
    {
      name: "Board Game Café",
      description:
        "Try various board games while enjoying coffee and snacks. Games provided.",
      maxAttendees: 24,
    },
    {
      name: "Comedy Show",
      description:
        "Stand-up comedy performance by local comedians. Guaranteed laughs!",
      maxAttendees: 80,
    },
    {
      name: "Trivia Night",
      description:
        "Test your knowledge in various categories. Teams of 4-6 people. Prizes for winners!",
      maxAttendees: 48,
    },
  ],
  travel_trips: [
    {
      name: "City Walking Tour",
      description:
        "Guided tour of historical downtown area with interesting stories and facts.",
      maxAttendees: 25,
    },
    {
      name: "Day Trip to Coast",
      description:
        "Full-day excursion to nearby coastal town with beach activities and local dining.",
      maxAttendees: 35,
    },
    {
      name: "Weekend Road Trip",
      description:
        "Two-day road trip to scenic locations with stops at interesting landmarks.",
      maxAttendees: 12,
    },
    {
      name: "Local Winery Tour",
      description:
        "Visit local wineries with tastings and learn about wine production process.",
      maxAttendees: 20,
    },
    {
      name: "Adventure Travel Planning",
      description:
        "Group meeting to plan upcoming adventure travel destinations and activities.",
      maxAttendees: 15,
    },
  ],
};

// Function to get random location based on user's location with some variation
function generateLocationNearUser(userLocation) {
  if (!userLocation) {
    // Default location if user has no location
    return {
      address: {
        administrativeArea: "București",
        country: "Romania",
        fullAddress: "Centrul Vechi, București, România",
        locality: "București",
        name: "Centrul Vechi",
      },
      geohash: "u8q2w5k9p",
      geopoint: new admin.firestore.GeoPoint(44.4268, 26.1025),
      lat: 44.4268,
      lng: 26.1025,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
  }

  // Add some variation to user's location (within 5km radius approximately)
  const latVariation = (Math.random() - 0.5) * 0.1; // ~5km variation
  const lngVariation = (Math.random() - 0.5) * 0.1;

  const newLat = userLocation.lat + latVariation;
  const newLng = userLocation.lng + lngVariation;

  return {
    address: {
      administrativeArea:
        userLocation.address?.administrativeArea || "Unknown Area",
      country: userLocation.address?.country || "Romania",
      fullAddress: `Event Location near ${
        userLocation.address?.locality || "Unknown"
      }, ${userLocation.address?.country || "Romania"}`,
      locality: userLocation.address?.locality || "Unknown",
      name: `Event Venue`,
    },
    geohash: "generated_hash",
    geopoint: new admin.firestore.GeoPoint(newLat, newLng),
    lat: newLat,
    lng: newLng,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  };
}

// Function to fetch categories from database
async function fetchCategories() {
  try {
    console.log("📋 Fetching categories from database...");
    const categoriesSnapshot = await db
      .collection("categories")
      .where("isActive", "==", true)
      .get();

    if (categoriesSnapshot.empty) {
      throw new Error(
        "No active categories found in database. Please run the categories seeder first."
      );
    }

    const categories = [];
    categoriesSnapshot.forEach((doc) => {
      const data = doc.data();
      categories.push({
        id: data.id,
        name: data.name,
        subcategories: data.subcategories || [],
      });
    });

    console.log(`✅ Found ${categories.length} active categories`);
    return categories;
  } catch (error) {
    console.error("❌ Error fetching categories:", error);
    throw error;
  }
}

// Function to fetch users from database
async function fetchUsers() {
  try {
    console.log("👥 Fetching users from database...");
    const usersSnapshot = await db.collection("users").get();

    if (usersSnapshot.empty) {
      console.log("⚠️ No users found in database. Using sample user data.");
      return [
        {
          id: "sample_user_1",
          email: "user1@example.com",
          firstName: "John",
          lastName: "Doe",
          location: null,
        },
        {
          id: "sample_user_2",
          email: "user2@example.com",
          firstName: "Jane",
          lastName: "Smith",
          location: null,
        },
      ];
    }

    const users = [];
    usersSnapshot.forEach((doc) => {
      const data = doc.data();
      users.push({
        id: doc.id,
        email: data.email || `user_${doc.id}@example.com`,
        firstName:
          data.firstName ||
          data.first_name ||
          data.displayName?.split(" ")[0] ||
          "User",
        lastName:
          data.lastName ||
          data.last_name ||
          data.displayName?.split(" ")[1] ||
          doc.id.substring(0, 8),
        location: data.location,
      });
    });

    console.log(`✅ Found ${users.length} users in database`);

    // Debug: Show sample user data
    if (users.length > 0) {
      console.log("📝 Sample user data:");
      users.slice(0, 3).forEach((user, index) => {
        console.log(
          `  ${index + 1}. ${user.firstName} ${user.lastName} (${user.id})`
        );
      });
    }

    return users;
  } catch (error) {
    console.error("❌ Error fetching users:", error);
    throw error;
  }
}

// Function to count existing events for a user
async function countUserEvents(userId) {
  try {
    const eventsSnapshot = await db
      .collection("users_events")
      .where("createdBy", "==", userId)
      .get();
    return eventsSnapshot.size;
  } catch (error) {
    console.error(`❌ Error counting events for user ${userId}:`, error);
    return 0;
  }
}

// Function to generate events for users
async function generateEventsForUsers(users, categories) {
  const generatedEvents = [];

  for (const user of users) {
    const existingEventCount = await countUserEvents(user.id);
    const eventsToCreate = Math.min(
      3 - existingEventCount,
      getRandomNumber(1, 3)
    );

    if (eventsToCreate <= 0) {
      console.log(
        `⏭️ User ${user.firstName} ${user.lastName} already has ${existingEventCount} events (max 3). Skipping.`
      );
      continue;
    }

    console.log(
      `🎯 Generating ${eventsToCreate} events for user: ${user.firstName} ${user.lastName}`
    );

    for (let i = 0; i < eventsToCreate; i++) {
      // Select random category and subcategory
      const category = getRandomElement(categories);
      const subcategory =
        category.subcategories.length > 0
          ? getRandomElement(category.subcategories)
          : { id: "general", name: "General" };

      // Get event template based on category
      const templates =
        eventTemplates[category.id] || eventTemplates.social_community;
      const template = getRandomElement(templates);

      // Generate event data
      const event = {
        eventName: template.name,
        details: template.description,
        categoryId: category.id,
        subcategoryId: subcategory.id,
        dateTime: generateFutureDate(),
        timezone: "Europe/Bucharest",
        status: "active",
        maxAttendees: template.maxAttendees,
        minAge: getRandomNumber(16, 25),
        maxAge: getRandomNumber(35, 65),
        imageUrl: "",
        attendees: [user.id],
        user_liked: [], // Users who liked this event
        users_declined: [], // Users who declined this event
        createdBy: user.id,
        requiresApproval: Math.random() > 0.5, // 50% chance of requiring approval
        location: generateLocationNearUser(user.location),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      generatedEvents.push(event);
      console.log(
        `  ✅ Generated: ${event.eventName} (${category.name}/${subcategory.name})`
      );
    }
  }

  return generatedEvents;
}

async function seedEventsData() {
  try {
    console.log("🚀 Starting users_events seeding...");

    // Fetch categories and users from database
    const categories = await fetchCategories();
    const users = await fetchUsers();

    if (users.length === 0) {
      console.log("⚠️ No users found. Cannot create events without users.");
      return;
    }

    // Generate events for users (max 3 per user)
    const eventsToCreate = await generateEventsForUsers(users, categories);

    if (eventsToCreate.length === 0) {
      console.log(
        "ℹ️ No events to create. All users already have maximum events or no users available."
      );
      return;
    }

    console.log(`\n📝 Creating ${eventsToCreate.length} events...`);

    // Create events in batches (Firestore has a limit of 500 operations per batch)
    const batchSize = 500;
    const batches = [];

    for (let i = 0; i < eventsToCreate.length; i += batchSize) {
      const batch = db.batch();
      const batchEvents = eventsToCreate.slice(i, i + batchSize);

      batchEvents.forEach((eventData) => {
        const eventRef = db.collection("users_events").doc();
        batch.set(eventRef, eventData);
      });

      batches.push(batch);
    }

    // Commit all batches
    for (let i = 0; i < batches.length; i++) {
      await batches[i].commit();
      console.log(`✅ Committed batch ${i + 1}/${batches.length}`);
    }

    console.log("✅ Successfully seeded users_events collection!");
    console.log(`📊 Total events created: ${eventsToCreate.length}`);

    // Verify the data
    const eventsSnapshot = await db.collection("users_events").get();
    console.log(
      `🔍 Verification: Found ${eventsSnapshot.size} total events in collection`
    );

    // Display summary by user
    console.log("\n📋 Events created by user:");
    const userEventCounts = {};

    for (const user of users) {
      const userEventsCount = await countUserEvents(user.id);
      userEventCounts[user.id] = userEventsCount;
      console.log(
        `👤 ${user.firstName} ${user.lastName}: ${userEventsCount}/3 events`
      );
    }

    // Display sample of created events
    console.log("\n📅 Sample of recently created events:");
    const recentEvents = eventsToCreate.slice(0, 5);
    recentEvents.forEach((event, index) => {
      const user = users.find((u) => u.id === event.createdBy);
      console.log(
        `${index + 1}. ${event.eventName} - ${event.categoryId}/${
          event.subcategoryId
        } (by ${user?.firstName} ${user?.lastName})`
      );
    });
  } catch (error) {
    console.error("❌ Error seeding events data:", error);
  } finally {
    console.log("🏁 Seeding process completed");
    process.exit(0);
  }
}

// Function to clean up existing events (for testing)
async function cleanupEvents() {
  try {
    console.log("🧹 Cleaning up existing events...");

    const eventsSnapshot = await db.collection("users_events").get();
    const batches = [];
    const batchSize = 500;

    for (let i = 0; i < eventsSnapshot.docs.length; i += batchSize) {
      const batch = db.batch();
      const batchDocs = eventsSnapshot.docs.slice(i, i + batchSize);

      batchDocs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      batches.push(batch);
    }

    for (let i = 0; i < batches.length; i++) {
      await batches[i].commit();
      console.log(`✅ Cleaned batch ${i + 1}/${batches.length}`);
    }

    console.log(`✅ Cleaned up ${eventsSnapshot.docs.length} events`);
  } catch (error) {
    console.error("❌ Error cleaning up events:", error);
  }
}

// Main execution
const main = async () => {
  try {
    const command = process.argv[2];

    switch (command) {
      case "seed":
        await seedEventsData();
        break;
      case "cleanup":
        await cleanupEvents();
        break;
      default:
        console.log("Usage:");
        console.log("  npm run seed:events seed    - Seed events data");
        console.log("  npm run seed:events cleanup - Clean up events");
        console.log("  npm run seed:events         - Default: seed events");
        await seedEventsData();
        break;
    }
  } catch (error) {
    console.error("❌ Process failed:", error);
    process.exit(1);
  }
};

// Run the script
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
} else {
  // If imported as module, just run the seeder
  seedEventsData();
}
