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
    console.log("📋 Fetching categories from Firebase...");
    const categoriesSnapshot = await db
      .collection("categories")
      .where("isActive", "==", true)
      .get();

    if (categoriesSnapshot.empty) {
      console.log("⚠️ No active categories found. Checking all categories...");
      const allCategoriesSnapshot = await db.collection("categories").get();

      if (allCategoriesSnapshot.empty) {
        throw new Error(
          "No categories found in database. Please run the categories seeder first."
        );
      } else {
        console.log(
          `📝 Found ${allCategoriesSnapshot.size} categories (some may be inactive)`
        );
      }
    }

    const categories = [];
    categoriesSnapshot.forEach((doc) => {
      const data = doc.data();
      categories.push({
        id: data.id || doc.id,
        name: data.name || data.id || doc.id,
        subcategories: data.subcategories || [],
      });
    });

    // If no active categories, fall back to all categories
    if (categories.length === 0) {
      const allCategoriesSnapshot = await db.collection("categories").get();
      allCategoriesSnapshot.forEach((doc) => {
        const data = doc.data();
        categories.push({
          id: data.id || doc.id,
          name: data.name || data.id || doc.id,
          subcategories: data.subcategories || [],
        });
      });
    }

    console.log(`✅ Found ${categories.length} categories to use for events`);

    // Debug: Show sample categories
    console.log("📝 Sample categories:");
    categories.slice(0, 3).forEach((cat, index) => {
      console.log(
        `  ${index + 1}. ${cat.name} (${
          cat.subcategories.length
        } subcategories)`
      );
    });

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
      console.log("⚠️ No users found in database. Creating 10 sample users...");
      return await createSampleUsers();
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

    // If we have fewer than 10 users, create additional users
    if (users.length < 10) {
      console.log(
        `📝 Creating ${10 - users.length} additional users to reach 10 total...`
      );
      const additionalUsers = await createSampleUsers(
        10 - users.length,
        users.length
      );
      users.push(...additionalUsers);
    }

    // Take only the first 10 users for seeding
    const selectedUsers = users.slice(0, 10);

    // Debug: Show selected user data
    console.log("📝 Selected users for seeding:");
    selectedUsers.forEach((user, index) => {
      console.log(
        `  ${index + 1}. ${user.firstName} ${user.lastName} (${user.id})`
      );
    });

    return selectedUsers;
  } catch (error) {
    console.error("❌ Error fetching users:", error);
    throw error;
  }
}

// Function to create sample users
async function createSampleUsers(count = 10, startIndex = 0) {
  const sampleUsers = [];
  const firstNames = [
    "Alex",
    "Maria",
    "David",
    "Ana",
    "Mihai",
    "Elena",
    "Radu",
    "Ioana",
    "Andrei",
    "Cristina",
    "Stefan",
    "Andreea",
    "Vlad",
    "Diana",
    "Bogdan",
    "Raluca",
    "Florin",
    "Bianca",
    "Adrian",
    "Carmen",
  ];
  const lastNames = [
    "Popescu",
    "Ionescu",
    "Popa",
    "Radu",
    "Stoica",
    "Dumitrescu",
    "Gheorghe",
    "Stan",
    "Marin",
    "Tudor",
    "Dima",
    "Preda",
    "Cristea",
    "Matei",
    "Niculescu",
    "Florea",
    "Dobre",
    "Constantinescu",
    "Barbu",
    "Nistor",
  ];

  // Sample locations in Romania
  const sampleLocations = [
    {
      address: {
        administrativeArea: "București",
        country: "Romania",
        fullAddress: "Piața Universității, București, România",
        locality: "București",
        name: "Piața Universității",
      },
      geohash: "u8q2w5k9p",
      geopoint: new admin.firestore.GeoPoint(44.4372, 26.1019),
      lat: 44.4372,
      lng: 26.1019,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      address: {
        administrativeArea: "Cluj",
        country: "Romania",
        fullAddress: "Piața Unirii, Cluj-Napoca, România",
        locality: "Cluj-Napoca",
        name: "Piața Unirii",
      },
      geohash: "u8q2w5k9q",
      geopoint: new admin.firestore.GeoPoint(46.7712, 23.6236),
      lat: 46.7712,
      lng: 23.6236,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      address: {
        administrativeArea: "Timiș",
        country: "Romania",
        fullAddress: "Piața Victoriei, Timișoara, România",
        locality: "Timișoara",
        name: "Piața Victoriei",
      },
      geohash: "u8q2w5k9r",
      geopoint: new admin.firestore.GeoPoint(45.7489, 21.2087),
      lat: 45.7489,
      lng: 21.2087,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
  ];

  for (let i = 0; i < count; i++) {
    const firstName = getRandomElement(firstNames);
    const lastName = getRandomElement(lastNames);
    const userIndex = startIndex + i + 1;

    const userData = {
      email: `user${userIndex}@example.com`,
      firstName: firstName,
      lastName: lastName,
      displayName: `${firstName} ${lastName}`,
      location: getRandomElement(sampleLocations),
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    try {
      const userRef = db.collection("users").doc();
      await userRef.set(userData);

      sampleUsers.push({
        id: userRef.id,
        email: userData.email,
        firstName: userData.firstName,
        lastName: userData.lastName,
        location: userData.location,
      });

      console.log(
        `  ✅ Created user: ${firstName} ${lastName} (${userRef.id})`
      );
    } catch (error) {
      console.error(`❌ Error creating user ${firstName} ${lastName}:`, error);
    }
  }

  return sampleUsers;
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

  console.log(
    `🎯 Generating exactly 3 events for each of the ${users.length} users...`
  );

  for (const user of users) {
    // Clean up existing events for this user first
    await cleanupUserEvents(user.id);

    console.log(
      `📝 Creating 3 events for user: ${user.firstName} ${user.lastName}`
    );

    // Create exactly 3 events for each user
    for (let i = 0; i < 3; i++) {
      // Select random category and subcategory
      const category = getRandomElement(categories);
      const subcategory =
        category.subcategories && category.subcategories.length > 0
          ? getRandomElement(category.subcategories)
          : { id: "general", name: "General" };

      // Get event template based on category id or name
      const categoryKey =
        category.id || category.name?.toLowerCase().replace(/[^a-z0-9]/g, "_");
      const templates =
        eventTemplates[categoryKey] || eventTemplates.social_community;
      const template = getRandomElement(templates);

      // Generate event data
      const event = {
        eventName: `${template.name} #${i + 1}`,
        details: template.description,
        categoryId: category.id,
        subcategoryId: subcategory.id,
        dateTime: generateFutureDate(1 + i, 30 + i * 10), // Spread events over time
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
        `  ✅ Generated: ${event.eventName} (${category.name || category.id}/${
          subcategory.name
        })`
      );
    }
  }

  return generatedEvents;
}

// Function to clean up existing events for a specific user
async function cleanupUserEvents(userId) {
  try {
    const userEventsSnapshot = await db
      .collection("users_events")
      .where("createdBy", "==", userId)
      .get();

    if (!userEventsSnapshot.empty) {
      const batch = db.batch();
      userEventsSnapshot.forEach((doc) => {
        batch.delete(doc.ref);
      });
      await batch.commit();
      console.log(
        `  🧹 Cleaned up ${userEventsSnapshot.size} existing events for user ${userId}`
      );
    }
  } catch (error) {
    console.error(`❌ Error cleaning up events for user ${userId}:`, error);
  }
}

async function seedEventsData() {
  try {
    console.log(
      "🚀 Starting users_events seeding for 10 users with 3 events each..."
    );

    // Fetch categories from Firebase
    const categories = await fetchCategories();

    // Ensure we have exactly 10 users (create if needed)
    const users = await fetchUsers();

    console.log(`\n📊 Seeding Summary:`);
    console.log(`  👥 Users: ${users.length}`);
    console.log(`  📋 Categories: ${categories.length}`);
    console.log(`  🎯 Target events: ${users.length * 3} (3 per user)`);

    // Generate exactly 3 events for each user
    const eventsToCreate = await generateEventsForUsers(users, categories);

    console.log(`\n📝 Creating ${eventsToCreate.length} events in batches...`);

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

    console.log("\n✅ Successfully seeded users_events collection!");
    console.log(`📊 Final Results:`);
    console.log(`  👥 Users created/used: ${users.length}`);
    console.log(`  🎉 Events created: ${eventsToCreate.length}`);

    // Verify the data
    const eventsSnapshot = await db.collection("users_events").get();
    console.log(
      `🔍 Verification: Found ${eventsSnapshot.size} total events in collection`
    );

    // Display detailed summary by user
    console.log("\n📋 Events created per user:");
    for (const user of users) {
      const userEventsCount = await countUserEvents(user.id);
      console.log(
        `👤 ${user.firstName} ${user.lastName}: ${userEventsCount}/3 events`
      );
    }

    // Display sample of created events grouped by category
    console.log("\n📅 Sample events by category:");
    const categoryEventCounts = {};
    eventsToCreate.forEach((event) => {
      categoryEventCounts[event.categoryId] =
        (categoryEventCounts[event.categoryId] || 0) + 1;
    });

    Object.entries(categoryEventCounts).forEach(([categoryId, count]) => {
      const category = categories.find((c) => c.id === categoryId);
      console.log(`  📊 ${category?.name || categoryId}: ${count} events`);
    });
  } catch (error) {
    console.error("❌ Error seeding events data:", error);
    throw error;
  } finally {
    console.log("🏁 Seeding process completed");
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

// Function to clean up existing users (for complete reset)
async function cleanupUsers() {
  try {
    console.log("🧹 Cleaning up existing users...");

    const usersSnapshot = await db.collection("users").get();
    const batches = [];
    const batchSize = 500;

    for (let i = 0; i < usersSnapshot.docs.length; i += batchSize) {
      const batch = db.batch();
      const batchDocs = usersSnapshot.docs.slice(i, i + batchSize);

      batchDocs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      batches.push(batch);
    }

    for (let i = 0; i < batches.length; i++) {
      await batches[i].commit();
      console.log(`✅ Cleaned user batch ${i + 1}/${batches.length}`);
    }

    console.log(`✅ Cleaned up ${usersSnapshot.docs.length} users`);
  } catch (error) {
    console.error("❌ Error cleaning up users:", error);
  }
}

// Function to perform complete seed (clean + create)
async function fullSeed() {
  try {
    console.log("🔄 Performing complete database seed...");
    console.log("⚠️  This will delete all existing users and events!");

    // Clean up existing data
    await cleanupEvents();
    await cleanupUsers();

    console.log("\n🌱 Starting fresh seeding...");
    await seedEventsData();

    console.log("✅ Complete seeding finished successfully!");
  } catch (error) {
    console.error("❌ Error in full seed:", error);
    throw error;
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
      case "cleanup-users":
        await cleanupUsers();
        break;
      case "full-seed":
        await fullSeed();
        break;
      default:
        console.log("Usage:");
        console.log(
          "  npm run seed:events seed         - Seed events data (10 users × 3 events)"
        );
        console.log(
          "  npm run seed:events cleanup      - Clean up events only"
        );
        console.log(
          "  npm run seed:events cleanup-users - Clean up users only"
        );
        console.log(
          "  npm run seed:events full-seed    - Complete reset + seed (users & events)"
        );
        console.log(
          "  npm run seed:events              - Default: seed events"
        );
        console.log("");
        console.log("🎯 Running default seeding (10 users × 3 events each)...");
        await seedEventsData();
        break;
    }
  } catch (error) {
    console.error("❌ Process failed:", error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
};

// Run the script
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
} else {
  // If imported as module, just run the seeder
  seedEventsData();
}
